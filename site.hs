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
        compile copyFileCompiler
        --compile compressCssCompiler

    match "**.markdown" $ version "metadata" $ do
        route $ setExtension "html"
        compile $ pandocCompiler

    match "**.markdown" $ do
        route $ setExtension "html"
        compile $ do
            posts <- loadAll ("**.markdown" .&&. hasVersion "metadata")
            id <- getUnderlying

            let menuCtx = listField "posts" (defaultContext `mappend`
                                             field "menu-class" (\item -> return $ if id == (setVersion Nothing $ itemIdentifier item)
                                                                                   then "selected-menu" else "menu"))
                                            (return posts)

            let postCtx = menuCtx                   `mappend`
                          defaultContext            `mappend`
                          constField "title" "Home" `mappend`
                          constField "image" "/images/vass.jpg"

            pandocCompiler >>= loadAndApplyTemplate "templates/default.html" postCtx
                           >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


