# Description:
#   Return a random image of the rapper Coolio
#
# Dependencies:
#   None
#
# Commands:
#   coolio - return a random Coolio image from Google Images
#
# Author:
#   marceldegraaf

module.exports = (robot) ->
  robot.hear /coolio/i, (msg) ->
    coolioImage msg, (url) ->
      msg.send url

coolioImage = (msg, callback) ->
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(v: "1.0", rsz: '8', q: "coolio")
    .get() (err, res, body) ->
      images = JSON.parse(body)
      if images && images.responseData
        images = images.responseData.results
        image  = msg.random images
        callback "#{image.unescapedUrl}#.png"
      else
        callback "Oops, something went wrong!"
