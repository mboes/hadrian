{-# LANGUAGE NoImplicitPrelude #-}
module Rules (
    generateTargets, packageRules,
    module Rules.Package,
    ) where

import Base hiding (arg, args, Args)
import Control.Monad
import Targets
import Package
import Expression
import Rules.Package
import Settings.Packages

-- generateTargets needs package-data.mk files of all target packages
-- TODO: make interpretDiff total
generateTargets :: Rules ()
generateTargets = action $
    forM_ [Stage0 ..] $ \stage -> do
        let env = defaultEnvironment { getStage = stage }
        pkgs <- interpretDiff env packages
        forM_ pkgs $ \pkg -> do
            let dir = targetDirectory stage pkg
            need [pkgPath pkg </> dir </> "package-data.mk"]

-- TODO: add Stage2 (compiler only?)
packageRules :: Rules ()
packageRules =
    forM_ [Stage0, Stage1] $ \stage -> do
        forM_ knownPackages $ \pkg -> do
            let env = defaultEnvironment { getStage = stage, getPackage = pkg }
            buildPackage env
