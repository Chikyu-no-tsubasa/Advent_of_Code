-- https://adventofcode.com/2024/day/10
-- To run it, use the command: runghc Day10_1.hs < input.txt

{-# LANGUAGE BangPatterns #-}

import qualified Data.Set as S
import qualified Data.Sequence as Q
import Data.Sequence (Seq((:<|)), (|>))
import Data.Array (Array, listArray, (!), bounds, inRange)

type Pos = (Int, Int) -- (row, col)
type Grid = Array Pos Int

main :: IO ()
main = do
  input <- getContents
  let ls = filter (not . null) (lines input)
      grid = parseGrid ls
      ((r0,c0),(r1,c1)) = bounds grid

      trailheads =
        [ (r,c)
        | r <- [r0..r1]
        , c <- [c0..c1]
        , grid ! (r,c) == 0
        ]

      total = sum [ scoreTrailhead grid p | p <- trailheads ]

  print total

parseGrid :: [String] -> Grid
parseGrid ls =
  let h = length ls
      w = if h == 0 then 0 else length (head ls)
      vals = [ fromEnum ch - fromEnum '0' | row <- ls, ch <- row ]
  in listArray ((0,0),(h-1,w-1)) vals

neighbors4 :: Pos -> [Pos]
neighbors4 (r,c) = [(r-1,c),(r+1,c),(r,c-1),(r,c+1)]

scoreTrailhead :: Grid -> Pos -> Int
scoreTrailhead g start =
  let bnds = bounds g

      go :: S.Set Pos -> S.Set Pos -> Q.Seq Pos -> Int
      go !visited !peaks q =
        case q of
          Q.Empty -> S.size peaks
          (p :<| qrest) ->
            let curH   = g ! p
                peaks' = if curH == 9 then S.insert p peaks else peaks

                nexts =
                  if curH == 9 then []
                  else
                    [ n
                    | n <- neighbors4 p
                    , inRange bnds n
                    , g ! n == curH + 1
                    , not (S.member n visited)
                    ]

                visited' = foldr S.insert visited nexts
                q' = foldl (|>) qrest nexts
            in go visited' peaks' q'
  in go (S.singleton start) S.empty (Q.singleton start)
