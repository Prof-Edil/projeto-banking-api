{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE UndecidableInstances       #-}

module Deposit where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader ( MonadIO(liftIO) )
import Database.Persist.Postgresql ( ConnectionString )
import Servant ( err404, Handler, ServerError(errBody) )

import qualified Data.Text as T
import qualified Database.Persist.TH as PTH

import DB
import Utils 
import User
import Operation

type Deposit = Operation

depositHandler :: ConnectionString -> Deposit -> Handler ()
depositHandler connString (Operation userId value ) = do
  user <- liftIO (fetchUserPG connString userId)
          >>= liftMaybe err404 { errBody = "User ID not found" }
  let user' = user { userBalance = userBalance user + value }
  updateUserHandler connString user' userId