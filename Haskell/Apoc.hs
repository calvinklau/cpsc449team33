{- |
Module      : Main
Description : The module that handles Apocalypse gameplay
Copyright   : Copyright 2016, Rob Kremer (rkremer@ucalgary.ca), University of Calgary.
License     : Permission to use, copy, modify, distribute and sell this software
              and its documentation for any purpose is hereby granted without fee, provided
              that the above copyright notice appear in all copies and that both that
              copyright notice and this permission notice appear in supporting
              documentation. The University of Calgary makes no representations about the
              suitability of this software for any purpose. It is provided "as is" without
              express or implied warranty.
Maintainer  : rkremer@ucalgary.ca
Stability   : experimental
Portability : ghc 7.10.2 - 7.10.3
-}

module Main (
      -- * Main
      main, main',
      -- * Utility functions
      replace, replace2
      ) where

import Data.Maybe (fromJust, isNothing)
import System.Environment
import System.IO.Unsafe
import ApocTools
import ApocStrategyHuman
import ApocStrategyGreedy
import System.Exit (exitSuccess)
import ApocStrategyRandom

---Main-------------------------------------------------------------

-- | The main entry, which just calls 'main'' with the command line arguments.
main = main' (unsafePerformIO getArgs)

{- | We have a main' IO function so that we can either:

     1. call our program from GHCi in the usual way
     2. run from the command line by calling this function with the value from (getArgs)
-}
main'           :: [String] -> IO()
main' args = do
    if (checkNumberArgs args == "interactiveMode")
      then interactiveMode args
      else do
                   if (verifyStrategy (args !! 0) && verifyStrategy (args !! 1))
                   then do (putStrLn (show initBoard))
                           (gameLoop initBoard (getStrategy (args !! 0)) (getStrategy (args !! 1)) (args !! 0) (args !! 1))
                   else printStrategies

{- | This is the main game loop
 It takes in an initial state, a black strategy, a white strategy, and the names for the black and white strategy, respectively.
 Prints a representation of the Game State to IO each iteration and prints a message if the game ends.
-}
gameLoop :: GameState -> Chooser -> Chooser -> String -> String -> IO()
gameLoop state blackStrat whiteStrat blackName whiteName = do
    blackMove <- blackStrat (state) Normal Black
    whiteMove <- whiteStrat (state) Normal White
    let nextState = GameState (if blackMove==Nothing
                                then Passed
                                else if ((checkMove (theBoard state) ((fromJust blackMove) !! 0) ((fromJust blackMove) !! 1) Black) /= "Goofed")
                                     then Played (head (fromJust blackMove), head (tail (fromJust blackMove)))
                                     else Goofed (head (fromJust blackMove), head (tail(fromJust blackMove))))
                               ((blackPen state) + (if (blackMove == Nothing) then 0 else (if (checkMove (theBoard state) ((fromJust blackMove) !! 0) ((fromJust blackMove) !! 1) Black) == "Goofed" then 1 else 0)))
                               (if whiteMove==Nothing
                                then Passed
                                else if ((checkMove (theBoard state) ((fromJust whiteMove) !! 0) ((fromJust whiteMove) !! 1) White) /= "Goofed")
                                     then Played (head (fromJust whiteMove), head (tail (fromJust whiteMove)))
                                     else Goofed (head (fromJust whiteMove), head (tail(fromJust whiteMove))))
                               (whitePen state + (if (whiteMove == Nothing) then 0 else (if(checkMove (theBoard state) ((fromJust whiteMove) !! 0) ((fromJust whiteMove) !! 1) White) == "Goofed" then 1 else 0)))
                               (if ((blackMove /= Nothing) && (checkMove (theBoard state) ((fromJust blackMove) !! 0) ((fromJust blackMove) !! 1) Black) == "Goofed") && ((whiteMove /= Nothing) && (checkMove (theBoard state) ((fromJust whiteMove) !! 0) ((fromJust whiteMove) !! 1) White) == "Goofed") --Both players goofed
                                then (theBoard state) --do nothing if both players goof
                                else if (whiteMove /= Nothing) && ((checkMove (theBoard state) ((fromJust whiteMove) !! 0) ((fromJust whiteMove) !! 1) White) == "Goofed")
                                         then handleMove state blackMove Nothing --do nothing for white if white goofs
                                         else if (blackMove /= Nothing) && ((checkMove (theBoard state) ((fromJust blackMove) !! 0) ((fromJust blackMove) !! 1) Black) == "Goofed")
                                               then handleMove state Nothing whiteMove --do nothing for black if black goofs
                                               else handleMove state blackMove whiteMove) --neither player goofed
    putStrLn(show nextState)

    if (isGameOver nextState blackMove whiteMove) then (putStrLn(gameOverReason nextState blackMove whiteMove blackName whiteName)) else if (pawnCrossed (theBoard nextState) Black) || (pawnCrossed (theBoard nextState) White) then (handlePawnPlacement nextState blackStrat whiteStrat blackName whiteName) else  (gameLoop nextState blackStrat whiteStrat blackName whiteName)

{- | Handles the placement of pawns or their upgrades when they reach the end of the board.
Takes in an initial state , and the strategies of Black and White, and their names, respectively
Prompts movement, or automatically upgrades pawns based on the number of knights
Prints a representation of the Game State to IO, and returns to the main game loop.
-}
handlePawnPlacement :: GameState -> Chooser -> Chooser -> String -> String -> IO()
handlePawnPlacement state blackStrat whiteStrat blackName whiteName = do
    blackMove <- if ((fst (countKnights (theBoard state))) >= 2) && (pawnCrossed (theBoard state) Black) then blackStrat (state) PawnPlacement Black else return Nothing --get black's move if black needs to make a move
    whiteMove <- if((snd (countKnights (theBoard state))) >= 2) && (pawnCrossed (theBoard state) White) then whiteStrat (state) PawnPlacement White else return Nothing --get white's move if white needs to make a move
    let nextState = GameState (if pawnCrossed (theBoard state) Black --if there is a black pawn at the opposite end of the board
                                  then (if blackMove == Nothing --then if there was no move or the pawn needed to be upgraded
                                      then if (fst (countKnights (theBoard state)) < 2)
                                          then UpgradedPawn2Knight (findPawn (theBoard state) Black) --upgrade the pawn
                                          else NullPlacedPawn --no move taken
                                      else if (checkPawnPlacement (theBoard state) ((fromJust blackMove) !! 0)) == "Goofed" --if the player made a mistake in placement
                                          then BadPlacedPawn ((findPawn (theBoard state) Black), ((fromJust blackMove) !! 0))
                                          else PlacedPawn ((findPawn (theBoard state) Black), ((fromJust blackMove) !! 0)))
                                  else None)
                                  ((blackPen state) + (if (blackMove == Nothing) then (if (fst (countKnights (theBoard state)) < 2) || (not (pawnCrossed (theBoard state) Black)) then 0 else 1) else (if (checkPawnPlacement (theBoard state) ((fromJust blackMove) !! 0)) == "Goofed" then 1 else 0))) --White penalty
                                  (if pawnCrossed (theBoard state) White then (if (whiteMove == Nothing) then (if (snd (countKnights (theBoard state)) < 2) then (UpgradedPawn2Knight (findPawn (theBoard state) White)) else (NullPlacedPawn) )else (if (checkPawnPlacement (theBoard state) ((fromJust whiteMove) !! 0)) == "Goofed" then BadPlacedPawn ((findPawn (theBoard state) White), ((fromJust whiteMove) !! 0)) else PlacedPawn ((findPawn (theBoard state) White), ((fromJust whiteMove) !! 0)))) else None) -- White's movement - functions virtually identically to Black's movement - on one line because Haskell's formatting rules didn't like it otherwise
                                  ((whitePen state) + (if (whiteMove == Nothing) then (if (snd (countKnights (theBoard state)) < 2) || (not (pawnCrossed (theBoard state) White)) then 0 else 1) else (if (checkPawnPlacement (theBoard state) ((fromJust whiteMove) !! 0)) == "Goofed" then 1 else 0))) --Black penalty
                                  (if ((blackMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust blackMove) !! 0) == "Goofed") && (whiteMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust whiteMove) !! 0) == "Goofed")) --both players goofed
                                  then (theBoard state)
                                  else if (whiteMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust whiteMove) !! 0) == "Goofed")
                                         then (handleMovePlacement state blackMove Nothing) --white goofed
                                         else if (blackMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust blackMove) !! 0) == "Goofed")
                                                then (handleMovePlacement state Nothing whiteMove) --black goofed
                                                else (handleMovePlacement state blackMove whiteMove))

    putStrLn(show nextState)
    if ((blackMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust blackMove) !! 0) == "Goofed") || (whiteMove /= Nothing) && (checkPawnPlacement (theBoard state) ((fromJust whiteMove) !! 0) == "Goofed"))
    then if (isGameOver' nextState) then (putStrLn(gameOverReason nextState blackMove whiteMove blackName whiteName)) else (handlePawnPlacement nextState blackStrat whiteStrat blackName whiteName)
    else if (isGameOver' nextState) then (putStrLn(gameOverReason nextState blackMove whiteMove blackName whiteName)) else (gameLoop nextState blackStrat whiteStrat blackName whiteName)

{- | Handles changing the board based on the players' moves.
Takes in a game state, and the moves of Black and White respectively,
and returns the board wherein Black and White's moves are played simultaneously.
-}
handleMove :: GameState -> Maybe [(Int,Int)] -> Maybe [(Int,Int)] -> Board
handleMove state blackMove whiteMove
 |((blackMove == Nothing) && (whiteMove == Nothing)) = (theBoard state) -- black and white pass
 |((blackMove == Nothing) && (whiteMove /= Nothing))= (replace2 (replace2 (theBoard state) ((fromJust whiteMove) !! 1) (getFromBoard (theBoard state) ((fromJust whiteMove) !! 0))) ((fromJust whiteMove) !! 0) E) --Black passes
 |((whiteMove == Nothing) && (blackMove /= Nothing)) = (replace2 (replace2 (theBoard state) ((fromJust blackMove) !! 1) (getFromBoard (theBoard state) ((fromJust blackMove) !! 0))) ((fromJust blackMove) !! 0) E) --White passes
 |(((fromJust whiteMove) !! 1) == ((fromJust blackMove) !! 1)) && (((getFromBoard (theBoard state) ((fromJust whiteMove) !! 0)) == WP) && ((getFromBoard (theBoard state) ((fromJust blackMove) !! 0)) == BP))  = (replace2 (replace2 (replace2 (theBoard state) ((fromJust blackMove) !! 1) E) ((fromJust blackMove) !! 0) E) ((fromJust whiteMove) !! 0) E) --Pawn v Pawn clash
 |(((fromJust whiteMove) !! 1) == ((fromJust blackMove) !! 1)) && (((getFromBoard (theBoard state) ((fromJust whiteMove) !! 0)) == WK) && ((getFromBoard (theBoard state) ((fromJust blackMove) !! 0)) == BK))  = (replace2 (replace2 (replace2 (theBoard state) ((fromJust blackMove) !! 1) E) ((fromJust blackMove) !! 0) E) ((fromJust whiteMove) !! 0) E) -- Knight v Knight clash
 |(((fromJust whiteMove) !! 1) == ((fromJust blackMove) !! 1)) && (((getFromBoard (theBoard state) ((fromJust whiteMove) !! 0)) == WK) && ((getFromBoard (theBoard state) ((fromJust blackMove) !! 0)) == BP))  = (replace2 (replace2 (replace2 (theBoard state) ((fromJust whiteMove) !! 0) E) ((fromJust blackMove) !! 0) E) ((fromJust whiteMove) !! 1) WK) --White Knight v Black Pawn clash
 |(((fromJust whiteMove) !! 1) == ((fromJust blackMove) !! 1)) && (((getFromBoard (theBoard state) ((fromJust whiteMove) !! 0)) == WP) && ((getFromBoard (theBoard state) ((fromJust blackMove) !! 0)) == BK))  = (replace2 (replace2 (replace2 (theBoard state) ((fromJust whiteMove) !! 0) E) ((fromJust blackMove) !! 0) E) ((fromJust whiteMove) !! 1) BK) --Black Knight v White Pawn clash
 |otherwise = (replace2 (replace2 (replace2 (replace2 (theBoard state) -- valid move / no clashes /no passes
                                                   ((fromJust blackMove) !! 0)
                                                   E)
                                         ((fromJust whiteMove) !! 0)
                                         E) ((fromJust whiteMove) !! 1) (getFromBoard (theBoard state) ((fromJust whiteMove) !! 0))) ((fromJust blackMove) !! 1) (getFromBoard (theBoard state) ((fromJust blackMove) !! 0)))

{- | Handles the board for pawn placement and upgrades after a pawn reaches the end of the board.
 Takes in a game state, and the moves of Black and White respectively.
 Returns the board after Black and White's actions are performed, simultaneously.
-}
handleMovePlacement :: GameState -> Maybe [(Int, Int)] -> Maybe[(Int, Int)] -> Board
handleMovePlacement state blackMove whiteMove
 |((blackMove == Nothing) && (pawnCrossed (theBoard state) Black)) && ((whiteMove == Nothing) && (pawnCrossed (theBoard state) White)) && (fst (countKnights (theBoard state)) < 2) && (snd (countKnights (theBoard state)) < 2) = (replace2 (replace2 (theBoard state) (findPawn (theBoard state) White) WK) (findPawn (theBoard state) Black) BK) --Both players need to upgrade to knights
 |((blackMove == Nothing) && (pawnCrossed (theBoard state) Black)) && (whiteMove == Nothing) && (fst (countKnights (theBoard state)) < 2) = (replace2 (theBoard state) (findPawn (theBoard state) Black) BK) --Black needs to upgrade, white takes no action
 |((whiteMove == Nothing) && (pawnCrossed (theBoard state) White)) && (blackMove == Nothing) && (snd (countKnights (theBoard state)) < 2) = (replace2 (theBoard state) (findPawn (theBoard state) White) WK) --White needs to upgrade, black takes no action
 |((blackMove == Nothing) && (pawnCrossed (theBoard state) Black)) && (fst (countKnights (theBoard state)) < 2) = (replace2 (replace2 (replace2 (theBoard state) (findPawn (theBoard state) Black) BK) (findPawn (theBoard state) White) E) ((fromJust whiteMove) !! 0) WP) -- Black upgrades, white moves
 |((whiteMove == Nothing) && (pawnCrossed (theBoard state) White)) && (snd (countKnights (theBoard state)) < 2) =  (replace2 (replace2 (replace2 (theBoard state) (findPawn (theBoard state) White) WK) (findPawn (theBoard state) Black) E) ((fromJust blackMove) !! 0) BP) -- White upgrades, black moves
 |(blackMove == Nothing) && (whiteMove == Nothing) = (theBoard state) -- nothing happens (both players pass)
 |(blackMove == Nothing) = (replace2 (replace2 (theBoard state) ((fromJust whiteMove) !! 0) WP) (findPawn (theBoard state) White) E) -- White moves
 |(whiteMove == Nothing) = (replace2 (replace2 (theBoard state) ((fromJust blackMove) !! 0) BP) (findPawn (theBoard state) Black) E) --Black moves
 |((fromJust blackMove) !! 0) == ((fromJust whiteMove) !! 0) = (replace2 (replace2 (theBoard state) (findPawn (theBoard state) Black) E) (findPawn (theBoard state) White) E) --Black and White both move to the same space (clash, no survivors)
 |otherwise = (replace2 (replace2 (replace2 (replace2 (theBoard state) (findPawn (theBoard state) Black) E) (findPawn (theBoard state) White) E) ((fromJust whiteMove) !! 0) WP) ((fromJust blackMove) !! 0) BP) --Black and White move to different spaces


{- | Checks to see if the game has ended due to both players passing, player(s) running out of pawns, player(s) gaining 2 penalties
Takes the gameState and black and white's moves, respectively
returns True if black and white's moves will cause the game to end, and False otherwise
-}
isGameOver :: GameState -> Maybe[(Int,Int)] -> Maybe[(Int,Int)] -> Bool
isGameOver state blackMove whiteMove
 |(blackMove == Nothing) && (whiteMove == Nothing) = True -- both players passed
 |((blackPen state) > 1) || ((whitePen state) > 1) = True --game over by penalty
 |(fst(countPawns (theBoard state)) == 0) || (snd(countPawns (theBoard state)) == 0) = True --game over by pawn loss
 |otherwise = False

-- | companion to isGameOver - specifically for pawn placement checking so it doesn't game over when both players return Nothing
isGameOver' :: GameState -> Bool
isGameOver' state
 |((blackPen state) > 1) || ((whitePen state) > 1) = True --game over by penalty
 |(fst(countPawns (theBoard state)) == 0) || (snd(countPawns (theBoard state)) == 0) = True --game over by pawn loss
 |otherwise = False

{- | Prints the reason as to why the game has ended
Takes a game state, and Black and white's moves and names, respectively.
Returns the game over message corresponding to the effects of Black and White's moves.
-}
gameOverReason :: GameState -> Maybe[(Int,Int)] -> Maybe[(Int,Int)]  -> String -> String ->String
gameOverReason state blackMove whiteMove blackName whiteName
 |((blackMove == Nothing) && (whiteMove == Nothing)) && ((fst (countPawns (theBoard state))) == (snd (countPawns (theBoard state)))) = ("Tie: Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) --both players forfeit - same # of pawns
 |((blackMove == Nothing) && (whiteMove == Nothing)) && ((fst (countPawns (theBoard state))) > (snd (countPawns (theBoard state)))) = ("Black Wins!  Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) -- black has more pawns than white on forfeit
 |((blackMove == Nothing) && (whiteMove == Nothing)) && ((fst (countPawns (theBoard state))) < (snd (countPawns (theBoard state)))) = ("White Wins!  Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) -- white has more pawns on forfeit
 |((blackPen state) > 1) && ((whitePen state) > 1) = "Tie: Both players had too many penalty points." --black penalty = 2/white penalty = 2
 |((blackPen state) > 1) = "White wins! Black had too many penalty points." -- black penalty = 2, white penalty < 2
 |((whitePen state) > 1) = "Black wins! White had too many penalty points." -- white penalty = 2, black penalty < 2
 |(fst (countPawns (theBoard state)) == 0) && (snd (countPawns (theBoard state)) == 0) = ("Tie: Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) --both players have no pawns
 |(fst (countPawns (theBoard state)) == 0) =  ("White wins!  Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) --black has no pawns
 |(snd (countPawns (theBoard state)) == 0) = ("Black Wins!  Black (" ++ blackName ++ "): " ++ (show (fst (countPawns (theBoard state)))) ++ " White (" ++ whiteName ++ "): " ++ (show (snd (countPawns (theBoard state))))) --white has no pawns
 |otherwise = "This wasn't supposed to happen."
---2D list utility functions-------------------------------------------------------

-- | Replaces the nth element in a row with a new element.
replace :: [a] -> Int -> a -> [a]
replace xs n elem = let (ys,zs) = splitAt n xs
                     in (if null zs then (if null ys then [] else init ys) else ys)
                        ++ [elem]
                        ++ (if null zs then [] else tail zs)

-- | Replaces the (x,y)th element in a list of lists with a new element.
replace2 :: [[a]] -> (Int,Int) -> a -> [[a]]
replace2 xs (x,y) elem = replace xs y (replace (xs !! y) x elem)

-- | Verifies that the user enters the correct amount of command line arguments
checkNumberArgs :: [a] -> String
checkNumberArgs x
  | len == 2  = "Valid number of cmd line arguments"
  | len == 0  = "interactiveMode"
  | otherwise = "interactiveMode"
  where len = length x

{- | Count the number of pawns on the board
     Takes in the game board and returns the number of pawns (Black, White)
-}
countPawns :: Board -> (Int, Int)
countPawns xss = ((length (filter (== '+') (board2Str xss))),(length (filter (== '/') (board2Str xss))))

{- | Count the number of knights on the board
     Takes in the game board and returns the number of knights (Black, White)
-}
countKnights :: Board -> (Int, Int)
countKnights xss = ((length (filter (== '#') (board2Str xss))),(length (filter (== 'X') (board2Str xss))))

{- | checks if a pawn has crossed to the other side
    Takes in the board and the player that you want to examine,
     and returns whether or not that player has crossed to the opposite side of the board (True or False)
-}
pawnCrossed :: Board -> Player -> Bool
pawnCrossed board Black = (BP `elem` (board !! 0))
pawnCrossed board White = (WP `elem` (board !! 4))

{- | Finds the coordinates of the first (only!) pawn in the top of the board (for black) or the bottom of the board (for white)
     Takes in the board and the player you want to examine, and returns their coordinates.
-}
findPawn :: Board -> Player -> (Int, Int)
findPawn board Black = findPawn' (head board) Black 0
findPawn board White = findPawn' (last board) White 0

-- | Helper for findPawn
findPawn' :: [Cell] -> Player -> Int -> (Int, Int)
findPawn' [] Black a = (0,0) --should never happen
findPawn' (x:xs) Black a = if x == BP then (a,0) else findPawn' xs Black (a+1)
findPawn' [] White a = (0,0) --should never happen
findPawn' (x:xs) White a = if x == WP then (a,4) else findPawn' xs White (a+1)


{- |The Interactive Mode
     Prompts for input on both strategies, and starts the game if they're provided
     or prints the list of valid strategies if either strategy name is malformed.
-}
interactiveMode :: [String] -> IO ()
interactiveMode args = do
  if (length args == 0)
  then do
           putStrLn("Possible Strategies: ")
           putStr("  human\n  greedy\n  random\n")
           putStr("Enter Black Strategy: \n")
           blackStrat <- getLine
           putStr("Enter White Strategy: \n")
           whiteStrat <- getLine
           if (verifyStrategy blackStrat) && (verifyStrategy whiteStrat)
             then do
                 putStrLn(show(initBoard))
                 gameLoop initBoard (getStrategy blackStrat) (getStrategy whiteStrat) blackStrat whiteStrat
             else printStrategies
  else printStrategies


{- | Verifies that a strategy name has been inputted correctly
       Returns True if so, and False otherwise
 -}
verifyStrategy :: String -> Bool
verifyStrategy x
    | x == "human" = True
    | x == "greedy" = True
    | x == "random" = True
    | otherwise = False

{- |Gets the strategy corresponding to the name given
-}
getStrategy :: String -> Chooser
getStrategy x
 | x == "human" = human
 | x == "greedy" = greedy
 | x == "random" = random

{- |Prints the list of valid strategies and exits.
-}
printStrategies :: IO ()
printStrategies = do
  putStr("  human\n")
  putStr("  greedy\n")
  putStr("  random\n")
  exitSuccess
