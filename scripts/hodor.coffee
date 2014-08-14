# Description:
#   Return a random image of Hodor
#
# Dependencies:
#   None
#
# Commands:
#   hodor - return a random Hodor image from Google Images
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    hodorImage msg, (url) ->
      msg.send url

hodorImage = (msg, callback) ->
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(v: "1.0", rsz: '8', q: "hodor")
    .get() (err, res, body) ->
      images = JSON.parse(body)
      if images && images.responseData
        images = images.responseData.results
        image  = msg.random images
        callback "#{image.unescapedUrl}#.png"
      else
        callback "Oops, something went wrong!"
