# Description:
#   Return a doge image
#
# Dependencies:
#   None
#
# Commands:
#   much / such *
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /\b^much (.*)\b/i, (msg) ->
    text = msg.match[1].replace(/,/g, "/").replace(/\s+/g, "")
    msg.send "http://i.imgur.com/TsnEMau.jpg"

  robot.hear /\b^such (.*)\b/i, (msg) ->
    text = msg.match[1].replace(/,/g, "/").replace(/\s+/g, "")
    msg.send "http://i.imgur.com/TsnEMau.jpg"
