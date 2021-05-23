{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE TypeOperators              #-}
{-# LANGUAGE UndecidableInstances       #-}

module API (startApp) where

import Data.Int ( Int64 )
import Database.Persist.Postgresql
import Network.Wai
import Network.Wai.Handler.Warp
import Servant

import qualified Data.Text as T
import qualified Database.Persist.TH as PTH

import User
import DB
import Transfer
import Deposit
import Withdrawal

-- endpoints:
-- GET  /users/:userId    -- get user by id
-- POST /users/           -- create user
-- POST /deposit/         -- deposits
-- POST /withdraw/        -- withdrawals
-- POST /transfer/        -- transfer
type API =
       "users"    :> Capture "userId" Int64     :> Get '[JSON] User
  :<|> "users"    :> ReqBody '[JSON] User       :> Post '[JSON] Int64
  :<|> "deposit"  :> ReqBody '[JSON] Deposit    :> Post '[JSON] ()
  :<|> "withdraw" :> ReqBody '[JSON] Withdrawal :> Post '[JSON] ()
  :<|> "transfer" :> ReqBody '[JSON] Transfer   :> Post '[JSON] ()

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve api (server connString)

api :: Proxy API
api = Proxy

server :: ConnectionString -> Server API
server pgInfo =
  fetchUserHandler pgInfo
  :<|> createUserHandler pgInfo
  :<|> depositHandler pgInfo
  :<|> withdrawHandler pgInfo
  :<|> transferHandler pgInfo