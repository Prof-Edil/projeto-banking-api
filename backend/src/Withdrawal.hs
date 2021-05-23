{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE UndecidableInstances       #-}

module Withdrawal where

import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader ( MonadIO(liftIO) )
import Control.Monad.Except
    ( MonadError(throwError), MonadIO(liftIO) )
import Data.Int ( Int64 )
import Database.Persist.Postgresql ( ConnectionString )
import Servant
    ( throwError, err403, err404, Handler, ServerError(errBody) )

import qualified Data.Text as T
import qualified Database.Persist.TH as PTH

import DB
import Utils 
import User
import Operation

type Withdrawal = Operation

withdrawHandler :: ConnectionString -> Withdrawal -> Handler ()
withdrawHandler connString (Operation userId value ) = do
  user <- liftIO (fetchUserPG connString userId) >>= liftMaybe err404
  if userBalance user < value
     then throwError err403 { errBody = "Insufficient balance" }
     else let user' = user { userBalance = userBalance user - value }
          in updateUserHandler connString user' userId