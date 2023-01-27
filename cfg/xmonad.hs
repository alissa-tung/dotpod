module Main (main) where

import XMonad
import XMonad.Hooks.DynamicLog (xmobarProp)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)

main :: IO ()
main = do
  xmonad
    $ xmobarProp
      . ewmhFullscreen
      . ewmh
    $ def
      { terminal = "kitty",
        modMask = mod4Mask,
        focusedBorderColor = "#6750A4",
        startupHook = do
          spawn "feh --bg-fill --no-fehbg ~/.config/background-image.jpg"
          pure ()
      }
