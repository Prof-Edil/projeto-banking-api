module Main where

import API (startApp)
import DB (migrateDB)

main :: IO ()
main = migrateDB >> startApp

