{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE UndecidableInstances       #-}

module Utils where

import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Except ( MonadError(throwError) )
import Servant ( Handler, ServerError )

import qualified Data.Text as T
import qualified Database.Persist.TH as PTH

liftMaybe :: ServerError -> Maybe a -> Handler a
liftMaybe err Nothing = throwError err
liftMaybe _ (Just x) = pure x