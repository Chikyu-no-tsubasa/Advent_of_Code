-- https://adventofcode.com/2024/day/10
-- To run it, use the command: runghc Day10_2.hs < input.txt

{-# LANGUAGE BangPatterns #-}

import Data.Array (Array, array, listArray, (!), bounds, inRange, range)

type Pos  = (Int, Int)   -- (row, col)
type Grid = Array Pos Int

main :: IO ()
main = do
  input <- getContents
  let ls = filter (not . null) (lines input)
      g  = parseGrid ls
      b  = bounds g

      -- Part 2: number of distinct trails from each 0 to any 9
      ways :: Array Pos Integer
      ways = array b
        [ (p, trailsFrom p)
        | p <- range b
        ]

      trailsFrom :: Pos -> Integer
      trailsFrom p =
        let h = g ! p
        in if h == 9
           then 1
           else sum
                [ ways ! n
                | n <- neighbors4 p
                , inRange b n
                , g ! n == h + 1
                ]

      trailheads = [ p | p <- range b, g ! p == 0 ]
      total = sum [ ways ! p | p <- trailheads ]

  print total

parseGrid :: [String] -> Grid
parseGrid [] = listArray ((0,0),(-1,-1)) []  -- empty grid case
parseGrid ls =
  let h = length ls
      w = length (head ls)
      vals = [ fromEnum ch - fromEnum '0' | row <- ls, ch <- row ]
  in listArray ((0,0),(h-1,w-1)) vals

neighbors4 :: Pos -> [Pos]
neighbors4 (r,c) = [(r-1,c),(r+1,c),(r,c-1),(r,c+1)]
