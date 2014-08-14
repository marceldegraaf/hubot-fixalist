# Description:
#   Return the "coo man, coo" pigeon
#
# Dependencies:
#   None
#
# Commands:
#   coo - return the "coo man, coo" pigeon
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /\bcoo\b/i, (msg) ->
    msg.send "http://i.imgur.com/10P6guT.jpg"
