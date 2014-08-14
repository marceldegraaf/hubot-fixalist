# Description:
#   Return a rondo PNG
#
# Dependencies:
#   None
#
# Commands:
#   rondo, rondoge
#
# Author:
#   wouter

module.exports = (robot) ->
  robot.hear /\brondo\b/i, (msg) ->
    msg.send "http://i.imgur.com/dxW7tn1.png"

  robot.hear /\brondoge\b/i, (msg) ->
    msg.send "http://i.imgur.com/WwbTOjk.png"
