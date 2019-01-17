{- |
Module      : ApocStrategyHuman
Description : Template for a game-playing strategy definition.
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

A strategy wherein a human player is prompted for possible moves.
-}

module ApocStrategyHuman where

import ApocTools
import Data.Char

{- | This is just a placeholder for the human strategy: it always chooses to play
     (0,0) to (2,1).
-}
human :: Chooser
human b n c = do -- Chooser = GameState -> PlayType -> Player
    putStr("Enter the move coordinates for player " ++ (if c == Black then "B" else "W") ++ (if n == Normal then "1" else "2") ++ ":\n")
    inp <- getLine -- pawnplace/normal-> 	Black / White
    if (n == Normal)
    then if (inp == "")
        then return Nothing
        else if length(readMove inp) == 4 && ((checkMove (theBoard b) (head (listToTuple (readMove inp))) (head (tail (listToTuple (readMove inp)))) c) /= "Illegal")-- && (checkCorrectPlayer)
             then do
               return (Just(listToTuple(readMove inp)))
             else do
               putStrLn("Illegal move: try again")
               human b Normal c
    else if length(readMove inp) == 2 && ((checkPawnPlacement (theBoard b) (head (listToTuple (readMove inp)))) /= "Illegal")
        then do
            return (Just(listToTuple(readMove inp)))
        else if (inp == "")
                then do
                    return Nothing
                else do 
                    putStrLn("Illegal move: try again")
                    human b PawnPlacement c

{- |Helper for readMove
     Takes a string and tells you if it's a number
     Considers empty strings to be "numbers"
-}
isNumber' :: [Char] -> Bool
isNumber' [] = True
isNumber' xs
 | (isDigit (head xs)) = isNumber' (tail xs)
 | otherwise = False
 
{- |Helper for readMove
       Takes a list of strings that can either be parsed as numbers ("1234") or not e.g. ("--comment", "123b4")
       and returns a list of only the numbers as integers
 -}
getNumbers :: [String] -> [Int]
getNumbers [] = []
getNumbers (x:xs)
 | (isNumber' x) = [(read x :: Int)]  ++ getNumbers xs
 | otherwise = []
 
{- |Read the move from the user input string
       Returns a list of integers that will be used to formulate the move
 -}
readMove :: String -> [Int]
readMove "" = []
readMove xs = getNumbers(words xs)

{- | Takes the user's MOVE input (String) and outputs the user's move input as an array of integers of length 4 (4 coordinates)

readMove1 :: String -> [Int]
readMove1 "" = []
readMove1 xs = map read(take 4(words xs)) :: [Int]
-]

{- | Takes the user's PAWN PLACEMENT input (String) and outputs the user's move input as an array of integers of length 4 (4 coordinates)
-}
readMovePawn :: String -> [Int]
readMovePawn "" = []
readMovePawn xs = map read(take 2(words xs)) :: [Int]
-}

{- | Takes the user's MOVE/PAWN PLACEMENT input ([Int]) and outputs whether or not the coordinates are on the game board (0..4)
-}
checkRange :: [Int] -> Bool
checkRange [] = True
checkRange (x:xs) = if (x>4) || (x<0) then False else checkRange xs

{- | For a given user move input, this function checks the following (in order):
        1. All coordinates are within 0..4 (all coordinates are on the game board)
        2. Given origin coordinates don't point to an empty cell (player trying to move an empty cell)
        3. A player is moving their own piece
        4. If the origin coordinates are pointing to a PAWN or a KNIGHT
        5. Calls the move-checking function or PAWN (movePawn) or KNIGHT (moveKnight)
     checkMove will return True if the passed user input passes all of the above checks
-}
checkMove :: [[Cell]] -> (Int,Int) -> (Int,Int) -> Player -> String
checkMove board origin move player = do
  if (checkRange ([(fst(origin)),(snd(origin)),(fst(move)),(snd(move))]))
  then if (checkCorrectPlayer board origin player)
       then if ((getFromBoard board origin == BP) || ((getFromBoard board origin == WP)))
            then if (movePawn board origin move)
                 then "Legal"
                 else "Goofed"
            else if ((getFromBoard board origin == BK) || ((getFromBoard board origin == WK)))
                 then if (moveKnight board origin move)
                      then "Legal"
                      else "Goofed"
                 else "Goofed" -- Origin coordinates point to an empty cell
       else "Goofed" -- Player trying to move other player's piece
  else "Illegal" -- Given coordinates are outside 0..4

{- | Determines if user's input to place a pawn anywhere on the board
       points to an empty cell
  -}
checkPawnPlacement :: [[Cell]] -> (Int,Int) -> String
checkPawnPlacement board a = do
  if (checkRange ([fst(a),snd(a)]))
  then if ((getFromBoard board a) == E)
       then "Legal"
       else "Goofed"
  else "Illegal"

{- | Takes an integer list ([Int]) and outputs a list of tuples using the elements in the parameter
-}
listToTuple :: [Int] -> [(Int, Int)]
listToTuple [] = []
listToTuple (x:y:zs) = (x,y) : listToTuple zs

{- | Checks that a player (Black/White) is moving its own piece
-}
checkCorrectPlayer :: [[Cell]] -> (Int, Int) -> Player -> Bool
checkCorrectPlayer b t p
 | ((getFromBoard b t) == WK) && (p == White) = True
 | ((getFromBoard b t) == WP) && (p == White) = True

 | ((getFromBoard b t) == BK) && (p == Black) = True
 | ((getFromBoard b t) == BP) && (p == Black) = True

 | otherwise = False

{- | Given a knight's origin coordinates, outputs all possible moves that knight could make on the board
      Does not check for empty cells on board
-}
checkKnight :: (Int,Int) -> [(Int,Int)]
checkKnight (a,b) = filter legalPlace
  [(a+2,b-1),(a+2,b+1),(a-2,b-1),(a-2,b+1)
  ,(a+1,b-2),(a+1,b+2),(a-1,b-2),(a-1,b+2)
  ]
  where legalPlace (a,b) = a `elem` [0..4] && b `elem` [0..4]

{- | Determines if user's input to move a knight is a legal knight moveKnight
       Does not check if it's moving onto an empty cell or not
       Assumes that move coordinates are within game board bounds
-}
moveKnight :: [[Cell]] -> (Int,Int) -> (Int,Int) -> Bool
moveKnight a b c
  | ((getFromBoard a b == BK) && (c `elem` (checkKnight b))) = True
  | ((getFromBoard a b == WK) && (c `elem` (checkKnight b))) = True
  | otherwise = False

{- | Determines if user's input to move a pawn one cell forward
       Does not check if it's moving onto an empty cell or not
       Assumes that move coordinates are within game board bounds
-}
movePawn :: [[Cell]] -> (Int, Int) -> (Int, Int) -> Bool
movePawn board a b
  -- Check if player is legally moving a pawn forward onto an empty space
  | ((((getFromBoard board a) == BP) && (snd(b) == ((snd(a))-1))) && (fst(b) == (fst(a))) && ((getFromBoard board b) == E)) = True
  | ((((getFromBoard board a) == WP) && (snd(b) == ((snd(a))+1))) && (fst(b) == (fst(a))) && ((getFromBoard board b) == E)) = True

  -- Check if player is legally moving a pawn diagonally to kill a piece of the  opposing player
  | ((((getFromBoard board a) == BP) && ((fst(b) == (fst(a)-1)) || (fst(b) == (fst(a)+1)) && (snd(b) == (snd(a)-1)))) && (((getFromBoard board b) == WP) || ((getFromBoard board b) == WK))) = True
  | ((((getFromBoard board a) == WP) && ((fst(b) == (fst(a)-1)) || (fst(b) == (fst(a)+1)) && (snd(b) == (snd(a)+1)))) && (((getFromBoard board b) == BP) || ((getFromBoard board b) == BK))) = True

  -- Otherwise the move is "Goofed"
  | otherwise = False
