# Description:
#   Manage groceries for lunch in an efficient way
#
# Dependencies:
#   "redis": "0.8.4"
#
# Configuration:
#   REDISTOGO_URL or REDISCLOUD_URL or BOXEN_REDIS_URL
#
# Commands:
#
#   hubot lunch poll new - starts a new lunch poll
#   hubot lunch poll list - show the responses to the poll
#   hubot lunch poll close - close the poll and show the results
#   hubot lunch poll remind - remind the missing users that they need to participate
#   hubot lunch poll respond <text> - respond to the poll with <text>
#   hubot lunch poll register - register for participation in lunch polls
#   hubot lunch poll unregister - unregister from participation in lunch polls
#   hubot lunch poll users - list of all registered users
#
# Author:
#   marceldegraaf

Util = require "util"

Array::compact = ->
  (elem for elem in this when elem?)

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

module.exports = (robot) ->

  # Create a new Lunch instance
  lunch = new Lunch(robot)

  # No poll is running
  handleNoPoll = (msg) ->
    msg.reply "no poll is running. Use 'lunch poll new' to start a new poll."

  # Current user is not registered to participate
  handleNotRegistered = (msg) ->
    msg.reply "you are not registered to participate in lunch polls. Please register with 'lunch poll register'."

  # No users have been registered at all
  handleNoRegisteredUsers = (msg) ->
    msg.reply "no users have been registered to participate in lunch polls yet."

  #
  # Command: register the current user for participation
  #
  robot.respond /lunch poll register/i, (msg) ->
    lunch.registerUser(msg.message.user)

    msg.reply "you have been registered for participation in lunch polls"

  #
  # Command: unregister the current user for participation
  #
  robot.respond /lunch poll unregister/i, (msg) ->
    lunch.unregisterUser(msg.message.user)

    msg.reply "you have been unregistered from participation in lunch polls"

  #
  # Command: list all registered users
  #
  robot.respond /lunch poll users/i, (msg) ->
    if lunch.noRegisteredUsers()
      handleNoRegisteredUsers(msg)
      return

    users = lunch.registeredUsers()
    userNames = users.map (user) -> user.name

    msg.reply "these users are registered for participation in lunch polls: #{userNames.join(', ')}"

  #
  # Command: start a new lunch poll
  #
  robot.respond /lunch poll new/i, (msg) ->
    if lunch.noRegisteredUsers()
      handleNoRegisteredUsers(msg)
      return

    if lunch.hasPoll()
      msg.reply "a poll is already running. Use 'lunch poll list' to see who's already answered."

    else
      lunch.createNewPoll(msg.message.user)
      msg.reply "a new poll has been created for you. Use 'lunch poll list' to check the answers."

  #
  # Command: list all the answers of the current poll
  #
  robot.respond /lunch poll list/i, (msg) ->
    if lunch.noRegisteredUsers()
      handleNoRegisteredUsers(msg)
      return

    if lunch.hasPoll()
      msg.send lunch.poll.responses()

    else
      handleNoPoll(msg)

  #
  # Command: close the current poll
  #
  robot.respond /lunch poll close/i, (msg) ->
    if lunch.hasPoll()
      lines = [
        "#{msg.message.user.name}: these are the results for the current poll:\n",
        lunch.poll.responses()
      ]

      msg.send lines.join("\n")

      lunch.poll.close()

    else
      handleNoPoll(msg)

  #
  # Command: current user responds to the current poll
  #
  robot.respond /lunch poll respond (.*)/i, (msg) ->
    if lunch.hasPoll()
      response = msg.match[1].trim()

      lunch.poll.recordResponse(msg.message.user, response)

      msg.reply "your order '#{response}' has been taken. Thanks!"

    else
      handleNoPoll(msg)

  #
  # Command: remind all users without responses that they must respond
  #
  robot.respond /lunch poll remind/i, (msg) ->
    if lunch.hasPoll()
      remindUsers = lunch.poll.usersWithoutResponse()

      if remindUsers.length > 0
        userNames = remindUsers.map (user) -> user.name
        msg.send "#{userNames.join(', ')}: please respond to the lunch poll using 'lunch poll respond <your order>'"

      else
        msg.reply "all users have responded to the poll. Here are their answers:"
        msg.send lunch.poll.responses()

    else
      handleNoPoll(msg)

  #
  # Command: current user volunteers to get lunch
  #
  robot.respond /lunch poll assign me/i, (msg) ->
    if lunch.hasPoll()
      if lunch.isRegisteredUser(msg.message.user)
        if lunch.poll.noUserAssigned()
          lunch.poll.assign(msg.message.user)
          msg.reply "thanks for volunteering to get lunch! We really appreciate it :heart:"

        else
          userName = lunch.poll.assignedUsers()[0].name
          msg.reply "sorry, #{userName} has already volunteered to get lunch. Better luck next time!"

      else
        handleNotRegistered(msg)

    else
      handleNoPoll(msg)

  #
  # Command: display who is assigned to get lunch
  #
  robot.respond /lunch poll assigned/i, (msg) ->
    if lunch.hasPoll()
      if lunch.poll.noUserAssigned()
        msg.reply "no one has volunteered to get lunch yet. To do so, type 'lunch poll assign me'"

      else
        userName = lunch.poll.assignedUsers()[0].name
        msg.reply "#{userName} has volunteered to get lunch today"

    else
      handleNoPoll(msg)

#
# Represents the interface to lunch polls, and to participating user storage
#
class Lunch

  constructor: (@robot) ->
    @poll = undefined

  hasPoll: ->
    @poll != undefined && @poll.isOpen()

  createNewPoll: (creator) ->
    @poll = new Poll(this, @robot, creator)

  isRegisteredUser: (user) ->
    matches = @registeredUsers().filter (registeredUser) -> registeredUser.id == user.id

    matches.length > 0

  registeredUsers: ->
    @robot.brain.data.lunch_users || []

  registerUser: (newUser) ->
    users = @robot.brain.data.lunch_users || []

    if users.filter( (user) -> user.id == newUser.id ).length == 0
      users = users.concat(newUser)

    @robot.brain.data.lunch_users = users

  unregisterUser: (removeUser) ->
    users = @robot.brain.data.lunch_users || []

    newUsers = for user in users
      unless user.id == removeUser.id
        user

    @robot.brain.data.lunch_users = newUsers.compact()

  noRegisteredUsers: ->
    @registeredUsers().length == 0

#
# Represents an individual lunch poll
#
class Poll

  constructor: (@lunch, @robot, @creator) ->
    @open = true

    @users = for user in @lunch.registeredUsers()
      { name: user.name, id: user.id, response: null, assigned: false }

  creatorName: ->
    @creator.name

  close: ->
    @open = false

  isOpen: ->
    @open == true

  recordResponse: (responder, response) ->
    for user in @users
      if user.id == responder.id
        user.response = response

  usersWithoutResponse: ->
    @users.filter (user) -> user.response == null

  responses: ->
    responses = @users.map (user) ->
      if user
        response = user.response || "not responded"
        assigned = if user.assigned then "(getting lunch)" else ""
        "#{user.name}: #{response} #{assigned}"

    responses.compact().join("\n")

  assign: (assignedUser) ->
    for user in @users
      if user.id == assignedUser.id
        user.assigned = true

  assignedUsers: ->
    @users.filter ( (user) -> user.assigned == true )

  noUserAssigned: ->
    @assignedUsers().length == 0
