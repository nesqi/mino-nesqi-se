--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Data.Maybe
import           Data.Functor
import           Data.Map as M
import           Hakyll

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "**.markdown" $ version "metadata" $ do
        route $ setExtension "html"
        compile $ pandocCompiler

    match "**.markdown" $ do
        route $ setExtension "html"
        compile $ do
            posts <- loadAll ("**.markdown" .&&. hasVersion "metadata")

            let postCtx = listField "posts" defaultContext (return posts) `mappend`
                          constField "title" "Home"                `mappend`
                          defaultContext

            pandocCompiler >>= loadAndApplyTemplate "templates/default.html" postCtx
                           >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

