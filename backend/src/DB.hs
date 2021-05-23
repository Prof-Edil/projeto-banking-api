{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE StandaloneDeriving         #-}
{-# LANGUAGE TypeOperators              #-}
{-# LANGUAGE UndecidableInstances       #-}

module DB where

import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader
import Data.Aeson
import Data.Aeson.TH
import Data.Int ( Int64 )
import Database.Persist.Sql
import Database.Persist.Postgresql
    ( withPostgresqlConn, ConnectionString )

import qualified Data.Text as T
import qualified Database.Persist.TH as PTH

PTH.share [PTH.mkPersist PTH.sqlSettings, PTH.mkMigrate "migrateAll"] [PTH.persistLowerCase|
  User sql=users
    name T.Text
    email T.Text
    balance Int
    UniqueEmail email
    deriving Show
|]

$(deriveJSON defaultOptions ''User)

connString :: ConnectionString
connString = "host=127.0.0.1 port=5432 user=postgres dbname=postgres password=password"

migrateDB :: IO ()
migrateDB = runAction connString (runMigration migrateAll)

fetchUserPG :: ConnectionString -> Int64 -> IO (Maybe User)
fetchUserPG connString uid = runAction connString (get (toSqlKey uid))

createUserPG :: ConnectionString -> User -> IO Int64
-- createUserPG connString user = fromSqlKey <$> runAction connString (insert user)
createUserPG connString user = do
  userId <- runAction connString (insert user)
  pure $ fromSqlKey userId

updateUserPG :: ConnectionString -> User -> Int64 -> IO ()
updateUserPG connString user userId =
  runAction connString (replace (toSqlKey userId) user)

-- runAction :: ConnectionString -> SqlPersistT a -> IO a
runAction connectionString action = runStdoutLoggingT $ withPostgresqlConn connectionString $ \backend ->
  runReaderT action backend