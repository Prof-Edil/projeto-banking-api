{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE UndecidableInstances       #-}

module Transfer where

import Data.Aeson ( defaultOptions )
import Data.Aeson.TH ( deriveJSON )
import Data.Int ( Int64 )
import Servant ( throwError, err403, Handler, ServerError(errBody) )
import Database.Persist.Postgresql ( ConnectionString )

import DB
import Utils 
import User

data Transfer =
  Transfer { fromId :: Int64, toId :: Int64, transferAmount :: Int }

$(deriveJSON defaultOptions ''Transfer)

transferHandler :: ConnectionString -> Transfer -> Handler ()
transferHandler connString (Transfer fromId toId value) = do
  user1 <- fetchUserHandler connString fromId
  user2 <- fetchUserHandler connString toId
  if userBalance user1 < value
    then throwError err403 { errBody = "Insufficient balance" }
    else do
      let user1' = user1 { userBalance = userBalance user1 - value }
          user2' = user2 { userBalance = userBalance user2 + value }
      updateUserHandler connString user1' fromId
      updateUserHandler connString user2' toId