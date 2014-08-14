# Description:
#   Return Tormund Giantsbane saying HAR
#
# Dependencies:
#   None
#
# Commands:
#   har
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /\b^har har\b/i, (msg) ->
    msg.send "http://i.imgur.com/7SCz4F6.jpg"
