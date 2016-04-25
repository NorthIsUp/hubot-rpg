require './utils'
Monster = require './monster'

String.prototype.title_case = () ->
  this.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())

Array.prototype.join_and = (sep=', ', sep_and=' and ') ->
  outStr = ''
  if this.length == 1
    outStr = this[0]
  else if this.length == 2
    outStr = this.join(sep_and);
  else if this.length > 2
    outStr = this.slice(0, -1).join(sep) + "#{sep}#{sep_and}" + this.slice(-1)
  outStr

class RolePlayingGame
  sword: 'o===§(:::::::::::::::>'
  pre: '⚔  '

  constructor: (@robot, @brain, @res=undefined) ->
    console.log 'constructor'

  welcome: =>
    @robot.logger.info @sword
    @robot.logger.info "#{@pre}Entering the #RPG realm"
    @robot.logger.debug @pre + @message

  Object.defineProperties @prototype,
    monster:
      get: ->
        if typeof @brain.monster != 'Monster'
          @brain.monster = Monster.copy(@brain.monster)
        @brain.monster
      set: (m) -> @brain.monster = m
    adventurer:
      get: -> @get_adventurer(@adventurer_name)
    adventurer_name:
      get: -> @res.message.user.name
    adventurers:
      get: -> @brain.adventurers
    tick:
      get: -> @brain.tick
    should_talk:
      get: ->
        now = Date.now()
        last_talked_time_delta = (now - @brain.db.last_talked_time) / 1000
        last_talked_tick_delta = @tick - @brain.db.last_talked_tick

        if last_talked_tick_delta < 5
          return false
        if last_talked_time_delta < 5
          return false
        if last_talked_time_delta > 20
          return true
        if @tick % 100 == 0
          return true

    message:
      get: -> "#{@monster.name} #{@monster.hp_bar}"

  get_adventurer: (adventurer) ->
    @adventurers[adventurer] ||= {xp: 0, loot: {}}
    @adventurers[adventurer]

  xp_for_level: (level) ->
    # http://bulbapedia.bulbagarden.net/wiki/Experience
    Math.floor((5 * Math.pow(level, 3)) / 4)

  level_for_xp: (xp) ->
    Math.floor(Math.pow(4/5 * xp, 1/3))

  level_up: (adventurer, lootz) ->
    # level up a character and generate the announcement of it
    a = @get_adventurer(adventurer)
    old_level = @level_for_xp(a.xp)

    a.xp += lootz.xp || 0
    for loot in lootz.loot
      a.loot[loot] ||= 0
      a.loot[loot]++

    new_level = @level_for_xp(a.xp)
    next = @xp_for_level(new_level + 1)

    level_up = old_level == new_level
    level_up_words = if level_up then 'levels up! ' else ''

    if level_up
      announce = "levels up to #{new_level}!"
    else
      announce = "is still level #{new_level}."

    if lootz.loot
      loot_str = lootz.loot.join_and()
      lootz_announce = ". #{adventurer} also got some sick phatty lootz #{loot_str}"
    else
      lootz_announce = ''

    @send "#{adventurer} gets #{lootz.xp}xp and #{announce} (next: #{a.xp}/#{next})#{lootz_announce}"

  new_monster: ->
    xp = Math.floor(@monster.hp * 3.13) || 1
    hp = Math.floor(@monster.hp * 1.13) || 1

    # for low values make sure we actually are increasing by something
    if hp == hp then hp++
    if xp == xp then xp++

    @monster = new Monster(hp, xp)

  announce_monster: ->
    @send "A wild #{@monster.name} appears!"

  announce_monster_death: ->
    @send "Rejoice! For #{@adventurer} has slain the #{@monster.name}!"

  do_tick: ->
    @brain.do_tick()
    message = @res.message
    damage = message.text.length

    @monster.ow(damage, @adventurer_name)

    if @monster.is_dead
      for adventurer, lootz of @monster.dole_out_phatty_lootz()
        @announce_monster_death()
        @level_up(adventurer, lootz)

      @new_monster()
      @announce_monster()
      @send @message
    else
      @send_polite @message
    @save()
    @robot.logger.debug @pre + @message

  save: ->
    @brain.save()

  reset: ->
    @storage_reset()
    @storage_loaded()

  send: (message) ->
    @res.send @pre + message
    @brain.do_talk()

  send_polite: (message) ->
    if @should_talk
      @send message

module.exports = RolePlayingGame
