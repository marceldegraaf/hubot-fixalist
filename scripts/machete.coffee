# Description:
#   Machete don't give description
#
# Dependencies:
#   None
#
# Commands:
#   machete - return a random Machete image from Google Images
#
# Author:
#   wouter

module.exports = (robot) ->
  robot.hear /\bmachete\b/i, (msg) ->
    macheteImage msg, (url) ->
      msg.send url

macheteImage = (msg, callback) ->
  msg.http('http://ajax.googleapis.com/ajax/services/search/images')
    .query(v: "1.0", rsz: '8', q: "machete trejo still")
    .get() (err, res, body) ->
      images = JSON.parse(body)
      if images && images.responseData
        images = images.responseData.results
        image  = msg.random images
        callback "#{image.unescapedUrl}#.png"
      else
        callback "Oops, something went wrong!"
