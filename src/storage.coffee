class Storage
  constructor: (@robot) ->
    @robot.brain.on 'loaded', @load_storage
    @db = {}

  load_storage: =>
    now = Date.now()
    @db = @robot.brain.data.RolePlayingGame ||= {
      adventurers: {}
      monster: new Monster(1, 1)
      tick: 0
      tick_time: now
      last_talked_tick: 0
      last_talked_time: now
      rooms: {}
    }

  reset_storage: ->
    @robot.logger.info 'Resetting the RPG brain.'
    @robot.brain.data.RolePlayingGame = undefined
    @save()
    @robot.logger.info 'Reloading the RPG brain with new data.'
    @load_storage()
    @save()

  Object.defineProperties @prototype,
    adventurers:
      get: -> @db.adventurers
    monster:
      get: -> @db.monster
      set: (m) -> @db.monster = m; @save()
    rooms:
      get: -> @db.rooms ||= {}

  do_tick: ->
    @db.ticks++
    @db.tick_time = Date.now()
    @save()

  do_talk: ->
    @db.last_talked_tick = @db.tick
    @db.last_talked_time = Date.now()
    @save()

  save: ->
    @robot.brain.save()

module.exports = Storage
