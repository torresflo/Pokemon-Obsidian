# PSDK .25 AI

The PSDK .25 AI has been reworked from scratch because the previous AI had a way to work that made it very inflexible. Now the .25 AI is using OOP to allow full customization.

## How does it work ?

In PSDK, the AI should answer to two kind of request:
- `What to do?` (`#trigger`) this correspond to the exact same choice as performed by player
- `With who to switch?` (`#request_switch(who)`) this correspond to the switch choice when one of the player mon is dead but on AI side.

Each trainer unless they're couple are controlled by a separate AI. This is why AI are initialized with the two following parameter:
- `bank` : telling from which bank the pokemon are controlled by the AI
- `party_id` : telling to which party in the bank (party index in Battle Info) the pokemon are being controlled by AI

For example, player usually control Pokémon from bank 0 and party_id 0. This mean that the AI that would replace the player needs to be initialize with 0, 0.

## The trigger method

The `#trigger` method is responsive of choosing the action to do for all Pokemon the AI controls. Meaning that in couple battle a single AI can control upto 2 Pokémon at once.
This method calls `#battle_action_for(pokemon)` for all Pokemon it controls.

The `#battle_action_for(pokemon)` method will attempt to find the best actions depending on its capability. All the actions will have an `heuristic` and they'll be shuffled before the maximum one is taken. This prevent two identical heuristic to cause the same action to always be triggered. (Regardless, it doesn't prevent a high heuristic to always trigger the same action!)

Here's the list of method called by `#battle_action_for(pokemon)` :
- `#move_action_for(move, pokemon)` combined with `#usable_moves(pokemon)` in order to get all the possible move action and their heuristics.
- `#mega_evolve_action_for(pokemon)` in order to get the possible mega action (if the AI is capable of mega evolving)
- `#switch_actions_for(pokemon, move_heuristics)` in order to get the possible switch action (if the AI is capable of switching)
- `#item_actions_for(pokemon, move_heuristics)` in order to get the possible item use action (if the AI is capable of using items)
- `#flee_action_for(pokemon)` in order to get the possible flee action (if the AI is capable of fleeing)

## How the heuristic is calculated

One of the most important heuristic is the move heuristic. In order to allow some computation we made a specific choice regarding this heuristic. We needed some heuristic to use exponential curve, this mean that we made the move heuristic start at a certain level a theorically end at another level.

### Move heuristic

The move heuristic is computed the following way:

```ruby
heuristic = (0.75 + base_power * effectiveness * stab / 8000) * special_modifier
```

When special modifier is 1, this formula yields values between 0.75 & 1.0 where 0.75 is a move with 0 effectiveness, and 1.0 is the most powerfull move (explosion: 250) with a stab of 2 (ability) and an effectiveness of x4 (double type). 

This formula might be wrong on 3rd type modification & with a standard special modifier, that's a risk we agree to take. Feel free to fix that yourself.

Regarding special_modifier. This modifier is set by default to `Math.sqrt(user.atk / target.dfe)` (depending on the category). Some moves might implement their own factor, for example protect might get a decreasing factor depending on the number of time it was used.

Note: The power of status move is computed the following way
```ruby
Math.exp((user.last_sent_turn - $game_temp.battle_turn + 1) / 10.0) * effectiveness * 0.85
```
If the move has a special modifier, it's set to 1 instead of this formula.

### Flee heuristic

This action has very high priority, if the Pokémon can flee, the heuristic is infinite.

### Switch heuristic

This kind of action has a specific behaviour. When called by trigger if capable, it will first evaluate the danger factor allowing or not the Pokemon to try switch actions. If the AI cannot read opponent move (because unused or incapable) the danger factor will be random between 0 & 1. If the danger factor is higher than the maximum user move heuristic, the user will get switch computation to choose a better Pokemon to switch in.

The definitive heuristic if switch got computed is the maximum heuristic of the moves the Pokemon to switch in.

### Item heuristic

#### Boosting item

Boosting item are treated the same way as status move so the heuristic of those item is the following:
```ruby
Math.exp((pokemon.last_sent_turn - $game_temp.battle_turn + 1) / 10.0) * 0.85
```

#### Healing item

Heal item are only considered if the AI can heal and the hp of the Pokemon are below a certain threshold (0.1). The formula for the heuristic is the following:
```ruby
(wrapper.item.is_a?(GameData::ConstantHealItem) ? wrapper.item.hp_count.to_f / pokemon.max_hp : wrapper.item.hp_rate) * 2.0
```
If an item heals 50% of the user HP, you're almost certain that the item will be used if the user has less than 10% of its life.

#### Burn healing item

Those items can be used only if the AI can heal and the user is burnt. The heuristic formula is:
```ruby
1 - pokemon.hp_rate / 4
```

#### Poison healing item

Those items can be used only if the AI can heal and the user is poisoned. The heuristic formula is:
```ruby
1 - pokemon.hp_rate / 4
```

#### Paralysis healing item

Those items can only be used if the AI can heal and the user is paralyzed. The heuristic is `0.78`.   
Note: We'd like some return over this heuristic.

#### Freeze healing item

Those items can only be used if the AI can heal and the user is frozen. The heuristic is `0.85`.   
Note: We'd like some return over this heuristic.

#### Sleep healing item

Those items can only be used if the AI can heal and the user is asleep. The heuristic is `0.76`.   
Note: We'd like some return over this heuristic.

## How the AI level is choosen

If you build the battle info yourself, you can set the AI level yourself. Otherwise, if you rely on automatic generation it is decided the following way:

1. If the battle is a roaming battle, the AI level is -1 (RoamingWild)
2. If the battle is a wild battle, the AI level is 0 (Wild)
3. If the variable Yuki::Var::AI_LEVEL (34) is greater than 0, the level is this variable
4. If the base money is strictly below 16, the AI level is 0 (Wild)
5. If the base money is strictly below 20, the AI level is 1 (TrainerLv1)
6. If the base money is strictly below 36, the AI level is 2 (TrainerLv2)
7. If the base money is strictly below 48, the AI level is 3 (TrainerLv3)
8. If the base money is strictly below 80, the AI level is 4 (TrainerLv4)
9. If the base money is strictly below 100, the AI level is 5 (TrainerLv5)
10. If the base money is strictly below 200, the AI level is 6 (TrainerLv6)
11. If the base money is strictly below Infinity, the AI level is 7 (TrainerLv7)

### Wild

Wild AI is the most basic AI, it does not know anything and just use random moves on random targets.

### TrainerLv1

AI corresponding to the youngster & similar trainers (base money < 20)

Its capability are:
- can_see_power

### TrainerLv2

AI corresponding to the bird keeper (base money < 36)

Its capability are:
- can_see_power
- can_see_effectiveness

### TrainerLv3

AI corresponding to the bird keeper (base money < 48)

Its capability are:
- can_see_power
- can_see_effectiveness
- can_see_move_kind

### TrainerLv4

AI corresponding to gambler (base money < 80)

Its capability are:
- can_see_power
- can_see_effectiveness
- can_see_move_kind
- can_mega_evolve
- can_switch
- can_use_item

### TrainerLv5

AI corresponding to Boss (base money < 100)

Its capability are:
- can_see_power
- can_see_effectiveness
- can_see_move_kind
- can_mega_evolve
- can_switch
- can_use_item
- can_choose_target

### TrainerLv6

AI corresponding to rival, gym leader, elite four (base money < 200)

Its capability are:
- can_see_power
- can_see_effectiveness
- can_see_move_kind
- can_mega_evolve
- can_switch
- can_use_item
- can_choose_target
- can_heal

### TrainerLv7

AI corresponding to champion (base money >= 200)

Its capability are:
- can_see_power
- can_see_effectiveness
- can_see_move_kind
- can_mega_evolve
- can_switch
- can_use_item
- can_choose_target
- can_heal
- can_read_opponent_movepool

### RoamingWild

This AI is for Roaming Pokémon, it inherit from TrainerLv3 and add the can_flee capability.

## How to define a new AI

In order to define a new AI, you have to create a AI class that inherit from Battle::AI::Base. You can specify its capability by redefining `#init_capability` like done in `TrainerLv1`. You can also change any aspect of the AI as long as you use proper input output for all redefined functions.

Once your class is fully defined, you can call `Battle::AI::Base.register(level, klass)`.

Example:
```ruby
# AI corresponding to the youngster & similar trainers (base money < 20)
class TrainerLv1Custom < Battle::AI::Base
  private

  def init_capability
    super
    @can_see_power = true
  end
end
Battle::AI::Base.register(96, TrainerLv1Custom)
```

## How to define a specific move ai rate

Since the AI cannot describe everything, especially for status move. We decided to make moves responsive of giving their own specific heuristic. To do so, you need to define the following method in the move class: `#special_ai_modifier(user, target, ai)`. This method takes the user, target and the AI that called the method. This way you can have a very precise definition.

Example:
```ruby
class SleepingMove < Battle::Move
  # Define the special ai modifier of this move
  # @param user [PFM::PokemonBattler]
  # @param target [PFM::PokemonBattler]
  # @param ai [Battle::AI::Base]
  def special_ai_modifier(user, target, ai)
    return user.asleep? ? 1 : 0
  end
end
```
Note: This move is not actually a sleeping move, it's just an example for the special AI modifier.

The special AI modifier might get multiplied to the move power if the move is not a status move. If the move is a status move and is innefective, the result of special_ai_modifier might get multiplied to 0 so you don't have to handle that case.

## How to see AI decisions

PSDK comes with a simple AI debug window, you can show it by writing the following line in the console:
```ruby
ScriptLoader.load_tool('AI/DebugWindow'); Debug::AiWindow.run
```

Note: This is not supported on Mac OS.
