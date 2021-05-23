{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE UndecidableInstances       #-}

module User where

import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader ( MonadIO(liftIO) )
import Data.Int ( Int64 )
import Database.Persist.Postgresql
import Servant
import DB
import Utils


fetchUserHandler :: ConnectionString -> Int64 -> Handler User
fetchUserHandler connString uid =
  liftIO (fetchUserPG connString uid)
    >>= liftMaybe err404 { errBody = "User not found" }

createUserHandler :: ConnectionString -> User -> Handler Int64
createUserHandler connString user = liftIO $ createUserPG connString user

updateUserHandler :: ConnectionString -> User -> Int64 -> Handler ()
updateUserHandler connString user userId = liftIO $ updateUserPG connString user userId