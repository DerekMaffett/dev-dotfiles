module Installer
    ( installPackage
    , installConfig
    )
where

import           Logger
import           Process
import           Config
import           Control.Monad.Reader
import           System.Directory
import           Symlinks
import           Registry                       ( Package(..)
                                                , Source(..)
                                                , PackageConfig(..)
                                                , SymlinkTarget(..)
                                                , GitAddress(..)
                                                , ZshPluginType(..)
                                                , toString
                                                )


zshInstall pluginType gitAddress = do
    Config { installationsDir } <- ask
    _githubInstall (packagePath installationsDir) gitAddress
  where
    packagePath installationsDir =
        installationsDir
            <> "/robbyrussell/oh-my-zsh/custom/"
            <> pluginLocation
            <> "/"
            <> (name :: GitAddress -> String) gitAddress
    pluginLocation = case pluginType of
        Theme  -> "themes"
        Plugin -> "plugins"

githubInstall gitAddress = do
    Config { installationsDir } <- ask
    _githubInstall (installationsDir <> "/" <> toString gitAddress) gitAddress

_githubInstall targetPath gitAddress = runProcess'
    (  "git clone --single-branch --branch "
    <> (branch :: GitAddress -> String) gitAddress
    <> " git@github.com:"
    <> toString gitAddress
    <> ".git "
    <> targetPath
    )

stackInstall name = runProcess' ("stack install " <> name)

pip3Install name = runProcess' ("pip3 install --user " <> name)

gemInstall name =
    runProcess' ("eval \"$(rbenv init -)\" && gem install " <> name)

npmInstall name =
    runProcess' ("source ~/.nvm/nvm.sh && npm install -g " <> name)

brewInstall name = do
    isUninstalled <- checkIfInstalled <$> runProcess "brew list"
    runProcess' ("brew install " <> name)
    where checkIfInstalled name = (\installed -> name `elem` installed) . words

installFromSource source = case source of
    Python name               -> pip3Install name
    Ruby   name               -> gemInstall name
    Stack  name               -> stackInstall name
    Npm    name               -> npmInstall name
    Brew   name               -> brewInstall name
    Github gitAddress         -> githubInstall gitAddress
    Zsh pluginType gitAddress -> zshInstall pluginType gitAddress
    Custom installationMethod -> installationMethod
    Batch  sources            -> mapM_ installFromSource sources

installPackage Package { name, source } = do
    logNotice $ "Installing " <> name <> "..."
    installFromSource source

installConfig :: PackageConfig -> ReaderT Config IO ()
installConfig (PackageConfig name symlinkTarget) = do
    Config { homeDir, configsDir, builtConfigsDir } <- ask
    configExists <- liftIO $ doesPathExist (configsDir <> "/" <> name)
    unless configExists $ logError (name <> " does not exist!")
    liftIO $ copyFile (configsDir <> "/" <> name)
                      (builtConfigsDir <> "/" <> name)
    createSymlink (builtConfigsDir <> "/" <> name)
                  (getTarget homeDir name symlinkTarget)
  where
    getTarget homeDir name symlinkTarget = case symlinkTarget of
        Home -> homeDir <> "/" <> name
