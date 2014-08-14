# Description:
#   Return a Clay Davis "sheeeeeeit" GIF
#
# Dependencies:
#   None
#
# Commands:
#   shiiit - return a Clay Davis "sheeeeeit" GIF
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /shiiii*t/i, (msg) ->
    msg.send "http://i.imgur.com/47YmPEo.gif"
