module Projects
    ( clone
    )
where

import qualified System.Directory              as Dir
import           System.Process                 ( callCommand )
import           Control.Monad
repos =
    [ "git@github.com:DerekMaffett/react-elm"
    , "git@github.com:DerekMaffett/river"
    , "git@bitbucket.org:DerekMaffett/river-bitbucket-test"
    , "git@github.com:DerekMaffett/river-github-test"
    ]

cloneProject projectsDir repo = do
    repoExists <-
        Dir.doesPathExist $ projectsDir <> "/" <> (dropWhile (/= '/') repo)
    unless repoExists (callCommand $ "git clone " <> repo <> ".git")

clone forceRemove = do
    projectsDir <- getProjectsDir
    when forceRemove $ Dir.removePathForcibly projectsDir
    Dir.createDirectoryIfMissing True projectsDir
    Dir.withCurrentDirectory projectsDir
        $ mapM_ (cloneProject projectsDir) repos
  where
    getProjectsDir = do
        homeDir <- Dir.getHomeDirectory
        return $ homeDir <> "/projects"
