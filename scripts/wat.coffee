# Description:
#   Return a wut photo
#
# Dependencies:
#   None
#
# Commands:
#   wut, wu(t*) - return a wut photo
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /\bwu(t+)\b/i, (msg) ->
    images = [
      "http://i.imgur.com/rUCjXC5.jpg",
      "http://i.imgur.com/PxxqLbR.jpg",
      "http://i.imgur.com/CSXDd6y.jpg"
    ]

    msg.send images[Math.floor(Math.random() * images.length)]
