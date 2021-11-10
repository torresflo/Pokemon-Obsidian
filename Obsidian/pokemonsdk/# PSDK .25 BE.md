# PSDK .25 BE 

This page describe many things about Pokémon SDK .25 Battle Engine

- [PSDK .25 BE](#psdk-25-be)
  - [How things works](#how-things-works)
  - [How to access those main objects](#how-to-access-those-main-objects)
    - [The battle scene object](#the-battle-scene-object)
    - [The logic object](#the-logic-object)
    - [The visual object](#the-visual-object)
  - [The generic stuff](#the-generic-stuff)
    - [Displaying a message](#displaying-a-message)
    - [Displaying the ability of a Pokémon](#displaying-the-ability-of-a-pokémon)
    - [Displaying the item held by a Pokémon](#displaying-the-item-held-by-a-pokémon)
    - [Display the animation showing the transformation of a Pokemon](#display-the-animation-showing-the-transformation-of-a-pokemon)
    - [Display a generic animation](#display-a-generic-animation)
  - [The handlers](#the-handlers)
    - [ChangeHandlerBase](#changehandlerbase)
    - [StatChangeHandler](#statchangehandler)
    - [ItemChangeHandler](#itemchangehandler)
    - [StatusChangeHandler](#statuschangehandler)
    - [DamageHandler](#damagehandler)
    - [SwitchHandler](#switchhandler)
    - [WeatherChangeHandler](#weatherchangehandler)
    - [FTerrainChangeHandler](#fterrainchangehandler)
    - [FleeHandler](#fleehandler)
    - [CatchHandler](#catchhandler)
      - [How to define a new ball](#how-to-define-a-new-ball)
      - [How to define a beast Pokémon](#how-to-define-a-beast-pokémon)
    - [AbilityChangeHandler](#abilitychangehandler)
      - [Ability on the target that cannot be changed](#ability-on-the-target-that-cannot-be-changed)
      - [Target ability that cannot be changed depending on the move](#target-ability-that-cannot-be-changed-depending-on-the-move)
      - [Abilities that cannot overwrite target ability](#abilities-that-cannot-overwrite-target-ability)
    - [BattleEndHandler](#battleendhandler)
  - [The effects](#the-effects)
    - [How to define a hook inside effect?](#how-to-define-a-hook-inside-effect)
    - [How to register a Status Effect](#how-to-register-a-status-effect)
    - [How to register an Ability effect](#how-to-register-an-ability-effect)
    - [How to register Item effect](#how-to-register-item-effect)
    - [How to register O-Power effect](#how-to-register-o-power-effect)
    - [How to register Trainer Effects](#how-to-register-trainer-effects)
    - [How to register Weather effect](#how-to-register-weather-effect)
    - [How to register a field terrain effect](#how-to-register-a-field-terrain-effect)
  - [The moves](#the-moves)
    - [How to define a move be_method ?](#how-to-define-a-move-be_method-)
    - [What are the methods of the moves ?](#what-are-the-methods-of-the-moves-)

## How things works

The Battle Engine is separated by 3 main instances
- `Battle::Scene` this instance is responsible of holding and instanciating the other two instances. That's the scene and it will gather and send the user input to the logic.
- `Battle::Visual` this instance is responsible of holding all the graphics of the Battle. We can query this instance to show specific things of the battle scene like the player choice or get a Pokemon visual battler.
- `Battle::Logic` this instance is responsible of holding the battle logic. It gives access to several handler like the handler of status changes, it also help to access a Pokemon Battler (the object containing the data).

All of those instance has a specific task (as described) and will only be responsive of the said task. This allow the battle to be more dynamic. For example, if you want to change how the battle looks like you only need to plug another Visual instance to the battle scene and it will work seamlessly.

## How to access those main objects
### The battle scene object

The battle scene object is normally accessible from anywhere, the battle engine is designed such a way that the instance variable `@scene` always contains a `Battle::Scene` object. We strongly discourage accessing the battle scene from the global `$scene` (especially if you seek the logic/visuals) because it's not guarenteed that this global contains the battle scene.

If you're implementing effects or hooks, you may get a `handler`. This handler should provide a `scene` property you can use to get the battle scene.

Note: The visual and the logic doesn't provide an external access to the battle scene. **They should always pass the reference to the objects they instanciate!**

### The logic object

If you're able to get the battle scene object, you'll get the logic object by using the `logic` property of the battle scene object. In some cases (effects, moves, handlers) the logic object is accessible from the `@logic` instance variable.

The handlers will always provide access to the logic (either from parameter or from property).

### The visual object

Unless it was passed down as parameter of the object you're manipulating, it will always be accessible through property visual of the battle scene object.

## The generic stuff
### Displaying a message

To display a message, you'll call the function `display_message_and_wait(string)` from the battle scene. This method will block the rest of the execution until the message has finished to be shown.

To get the string, you may call `parse_text(file_id, text_id)` (generally with file 18) or `parse_text_with_pokemon(file_id, text_id, pokemon)` (generally with file 19). See how it is called to guess how to use those functions.

Example:
```ruby
@scene.display_message(parse_text(18, 25))
```

### Displaying the ability of a Pokémon

Call the function `show_ability(pokemon)` from the `visual` object. This function will shows the ability name near to the Pokémon and does not block the execution.

Example:
```ruby
@scene.visual.show_ability(target)
```

### Displaying the item held by a Pokémon

Call the function `show_item(pokemon)` from the `visual` object. This function shows the item held near to the Pokémon and does not block the execution.

Example:
```ruby
@scene.visual.show_item(user)
```

### Display the animation showing the transformation of a Pokemon

Several Pokémon change their appearance during battle, to show this assign the new appearence to the Pokémon and then call the function `show_switch_form_animation(pokemon)` from the `visual` object. This function blocks the execution.

Example:
```ruby
pokemon.form = 5
@scene.visual.show_switch_form_animation(pokemon)
```
### Display a generic animation

Sometimes you need to show a generic animation over a specific Pokémon (or not but you have to specify a Pokémon anyway). To do this, use the function `show_rmxp_animation(target, rmxp_id)`.

This function will be deprecated in the future (replaced by something else) so don't use it unless you have no other choice.

## The handlers

In order to get the thing clean, we use handlers to handle the generic things that can happen during battle. Here's the handler that currently exists:

- `StatChangeHandler`: Manage the stat changes, can be accessed through `logic.stat_change_handler`.
- `ItemChangeHandler`: Manage the swapping of item over a Pokémon, can be accessed through `logic.item_change_handler`
- `StatusChangeHandler`: Manage the status changes, can be accessed through `logic.status_change_handler`
- `DamageHandler`: Manage the damage, drain & heal over Pokémon, can be accessed through `logic.damage_handler`
- `SwitchHandler`: Manage the switches between Pokémon, can be accessed through `logic.switch_handler`
- `EndTurnHandler`: Manage the end of turn sequence, can be accessed through `logic.end_turn_handler`. **This is not a change handler, this mean it doesn't act as the other handlers!**
- `WeatherChangeHandler`: Manage the weather condition changes, can be accessed through `logic.weather_change_handler`
- `FTerrainChangeHandler`: Manage the field terrain condition changes, can be accessed through `logic.fterrain_change_handler`
- `FleeHandler`: Manage the flee sequence (& calculation), can be accessed through `logic.flee_handler`
- `CatchHandler`: Manage the calculations related to catching the Pokemon, can be accessed through `logic.catch_handler`
- `AbilityChangeHandler`: Manage the change ability procedure, can be accessed through `logic.ability_change_handler`
- `BattleEndHandler`: Manage the everything that happends at the end of the battle
- `TransformHandler`: Manage transformation related thing, can be accessed through `logic.transform_handler`
- `ExpHandler`: Manage the exp distribution (telling which pokemon get what exp)

**Important note about the handlers**: the logic instanciate a new handler everytime you call the function that give access to the handler. If you need to show the prevention reason when you don't call the `*_with_process` function but use the test function instead, it's recommanded to store the handler in a local variable.

### ChangeHandlerBase

The class `Battle::Logic::ChangeHandlerBase` implements the basic functionality of all change handlers:

- The attribute `scene` giving you access to the scene inside the hooks.
- The attribute `logic` giving you access to the logic inside the hooks.
- The method `process_prevention_reason` that execute the block passed through `prevent_change`.
- The method `prevent_change(&block)` that returns `:prevent` and store the block as prevention_reason. This method can be called inside the prevention hooks in order to stop the prevention checking and tell that the change is not possible.

### StatChangeHandler

This handler is responsive of telling if it is possible to change the stats, why not and apply the stat change.

Methods you can call:
- `stat_increasable?(stat, target, launcher = nil, skill = nil)` : Tells if the `stat` can be increased on the `target`. You can pass `launcher` and `skill` during the move procedure execution to help the prevention upons move use.
- `stat_decreasable?(stat, target, launcher = nil, skill = nil)` : Tells if the `stat` can be decreased on the `target`. You can pass `launcher` and `skill` during the move procedure execution to help the prevention upons move use.
- `stat_change(stat, power, target, launcher = nil, skill = nil)` : Actually change the `stat` with the amount specified by `power` (negative = decrease) on the `target`. If the resulting power is 0, the apprioriate message will be shown, the animation is also played from here. You can pass `launcher` and `skill` during the move procedure execution to help the prevention upons move use.
- `stat_change_with_process(stat, power, target, launcher = nil, skill = nil)` : does the same as `stat_change` but call the test methods before and show the prevention reason if any.

The stats you can change:
- `:atk` : Physical attack of the Pokémon
- `:dfe` : Physical defense of the Pokémon
- `:ats` : Special attack of the Pokémon
- `:dfs` : Special defense of the Pokémon
- `:spd` : Speed of the Pokémon
- `:acc` : Accuracy of the Pokémon
- `:eva` : Evasion of the Pokémon

Example:
```ruby
logic.stat_change_handler.stat_change_with_process(:atk, -2, target)
```

### ItemChangeHandler

This handler is responsive of replacing the item held by the Pokémon. The only method you can call from this handler is `change_item(db_symbol, overwrite, target, launcher = nil, skill = nil)`.

As most handler, it can be called during moves so launcher & skill are optional. The `db_symbol` should be the new item held by the pokemon, use `:none` to remove the item held by the Pokémon (please don't call your items None). The `overwrite` parameter should be set to `true` if you want to permanently change the item (usually it's consumable items that sets this parameter to true).

### StatusChangeHandler

This handler is responsible of telling if a status can be applied (including confusion & flinch) and apply it if requested.

Here's the list of method you can call from this handler:
- `status_appliable?(status, target, launcher = nil, skill = nil)` : To test if you can apply the status.
- `status_change(status, target, launcher = nil, skill = nil, message_overwrite: nil)` To change the status.
- `status_change_with_process(status, target, launcher = nil, skill = nil, message_overwrite: nil)` : To test if the status is appliable and to change it if so.

The same way of other handlers, you can pass launcher and skill during the move procedure to tell explicitely that the status change comes from a move.
The parameter `message_overwrite` is the id of the message in file 19 if you want to show something else than the regular status change message.

The status you can apply are the following:
- `:poison` : to set the poison status condition
- `:toxic` : to set the bad poison status condition
- `:confusion` : to confuse the Pokémon
- `:sleep` : to set the asleep status condition
- `:freeze` : to set the frozen status condition
- `:paralysis` : to set the freeze status condition
- `:burn` : to set the burn status condition
- `:cure` : to cure the status condition
- `:confuse_cure` : to cure the confusion 

### DamageHandler

This handler is responsive of telling if damages can be applied on a Pokémon and deal them. It also include the draining damage kind so it's easier to manage draining.

List of method you can call from this handler:
- `damage_appliable(hp, target, launcher = nil, skill = nil)` give the actual number of damage the target will take or false if no damage can be applied.
- `damage_change(hp, target, launcher = nil, skill = nil)` if hp is positive, deal damage to the target, otherwise heals the target.
- `damage_change_with_process(hp, target, launcher = nil, skill = nil)` calculate the actual damage that can be applied (or if that's not possible to deal damages) and apply them if possible.
- `drain(hp_factor, target, launcher, skill = nil)` drains a factor amount of hp on the target (max_hp / hp_factor) and heals the launcher with that taken amount (unless an ability tells otherwise).
- `drain_with_process(hp_factor, target, launcher, skill)` check first the actual damage the target can take (substitute & co) and then drain the result if possible.
- `heal(target, hp, test_heal_block: true, animation_id: nil)` heal the pokemon if possible (hp < max_hp && not heal block if test_heal_block is true)

### SwitchHandler

The SwitchHandler is responsive of telling wether the pokemon can switch and execute all the events that triggers during switch (eg. entry hazard).

Here's the methods you can call from this handler:
- `can_switch?(pokemon, skill = nil, reason: :switch)` : Tell if the pokemon can be switched, a move can be passed if it was caused by a "switching like" move.
- `execute_switch_events(who, with)` : Actually execute the switch events.

**Note**: The execute_switch_events is called from `perform_action_switch` in the logic.
It is recommended to call the function from logic if you want to actuall perform a switch.

Example:
```ruby
logic.perform_action_switch(type: :switch, with: with, who: who)
```
The parameter with is the Pokémon comming to the battle, the parameter who is the pokemon being replaced.

### WeatherChangeHandler

In order to be able to change the weather properly, there's a handler telling if weather can be changed and what happen after the weather got changed.

Here's the methods you can call from the WeatherChangeHandler:
- `weather_appliable?(weather_type)` Tell if the weather can be applied
- `weather_change(weather_type, nb_turn)` Change the weather for a specific amount of turn (nb_turn = nil means never stops)
- `weather_change_with_process(weather_type, nb_turn)` Check if the weather can be changed and change it.

Here's the list of weather types:
- `:none` : No weather
- `:rain` : Raining
- `:sunny` : Sunny Day weather
- `:sandstorm` : Sandstorm
- `:hail` : Hail
- `:fog` : Fog

### FTerrainChangeHandler

In order to be able to change the field terrain properly, there's a handler telling if the field terrain can be applied and what happens after the field terrain got changed.

Here's the methods you can call from the FTerrainChangeHandler:
- `fterrain_appliable?(fterrain_type)` Tell if the field terrain can be applied
- `fterrain_change(fterrain_type)` Change the field terrain (for 5 turns)
- `fterrain_change_with_process(fterrain_type)` Change the field terrain only if it is possible, tell why it's not possble otherwise

Here's the list of field terrain types:
- `:none` : No field terrain
- `:electric_terrain` : Electric terrain
- `:grassy_terrain` : Grassy terrain
- `:misty_terrain` : Misty terrain
- `:psychic_terrain` : Psychic terrain

### FleeHandler

This handler is responsive of telling if it is possible to flee or not. Normally you should not have to call it yourself because it's related to the Player flee action. However if you want to add conditions that prevents the player from fleeing (without preventing him from doing anything else) you can use the flee_block hook.

Here's an example:

```ruby
Battle::Logic::FleeHandler.register_flee_block_hook('No flee when BT_NoEscape is on') do |handler|
  next unless $game_switches[Yuki::Sw::BT_NoEscape]

  handler.prevent_change do
    handler.scene.display_message(parse_text(18, 77))
  end
end
```

If you want the player to be able to flee (eg, having the Pokemon holding smoke ball) you can use the `flee_passthrough` block. If this block returns :success, the rate calculation & the switch handler will not be invoked!

Here's an example:
```ruby
Battle::Logic::FleeHandler.register_flee_passthrough_hook('PSDK smoke ball') do |handler, pokemon|
    next unless pokemon.hold_item?(:smoke_ball)

    # Play smokeball animation over pokemon
    message = parse_text_with_pokemon(19, 1010, pokemon, PFM::Text::ITEM2[1] => pokemon.item_name)
    handler.scene.display_message_and_wait(message)
    next :success
  end
end
```

### CatchHandler

This handler is responsive of calculating of the enemy Pokémon can be caught and showing the sequence of catching the Pokémon (including animation & message).

#### How to define a new ball

It is possible to have specific calculation depending on the type of ball, to do so, call `Battle::Logic::CatchHandler.add_ball_rate_calculation(db_symbol)`

This function takes `db_symbol` as the db_symbol of the ball item and a block that is feeded with the following arguments:
- `target` : The PFM::PokemonBattler object of the Pokémon that should be caught
- `pkm_ally` : The PFM::PokemonBattler object of the Player's Pokémon.

The block should return the final rate of the ball (so you should return a modified version of target.rareness).

Example:
```ruby
Battle::Logic::CatchHandler.add_ball_rate_calculation(:dive_ball) do |target, _pkm_ally|
  next (target.rareness * 3.5) if @scene.battle_info.fishing
  next (target.rareness * 3.5) if $game_player.surfing?

  next target.rareness
end
```

Note: Beast ball is not implement through add_ball_rate_calculation!

#### How to define a beast Pokémon

Add its db_symbol to `Battle::Logic::CatchHandler::ULTRA_BEAST`.

Example:
```ruby
Battle::Logic::CatchHandler::ULTRA_BEAST << :pheromosa
```

### AbilityChangeHandler

This handler is responsive of checking if an ability can be changed on the Pokemon and perform the change if requested.

There's several kind of change that can be prevented.

#### Ability on the target that cannot be changed

If a Pokemon hold any of the ability defined in `Battle::Logic::AbilityChangeHandler::CANT_OVERWRITE_ABILITIES` you cannot change its ability to another ability.

To define such ability, just add its db_symbol to the constant. Example:
```ruby
Battle::Logic::AbilityChangeHandler::CANT_OVERWRITE_ABILITIES << :multitype
```

#### Target ability that cannot be changed depending on the move

When a Pokemon use a move against a target, it is possible that some ability of the target prevents the target ability to be changed. To do so, define the list a target ability that prevent a move from changing the ability this way:

```ruby
Battle::Logic::AbilityChangeHandler::SKILL_BLOCKING_ABILITIES[mov_db_symbol] = [ability_db_symbol1, ability_db_symbol2, ...]
```

#### Abilities that cannot overwrite target ability

Sometimes you need to specify a list of abilities that cannot be overwritten if you want to change target ability with this ability. To do so define the list this way:
```ruby
Battle::Logic::AbilityChangeHandler::ABILITY_BLOCKING_ABILITIES[ability_to_change_db_symbol] = [target_ability_db_symbol1, target_ability_db_symbol2, ...]
```

Example:
```ruby
Battle::Logic::AbilityChangeHandler::ABILITY_BLOCKING_ABILITIES[:trace] = %i[flower_gift forecast illusion imposter trace]
```

Don't forget that some cases are already handled by `Battle::Logic::AbilityChangeHandler::CANT_OVERWRITE_ABILITIES`.

### BattleEndHandler

This handler handle every actions that happends at the end of the battle. For example, the trigger of the pickup ability, returning to the Pokemon Center when defeated, etc...

You can define stuff that happens at the end of the battle using those two methods:
- `Battle::Logic::BattleEndHandler.register('Reason') do |handler, players_pokemon| end`
- `Battle::Logic::BattleEndHandler.register_no_defeat('Reason') do |handler, players_pokemon| end`

The block sent to `register_no_defeat` are not called if the result is defeat.
The variable `handler` allows you to access the battle scene and the variable `players_pokemon` contains the PokemonBattler of the Player. You will need to call the `.original` method to get the actual Pokemon in the party in case you want to read something unchanged on the Pokemon.

Example:
```ruby
Battle::Logic::BattleEndHandler.register_no_defeat('PSDK honey gather') do |_, players_pokemon|
  players_pokemon.each do |pokemon|
    next unless pokemon.original.ability_db_symbol == :honey_gather && pokemon.item_holding == 0 && rand(100) < (pokemon.level / 2)

    pokemon.item_holding = GameData::Item[:honey].id
  end
end
```

## The effects

The effects in the battle engine are objects that execute an action on any hooks of the handlers. The effects all inherit from `Battle::Effects::EffectBase`. Those effects can have a counter, can be killed (then removed from their respective stack).

You can find effects at several places:
- `logic.terrain_effects` : On terrain (affecting everything)
- `logic.bank_effects[bank]` : On banks (affecting Pokémon of this bank)
- `logic.position_effects[bank][position]` : On specific position (affecting the Pokémon on this position)
- `pokemon.effects` : On a specific Pokémon (for moves)

All those places holds a `Battle::Effects::EffectsHandler` object allowing you to manage the effect through the following methods:

- `has?(symbol)` : Tell you if the handler contains an effect named by the symbol input
- `add(effect)` : Add a new effect to the handler
- `get(symbol)` : Get the first effect that is named by the symbol input
- `each { |effect| ... }` : Execute a block getting each effects as parameter
- `deleted_dead_effects` : Remove all dead effects from the handler

There's also static effect you cannot assign but that are used by the battle engine to know what to do:
- `pokemon.status_effect` : Effect of the current status the Pokemon has
- `pokemon.ability_effect` : Effect of the current ability the Pokemon has (voided if anything voids it)
- `pokemon.item_effect` : Effect of the current item held by the Pokemon (voided if anything voids it)
- `logic.weather_effect` : Effect of the weather
- `logic.field_terrain_effect` : Effect of the field terrain

When a handler is called, all the effect related to the pokemon involved (user & target) in the handler are called in the following order:
1. `logic.terrain_effects`
2. `logic.weather_effect`
3. `logic.field_terrain_effect`
4. For each pokemon involved:
   1. `pokemon.status_effect`
   2. `pokemon.ability_effect`
   3. `pokemon.item_effect`
   4. `pokemon.effects`
   5. `logic.position_effects[pokemon.bank][pokemon.position]`
5. Each ally Pokémon that has an ability effect flagged with `affect_allies`
6. For each bank involved (guessed from involved pokemon):
   1. `logic.bank_effects[bank]`

**Note**: If any effect block returns a Symbol, iteration over all effect is stoppoed and the Symbol is returned.

### How to define a hook inside effect?

All effect inheriting from `Battle::Effects::EffectBase` has methods called `on_{hook_type}` you can overwrite in order to specify the behaviour you want for your effect. Since all hook methods are called from the effects, they always return nil or a neutral result when they're not defined.

Most of the thing will rely on effects (including damage calculation), this allows maximum flexibility so you just define a new effect instead of rewriting the whole battle engine for one little thing.

Here's the list of methods you can define to hook something on an effect:
- `on_stat_increase_prevention(handler, stat, target, launcher, skill)`
- `on_stat_decrease_prevention(handler, stat, target, launcher, skill)`
- `on_stat_change(handler, stat, power, target, launcher, skill)`
- `on_stat_change_post(handler, stat, power, target, launcher, skill)`
- `on_pre_item_change(handler, db_symbol, target, launcher, skill)`
- `on_post_item_change(handler, db_symbol, target, launcher, skill)`
- `on_status_prevention(handler, status, target, launcher, skill)`
- `on_post_status_change(handler, status, target, launcher, skill)`
- `on_damage_prevention(handler, hp, target, launcher, skill)`
- `on_post_damage(handler, hp, target, launcher, skill)` : If the target is still alive
- `on_post_damage_death(handler, hp, target, launcher, skill)` : If the target died
- `on_switch_passthrough(handler, pokemon, skill, reason)`
- `on_switch_prevention(handler, pokemon, skill, reason)`
- `on_switch_event(handler, who, with)`
- `on_end_turn_event(logic, scene, battlers)`
- `on_weather_prevention(handler, weather_type, last_weather)`
- `on_post_weather_change(handler, weather_type, last_weather)`
- `on_fterrain_prevention(handler, fterrain_type, last_fterrain)`
- `on_post_fterrain_change(handler, fterrain_type, last_fterrain)`
- `on_move_prevention_user(user, targets, move)`
- `on_move_prevention_target(user, target, move)`
- `on_move_type_change(user, target, move, type)`
- `on_move_disabled_check(user, move)`
- `on_move_priority_change(user, priority, move)`
- `on_move_ability_immunity(user, target, move)`
- `on_transform_event(handler, target)`
- `on_single_type_multiplier_overwrite(target, target_type, type, move)`
- `base_power_multiplier(user, target, move)`
- `sp_atk_multiplier(user, target, move)`
- `sp_def_multiplier(user, target, move)`
- `mod1_multiplier(user, target, move)`
- `mod2_multiplier(user, target, move)`
- `mod3_multiplier(user, target, move)`
- `spd_modifier`
- `chance_of_hit_multiplier(user, target, move)`

Here's an example of effect that defines a behaviour:
```ruby
module Battle
  module Effects
    # Implement the attract effect
    class Attract < PokemonTiedEffectBase
      # Get the Pokemon who's this Pokemon is attracted to
      # @return [PFM::PokemonBattler]
      attr_reader :attracted_to
      # Create a new Pokemon Attract effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param attracted_to [PFM::PokemonBattler]
      def initialize(logic, target, attracted_to)
        super(logic, target)
        @attracted_to = attracted_to
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if user != @pokemon
        return unless targets.include?(@attracted_to)

        move.scene.display_message_and_wait(parse_text_with_pokemon(19, 333, user, PFM::Text::PKNICK[1] => @attracted_to.given_name))
        if bchance?(0.5)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 336, user))
          return :prevent
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :attract
      end
    end
  end
end
```

This effect has the name `:attract` so we can detect that it's already applied to the pokemon like this: `pokemon.effects.has?(:attrack)`. Each time the user will try to use a move on a target, the method `on_move_prevention_user` will be called and will potentially prevents the user to use the move on the specified target.

If you want to manage some properties of the effect here's the methods you can find on an effect:
- `counter=(new_counter)` : allows you to set how many turn the effect is active
- `dead?` : allows you to know/specify if the effect is dead or not (implying it'll get removed at the very last after all the end turn actions)
- `name` : gives you the symbol name of the effect (helping the effect handler to detect the effect with `has?(symbol)`)
- `rapid_spin_affected?`: tell if the effect is affected by rapid spin
- `force_next_move?`: Tell if the effect forces a move on the next turn
- `out_of_reach?`: Tell if the effect makes its holder out of reach
- `kill` : Kills the effect.
- `on_delete` : Function that is called after the effect was removed from its handler. It allows you to specify a message.

### How to register a Status Effect

Status effect gets automatically applied whenever we try to check which status it is. In order to be able to define what happens when a Pokémon has a specific status, we need to register a Status Effect.

In order to do so, we call the function:
```ruby
Battle::Effects::Status.register(status_id, klass)
```

Here's an example with the Burn status:
```ruby
module Battle
  module Effects
    class Status
      class Burn < Status
        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 if user != self.target
          return 1 unless move.physical?
          return 1 if user.has_ability?(:guts)

          return 0.5
        end

        # Prevent burn from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not burn or the taget is not the target of this effect
          return if target != self.target
          return if status != :burn

          # Prevent change by telling the target is already paralysed
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 267, target))
          end
        end

        # Apply burn effect on end of turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(target)
          return if target.has_ability?(:magic_guard)

          hp = burn_effect
          # Apply heat proof protection
          hp /= 2 if target.has_ability?(:heatproof)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 261, target))
          scene.visual.show_rmxp_animation(target, 469 + status_id)
          logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), target)

          # Ensure the procedure does not get blocked by this effect
          nil
        end

        private

        # Return the Burn effect on HP of the Pokemon
        # @return [Integer] number of HP loosen
        def burn_effect
          return (target.max_hp / 8).clamp(1, Float::INFINITY)
        end
      end

      register(GameData::States::BURN, Burn)
    end
  end
end
```

### How to register an Ability effect

Abilities provide effects to the Pokémon as soon as we check for the ability_effect. They'll only work with nothing disable the ability (making pokemon.has_ability?(name) return false).

To register an ability you need to call:
```ruby
Battle::Effects::Ability.register(db_symbol, klass)
```

Here's an example with the Analytic ability:
```ruby
module Battle
  module Effects
    class Ability
      class Analytic < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target

          return move.logic.battler_attacks_last?(user) ? 1.3 : 1
        end
      end
      register(:analytic, Analytic)
    end
  end
end
```

### How to register Item effect

Item effect works like abilities but are tied to items. The item_effect is working as long as `pokemon.hold_item?(name)` returns `true`. This mean that consumed berries, burnt items, thrown items will not work.

In order to define an item effect, you'll call:
```ruby
Battle::Effects::Item.register(db_symbol, klass)
```

Example with the Choice Scarf:
```ruby
module Battle
  module Effects
    class Item
      class ChoiceScarf < Item
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 1.5
        end

        # Function called when we try to check if the user cannot use a move
        # @param user [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Proc, nil]
        def on_move_disabled_check(user, move)
          return unless user == @target && user.move_history.any?
          return if user.move_history.last.db_symbol == move.db_symbol

          return proc {}
        end
      end
      register(:choice_scarf, ChoiceScarf)
    end
  end
end
```

### How to register O-Power effect

This is currently not possible (in .25.0) but this will be possible at some point.

We plan to make it able to be registered the following way:
```ruby
Battle::Effects::OPower.register(db_symbol, klass)
```

The information related to OPower will be stored in the PFM::Trainer object tied to the Pokémon which will benefit to the O-Power effect.

### How to register Trainer Effects
This is currently not possible (in .25.0) but this will be possible at some point.

We plan to make it able to register the following way:
```ruby
Battle::Effects::Trainer.register(klass) { |trainer| condition_over_trainer }
```

Trainer effect will be permanent during the whole battle, they'll be fetched during initialization of battle by checking each conditions. The trainer object is given to each condition so you can filter out trainers. For example obedience effect will not be applied to environmental trainers, it will only work over players.

### How to register Weather effect

Weather effects are valid as long as the weather `$env.current_weather_db_symbol` is equal to the db_symbol of the weather effect. That's why Cloud Nine and Air Lock needs to set weather to none.

To register a weather effect you call:
```ruby
Battle::Effects::Weather.register(weather_type, klass)
```
Weather type is normally the same as the parameter given to the weather change handler.

Example with [Sandstorm](https://www.youtube.com/watch?v=y6120QOlsfU):
```ruby
module Battle
  module Effects
    class Weather
      class Sandstorm < Weather
        # List of abilities that blocks sandstorm damages
        SANDSTORM_BLOCKING_ABILITIES = %i[magic_guard sand_veil sand_rush sand_force overcoat]
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          if $env.decrease_weather_duration
            scene.display_message_and_wait(parse_text(18, 94))
            logic.weather_change_handler.weather_change(:none, 0)
          else
            scene.visual.show_rmxp_animation(battlers.first || logic.battler(0, 0), 494)
            scene.display_message_and_wait(parse_text(18, 98))
            battlers.each do |battler|
              next if battler.type_rock? || battler.type_ground? || battler.type_steel?
              next if SANDSTORM_BLOCKING_ABILITIES.include?(battler.battle_ability_db_symbol)

              logic.damage_handler.damage_change((battler.max_hp / 16).clamp(1, Float::INFINITY), battler)
            end
          end
        end

        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if move.physical?
          return 1 unless target.type_rock?

          return 1.5
        end
      end
      register(:sandstorm, Sandstorm)
    end
  end
end
```

### How to register a field terrain effect

Field terrain works a bit the same way as weather but instead we do check logic.field_terrain and make sure the symbol is the same as the one from the effect.

To register a field terrain effect you call:
```ruby
Battle::Effects::FieldTerrain.register(terrain_type, klass)
```
The terrain type is the same value as you provided to the field terrain change handler.

Example with Misty terrain:
```ruby
module Battle
  module Effects
    class FieldTerrain
      class Misty < FieldTerrain
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          @internal_counter -= 1
          logic.fterrain_change_handler.fterrain_change(:none) if @internal_counter <= 0
        end

        # Function called when a status_prevention is checked
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          return unless target.affected_by_terrain? && status != :flinch && status != :cure

          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 845, target))
          end
        end

        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 unless move.type_dragon? && target.affected_by_terrain?

          return 0.5
        end

        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false unless target.affected_by_terrain? && move.status?
          return false unless move.status_effect > 0 || move.db_symbol == :yawn

          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 845, target))
          return true
        end
      end
      register(:misty_terrain, Misty)
    end
  end
end
```

## The moves

In the new Battle engine, the moves have their own object in the Battle module. This allow to specify several kind of Move using inheritance for several "be_methods".

All moves should inherit from `Battle::Move` if a be_method for move is not defined, the behaviour of the move can be highly impredictible!

### How to define a move be_method ?

Once you defined the move class, you can call the following static method of `Battle::Move` : `register`. Example: `Battle::Move.register(:s_basic, Battle::Move::Basic)`.

Once you did this, all the move whose be_method correspond to the first parameter of register will be instancied with the class given by the second parameter of register.

### What are the methods of the moves ?

Here's the list of important methods you'll find in the moves:

- `damages(user, target)` : Calculate the damages the move will deal to target, sets the `effectiveness` factor and the `critical` boolean attribute. This method should remain silent so abilities & items involved in rate modification should not be shown during the calculation. We will not detail all the methods involved in the calculation in this chapter.
- `type_modifier(user, target)` : Calculate the effectiveness of the move against a target. **This method is not called in damages**.
- `definitive_types(user, target)` : Calculate the definitive types of the move (eg. Ion Deluge changing type normal to type electric)
- `calc_stab(user, types)` : Gives the stab of the move with a specific user.
- `calc_type_n_multiplier(target, type_to_check, types)` : Gives the type modifier of the wanted type_to_check (`:type1`, `:type2`, `:type3`) on target when the move will hit the target. `types` correspond to the move types.
- `real_base_power(user, target)` Give the real base power of the move when used, useful for weight based move.
- `one_target?` : Tells if the move can hit only one target each time it's used.
- `no_choice_skill?` : Tell if the move let the player choose the target.
- `battler_targets(pokemon, logic)` : List all the possible targets of the move depending on the pokemon who use the move.
- `chance_of_hit(user, target)` : Give the chance the user has to hit the target (after the move accuracy was tested).
- `proceed(user, target_bank, target_position)` : Execute the move.
- `move_usable_by_user(user, targets)` : Test if the user is able to use the move (not frozen etc...). This method invokes the `move_prevention_user` hook and is called before testing the move accuracy.
- `disabled?(user)` : Tell if the move cannot be choosen from the choice because it's disabled by an effect.
- `target_immune?(user, target)` : Test if the target is immune (type). This method can be overwritten to prevent effects like LeechSeed on Grass Pokémon. If this method returns true, the following message will be shown: `The {target} is not affected`.
- `move_blocked_by_target?(user, target)` : Test if the move is blocked by the target thanks to a specific effect (protect). This method calls the move_prevention_target hook and this hook should return true if the target blocks the move. This method doesn't prevent the move from working on other targets if they didn't block the move.
- `blocked_by?(target, symbol)` : Test if the target is blocking the move using a specific move described by symbol (the move db_symbol). This method should be used inside move_prevention_target hooks.
- `play_animation_internal(user, targets)` : Plays the move animation, useful to overwrite when move has multiple animations.
- `deal_damage(user, actual_targets)` : Method responsive of dealing damage on each targets that was choosen and didn't evaded the move. Should return true to allow all the other `deal_` method to work.
- `effect_working?(user, actual_targets)` : Test if the effect is working (unless overwritten will always return true). If this method returns false, the deal_status, deal_stats and deal_effect method won't be called.
- `deal_status(user, actual_targets)` : Apply the status change on the targets
- `deal_stats(user, actual_targets)` : Apply the stat change on the targets
- `deal_effect(user, actual_targets)` : Apply the effect on the targets or terrain.
- `on_move_failure(user, targets, reason)` : Method executed if the move fails because the user couldn't use it (`:usable_by_user`), the accuracy of the move was not enough (`:accuracy`), one of the target is immune / evades the move (`:immunity`) or the move did not have enough pp (`:pp`)
- `use_another_move(move, user, target_bank = nil, target_position = nil)`: Allow the move to use another move. (eg. metronome)

Example of move that was implemented with some of those methods and that is registered properly:

```ruby
module Battle
  class Move
    # Move that inflict attract effect to the ennemy
    class Attract < Move
      private

      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[oblivious aroma_veil]
      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:attract) || (user.gender * target.gender) != 2

        if target.hold_item?(:mental_herb)
          @logic.item_change_handler.change_item(:none, true, target)
          return true
        elsif user.can_be_lowered_or_canceled?(BLOCKING_ABILITY.include?(target.battle_ability_db_symbol))
          @scene.visual.show_ability(target)
          return true
        end

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::Attract.new(@logic, target, user))
          user.effects.add(Effects::Attract.new(@logic, user, target)) if target.hold_item?(:destiny_knot)
        end
      end
    end

    Move.register(:s_attract, Attract)
  end
end
```

Don't forget that you can overwrite mostly anything related to the moves when a move behave differently, for example a move that has an addition to mod2. Effects do work over the move and are called during several computation (damage & hit chance).

The damage formula that PSDK applies is the following:
```ruby
(
  (
    (
      (
        (
          (
            (Level * 2 / 5) + 2
          ) * BasePower * [Sp]Atk / 50
        ) / [Sp]Def
      ) * Mod1
    ) + 2
  ) * CH * Mod2 * R / 100
) * STAB * Type1 * Type2 * Type3 * Mod3
```

You'll find all the method you can potentially super-monkey-patch in: `pokemonsdk/scripts/01600 Alpha 25 Battle Engine/04150 Battle_Move/00101 Move_Damage_Calc.rb`
