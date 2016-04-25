_ = require 'underscore'
adjectiveAnimal = require 'adjective-animal'
emojis = require 'emoji-named-characters'
require './utils'

class Monster

  constructor: (@hp, @xp, @tick) ->
    # ideas
    # - incorporate age
    #  - when created
    #  - how long it takes to kill
    #  - does the monster get stronger with age?

    @name = adjectiveAnimal.generateName().replace(/-/, ' ').title_case()
    @damage = 0
    @who_hit_me = {}

  Object.defineProperties @prototype,
    is_dead:
      get: -> @damage >= @hp
    hp_bar:
      get: ->
        p = @damage / @hp * 10
        bars = Math.floor(p)
        part = Math.floor(p % (bars || 1) * 10) || 0
        partial = '█▇▆▅▄▃▂▁'
        full = partial[0]
        empty = ' '

        a = Array(bars + 1).join(empty)
        b = Array(10 - bars).join(full)
        c = partial[Math.floor(part * (partial.length / 10))]
        bar = "|hp:#{@hp-@damage}|#{b}#{c}#{a}|"
        return bar

  @copy: (json) ->
    _.extend(new Monster(), json)

  ow: (damage, adventurer) ->
    if typeof damage == "string"
      damage = damage.length

    @damage += damage

    @who_hit_me[adventurer] ||= 0
    @who_hit_me[adventurer] += damage

  dole_out_phatty_lootz: ->
    lootz = {}
    if @is_dead
      for adventurer, damage_done of @who_hit_me
        lootz[adventurer] = {
          xp: Math.floor((damage_done / @hp) * @xp)
          loot: (emoji.character for emoji in _.sample(emojis, _.random(0, 3)))
        }

    return lootz

module.exports = Monster
