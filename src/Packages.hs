module Packages
    ( install
    , processPackageList
    , getConfigsAndSnippets
    )
where

import           Config
import           Process
import           Logger
import           Data.Maybe
import           Debug.Trace
import           Data.List
import           Control.Monad
import           Control.Monad.Reader
import qualified Installer
import           Registry                       ( registryLookup
                                                , registryMember
                                                , Package(..)
                                                , PackageConfig(..)
                                                , Snippet(..)
                                                , centralRegistry
                                                , Registry
                                                )

stringSources =
    [ "git"
    , "stack"
    , "jq"
    , "oh-my-zsh"
    , "brittany"
    , "prettier"
    , "hidden-dock"
    , "tmuxinator"
    , "neovim"
    , "elm"
    , "elm-format"
    , "elm-test"
    , "autojump"
    , "cloc"
    , "tmux"
    , "the_silver_searcher"
    , "vim-plug"
    , "zsh"
    , "powerlevel9k"
    , "powerline-fonts"
    , "iTerm2-color-schemes"
    ]


unpackSources registry sourceList = registryLookup registry <$> sourceList

expandDependenciesList packages =
    (nubBy (\x y -> name x == name y))
        . (concatMap expandDependencies)
        $ packages
  where
    expandDependencies package = case (dependencies package) of
        [] -> [package]
        xs -> expandDependenciesList xs <> [package]

isMissing registry = not . registryMember registry

processPackageList :: Registry -> [String] -> [Package]
processPackageList registry packageList =
    expandDependenciesList
        . catMaybes
        . (unpackSources registry)
        . nub
        $ packageList


getConfigsAndSnippets :: [Package] -> [(PackageConfig, [Snippet])]
getConfigsAndSnippets packages = fmap associateWithSnippets packageConfigs
  where
    associateWithSnippets packageConfig =
        (packageConfig, snippetsFor packageConfig)
    snippetsFor packageConfig =
        filter (snippetIsForConfig packageConfig) allSnippets
    snippetIsForConfig packageConfig (Snippet snippetConfig _) =
        packageConfig == snippetConfig
    allSnippets :: [Snippet]
    allSnippets = concatMap snippets packages
    packageConfigs :: [PackageConfig]
    packageConfigs = catMaybes . (fmap config) $ packages


resetDirectory dir = do
    runProcess ("rm -rf " <> dir)
    runProcess ("mkdir -p " <> dir)

install = do
    Config { rebuildConfigsOnly, installationsDir, buildDir, binDir, builtConfigsDir } <-
        ask
    when (not . null $ missingPackages)
        $ logError ("MISSING REGISTRY PACKAGES: " <> show missingPackages)

    resetDirectory builtConfigsDir
    (mapM_ Installer.installConfig) . getConfigsAndSnippets $ packagesToInstall

    unless rebuildConfigsOnly $ do
        mapM_ resetDirectory           [installationsDir, buildDir, binDir]
        mapM_ Installer.installPackage packagesToInstall
  where
    packagesToInstall = processPackageList centralRegistry stringSources
    missingPackages =
        (filter $ isMissing centralRegistry) . nub $ stringSources