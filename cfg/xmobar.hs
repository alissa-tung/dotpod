module Main (main) where

import Xmobar

main :: IO ()
main = do
  xmobar $
    defaultConfig
      { commands =
          [ Run $ Date "%a %b %_d %Y * %H:%M:%S" "theDate" 10,
            Run XMonadLog
          ],
        template =
          "%XMonadLog% }{ "
            ++ "<fc=#00FF00>%uname%</fc> * <fc=#FF0000>%theDate%</fc>"
      }
