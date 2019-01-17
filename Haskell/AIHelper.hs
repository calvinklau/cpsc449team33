{- |
Module      : AIHelper
Description : Various helper functions for the AI strategies
Stability   : experimental
Portability : ghc 7.10.2 - 7.10.3

Various helper functions for the AI players.

-}
module AIHelper where

import ApocTools
import System.Random

{- | Takes a list of tuples and converts it to a list of moves (in the form of lists of pairs of tuples [[(Int,Int),(Int,Int)]])
-}
convert :: [(Int,Int)] -> [[(Int,Int)]]
convert [] = []
convert (x:y:xs) = [[x,y]] ++ convert xs

{- | Takes a list of moves and picks one at random
-}
pick :: [[(Int,Int)]] -> IO (Maybe [(Int,Int)])
pick xss = do
                 rand <- randomRIO (0, ((length xss) -1))
                 return (Just (xss !! rand))

{- |Sequentially lists every possible move that a player can make.
-}
listAllMoves :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
listAllMoves _ _ [] = []
listAllMoves board player (x:xs) = (listAllMoves' x (listMoves board player x)) ++ listAllMoves board player xs

{- | Helper for list all moves. Takes every possible destination and adds the source before it in the list
-}
listAllMoves' :: (Int,Int) -> [(Int,Int)] -> [(Int,Int)]
listAllMoves' _ [] = []
listAllMoves' x (y:ys) = [x,y] ++ listAllMoves' x ys

{- | Given a pieces's origin coordinates, return a list of tuples that represent all possible moves that piece may take
-}
listMoves :: [[Cell]] -> Player -> (Int,Int) -> [(Int,Int)]
listMoves board player (a,b)
  | (((getFromBoard board (a,b)) == WK) || ((getFromBoard board (a,b)) == BK)) = listKnightMoves board player (a,b)
  | ((getFromBoard board (a,b)) == BP) = listBlackPawnMoves board player (a,b)
  | otherwise = listWhitePawnMoves board player (a,b)

{- | Given a list of a piece's possible moves, return a list of tuples that represent all possible pieces that could be killed
-}
listPossibleKills :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
listPossibleKills _ _ [] = []
listPossibleKills board player (x:xs) = do
  -- Check if a possible move is moving onto an empty cell "E"
  if (getFromBoard board (fst(x),snd(x)) == E)
       -- If so, it is not a kill move -> Move onto next coordinate in the passed list
  then listPossibleKills board player xs
       -- Else, add kill move coordinates to list that will be returned, and move onto next coordinate in the passed list
  else [x] ++ listPossibleKills board player xs

{- | Given a coordinate and player, determine if the piece at the given coordinate belongs to the opposing player
-}
verifyOtherPlayerPiece :: [[Cell]] -> Player -> (Int,Int) -> Bool
verifyOtherPlayerPiece board player (a,b)
  | (playerOf (pieceOf (getFromBoard board (a,b))) /= player) = True
  | otherwise = False

{- | Given a knight's origin coordinates, return a list of tuples that represent all possible moves that knight may take
-}
listKnightMoves :: [[Cell]] -> Player -> (Int,Int) -> [(Int,Int)]
listKnightMoves board player (a,b) = filter legalKnightMoves
         [(a+2,b-1),(a+2,b+1),(a-2,b-1),(a-2,b+1)
         ,(a+1,b-2),(a+1,b+2),(a-1,b-2),(a-1,b+2)]
                                       -- Filter out if either coordinate is out of bounds
        where legalKnightMoves (c,d) = (c `elem` [0..4] && d `elem` [0..4])
                                             -- Accept coordinates if knight is moving onto an empty cell "E"
                                          && (((getFromBoard board (c,d)) == E)
                                               -- OR knight is moving onto a cell that contains an opposing piece
                                               || (((getFromBoard board (c,d)) /= E) && (verifyOtherPlayerPiece board player (c,d))))

{- | Given a black pawn's origin coordinates, return a list of tuples that represent all possible moves that black pawn may take
-}
listBlackPawnMoves :: [[Cell]] -> Player -> (Int,Int) -> [(Int,Int)]
listBlackPawnMoves board player (a,b) = filter legalBlackPawnMoves
         [(a,b-1),(a-1,b-1),(a+1,b-1)]    -- Filter out if either coordinate is out of bounds
        where legalBlackPawnMoves (c,d) = (c `elem` [0..4] && d `elem` [0..4])
                                             -- Accept coordinates if cell in front of pawn is empty "E"
                                          && ((((c,d) == (a,b-1)) && ((getFromBoard board (c,d)) == E))
                                             -- Accept coordinates if cell that is left-diagonal to pawn is non-empty and contains an opposing piece
                                          || (((c,d) == (a-1,b-1) && ((getFromBoard board (c,d)) /= E) && (verifyOtherPlayerPiece board player (c,d))))
                                             -- Accept coordinates if cell that is right-diagonal to pawn is non-empty and contains an opposing piece
                                          || (((c,d) == (a+1,b-1) && ((getFromBoard board (c,d)) /= E) && (verifyOtherPlayerPiece board player (c,d)))))

{- | Given a white pawn's origin coordinates, return a list of tuples that represent all possible moves that white pawn may take
-}
listWhitePawnMoves :: [[Cell]] -> Player -> (Int,Int) -> [(Int,Int)]
listWhitePawnMoves board player (a,b) = filter legalWhitePawnMoves
         [(a,b+1),(a-1,b+1),(a+1,b+1)]    -- Filter out if either coordinate is out of bounds
        where legalWhitePawnMoves (c,d) = (c `elem` [0..4] && d `elem` [0..4])
                                             -- Accept coordinates if cell in front of pawn is empty "E"
                                          && ((((c,d) == (a,b+1)) && ((getFromBoard board (c,d)) == E))
                                             -- Accept coordinates if cell that is right-diagonal to pawn is non-empty and contains an opposing piece
                                          || (((c,d) == (a-1,b+1) && ((getFromBoard board (c,d)) /= E) && (verifyOtherPlayerPiece board player (c,d))))
                                             -- Accept coordinates if cell that is left-diagonal to pawn is non-empty and contains an opposing piece
                                          || (((c,d) == (a+1,b+1) && ((getFromBoard board (c,d)) /= E) && (verifyOtherPlayerPiece board player (c,d)))))

{- | List the first pawn placement move that a given player can make
-}
listPawnPlacements :: Board->  Player -> (Int,Int)
listPawnPlacements board player
  | player == Black = blackPawnPlacement 4 4 board
  | player == White = whitePawnPlacement 0 0 board

{- | Helper for listPawnPlacements
Lists the first pawn placement move that Black can make
-}
blackPawnPlacement :: Int -> Int -> Board  -> (Int,Int)
blackPawnPlacement x (-1) board = blackPawnPlacement x 4 board
blackPawnPlacement (-1) y board = blackPawnPlacement 4 (y-1) board
blackPawnPlacement x y board = if (getFromBoard board (x,y) == E) then (x,y) else blackPawnPlacement (x-1) y board

{- | Helper for listPawnPlacements
Lists the first pawn placement move that White can make
-}
whitePawnPlacement :: Int -> Int -> Board  -> (Int,Int)
whitePawnPlacement x (5) board = whitePawnPlacement x 0 board
whitePawnPlacement (5) y board = whitePawnPlacement 0 (y+1) board
whitePawnPlacement x y board = if (getFromBoard board (x,y) == E) then (x,y) else whitePawnPlacement (x+1) y board

{- | Given the list of all possible moves, finds out if there's a move that can kill a knight
-}
containsKnightKill :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
containsKnightKill _ _ [] = [((-1),(-1))]
containsKnightKill board player (x:y:zs) =
  if (((getFromBoard board y) == E) || ((getFromBoard board y) == BP) || ((getFromBoard board y) == WP))
  then containsKnightKill board player zs
  else if (verifyOtherPlayerPiece board player y)
       then [x,y]
       else containsKnightKill board player zs

{- | Returns a subset of the list of all possible moves, wherein only moves that can kill a knight are returned
-}
getAllKnightKills :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
getAllKnightKills _ _ [] = []
getAllKnightKills board player (x:y:zs) =
  if (((getFromBoard board y) == E) || ((getFromBoard board y) == BP) || ((getFromBoard board y) == WP))
  then getAllKnightKills board player zs
  else if (verifyOtherPlayerPiece board player y)
       then [(x),(y)] ++ getAllKnightKills board player zs
       else getAllKnightKills board player zs

{- | Given the list of all possible moves, finds out if there's a move that can kill a pawn
-}
containsPawnKill :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
containsPawnKill _ _ [] = [((-1),(-1))]
containsPawnKill board player (x:y:zs) =
  if (((getFromBoard board y) == E) || ((getFromBoard board y) == BK) || ((getFromBoard board y) == WK))
  then containsPawnKill board player zs
  else if (verifyOtherPlayerPiece board player y)
    then [x,y]
    else containsPawnKill board player zs

-- | Returns a subset of the list of all possible moves, wherein only moves that can kill a pawn are returned
getAllPawnKills :: [[Cell]] -> Player -> [(Int,Int)] -> [(Int,Int)]
getAllPawnKills _ _ [] = []
getAllPawnKills board player (x:y:zs) =
  if (((getFromBoard board y) == E) || ((getFromBoard board y) == BK) || ((getFromBoard board y) == WK))
  then getAllPawnKills board player zs
  else if (verifyOtherPlayerPiece board player y)
       then [(x),(y)] ++ getAllPawnKills board player zs
       else getAllPawnKills board player zs

-- | Returns a list of all the coordinates of the given player's pieces
findOwnPieces :: [[Cell]] -> Player -> (Int,Int) -> [(Int,Int)]
findOwnPieces board player (x,5) = []
findOwnPieces board player (5,y) = findOwnPieces board player (0,y+1)
findOwnPieces board player (x,y) =
  if ((((getFromBoard board (x,y)) == E) || (verifyOtherPlayerPiece board player (x,y)) == True))
  then findOwnPieces board player (x+1,y)
  else [(x,y)] ++ findOwnPieces board player (x+1,y)
