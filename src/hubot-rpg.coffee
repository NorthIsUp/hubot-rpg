# Description
#   A passive rpg for your chat
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Adam Hitchcock <adam@northisup.com>

require './utils'
RolePlayingGame = require './rpg'
Storage = require './storage'

module.exports = (robot) ->

  storage = new Storage(robot)
  RPG = new RolePlayingGame(robot, storage)

  should_play = (res) ->
    storage.rooms[res.message.room] ||= false

  set_room_state = (res, state) ->
    storage.rooms[res.message.room] = state

  robot.hear /rpg reset/, (res) ->
    res.send 'Resetting the RPG brain.'
    RPG.reset()

  robot.hear /rpg join/, (res) ->
    set_room_state(res, true)

  robot.hear /rpg leave/, (res) ->
    set_room_state(res, false)

  robot.hear /what is my loot(sz)?/, (res) ->
    adventurer = res.message.user.name
    res.send "#{adventurer} has some phat lootz, check them out: " + ("#{loot} : #{count}" for loot, count of RPG.adventurers[res.message.user.name].loot).join_and()

  robot.hear /./, (res) ->
    if should_play(res)
      rpg = new RolePlayingGame(robot, storage, res)
      rpg.do_tick(res)
