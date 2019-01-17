{- |
Module      : ApocStrategyRandom
Description : An Apocalypse strategy that plays moves at random.
Stability     : experimental
Portability  : ghc 7.10.2 - 7.10.3

Returns valid moves at random from all the possible moves that player can make.
Returns nothing if the player cannot make a valid move.
-}

module ApocStrategyRandom where

import AIHelper
import ApocTools
import System.Random

{- | Plays a strategy at random.
Takes in the game state, a play type, and the player, and returns a valid, random move
-}
random :: Chooser
random s n p = if (n == PawnPlacement) then pawnForRandom (theBoard s) p else normalForRandom (theBoard s) p

{- | Plays a Normal move at random
Takes in a board and a player, and returns a move at random that is valid for that player
-}
normalForRandom:: Board -> Player -> IO (Maybe [(Int,Int)])
normalForRandom board player = if length((listAllMoves board player (findOwnPieces board player (0,0)))) == 0 then return Nothing else pick (convert (listAllMoves board player (findOwnPieces board player (0,0))))

{- | Plays a Pawn Placement move at random
Takes in a board and a player, and returns a valid Pawn Placement move (sequential, not random)
-}
pawnForRandom :: Board ->Player -> IO (Maybe [(Int,Int)])
pawnForRandom board player = return $ Just ([listPawnPlacements board player])