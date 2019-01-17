{- |
Module : ApocStrategyGreedy
Description : An Apocalypse strategy that selects moves based off a simple Greedy algorithm
Stability : experimental
Portability : ghc 7.10.2 - 7.10.3

A strategy that selects moves based off a greedy algorithm.
-}

module ApocStrategyGreedy where

import AIHelper
import ApocTools
import ApocStrategyHuman
import System.Random

-- | Selects a move based off a Greedy algorithm for the given player
greedy :: Chooser
greedy gameState playType player = if (playType == PawnPlacement)
                                   then pawnForGreedy (theBoard gameState) player
                                   else normalForGreedy (theBoard gameState) player

{- | Picks a random number if the number if greater than 95 pass on move else determine what move to make, if a knight can be killed then kill the knight,
  otherwise if a pawn can be killed kill the pawn otherwise just move a random pawn forward
  
-}
normalForGreedy :: Board -> Player -> IO (Maybe [(Int,Int)])
normalForGreedy board player =
  if ((length(listAllMoves board player (findOwnPieces board player (0,0)))) == 0)
  then return Nothing
  else do
    randomNumber <- randomRIO (0,100) :: IO Int
    if (randomNumber > 95)
    then return Nothing
    else if ((containsKnightKill board player (listAllMoves board player (findOwnPieces board player (0,0)))) == [((-1),(-1))])
         then if (containsPawnKill board player (listAllMoves board player (findOwnPieces board player (0,0))) == [((-1),(-1))])
              then pick (convert (listAllMoves board player (findOwnPieces board player (0,0))))
              else pick (convert (getAllPawnKills board player (listAllMoves board player (findOwnPieces board player (0,0)))))
         else pick (convert (getAllKnightKills board player (listAllMoves board player (findOwnPieces board player (0,0)))))

{- | Places a pawn on the first empty square on the board from the player's side.
-}
pawnForGreedy :: Board ->Player -> IO (Maybe [(Int,Int)])
pawnForGreedy board player = return $ Just ([listPawnPlacements board player])