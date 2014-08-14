# Description:
#   Getting the MtGox Bitcoin price
#
# Commands:
#   hubot bitcoin
module.exports = (robot) ->
  robot.respond /bitcoin|btc/i, (msg) ->
    robot.http("http://data.mtgox.com/api/1/BTCUSD/ticker")
      .get() (err, res, body) ->
        result = JSON.parse(body)
        if result['return'] && result['return']['sell']
          msg.send "1 BTC is currently worth #{result['return']['sell']['display']}"
