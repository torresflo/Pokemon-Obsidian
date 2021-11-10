# Describe Item

In PSDK all item are a kind of GameData::Item, this kind of object only holds the data about the item. It doesn't tell how PSDK should use this item. In order to do this we have a module in `PFM` called `ItemDescriptor`.

This module takes an item (item_id / db_symbol) in parameter of `action` and returns a Wrapper telling what PSDK has to do. This wrapper is refered as `extend_data` in many UI.

## Properties and function of PFM::ItemDescriptor::Wrapper

You can read several properties from the wrapper:
- `no_effect` If this property is set to `true`, the UI has to display the message telling this item has no effect.
- `chen` If this property is set to `true`, the UI has to display the message telling it's not time to use this item.
- `open_party` If this property is set to true, the UI has to open the party in order to let the player choose a Pokemon / Skill in order to use this item.
- `open_skill` If this property is set to true, the UI has to open the Skill selection UI in order to let the item perform something on a choosen skill.
- `open_skill_learn` If this property is set to a move ID, the Party UI should open the `MoveTeaching` UI on the choosen Pokémon (if it can learn the move).
- `stone_evolve` If this property is set to true, the UI should show if the Pokémon is able to evolve or not with this item.
- `use_before_telling` If this property is set to true, the item will be used before the message (allowing to cancel usage) from bag.
- `skill_message_id` This property should contain the ID of the message to show in the Summary UI when we choose a skill.


Depending on the properties you'll have, you can call several function that will process the item or tell if the item can be used:
- `on_pokemon_choice(pokemon, scene)` This function returns true or false if the Item can be used on the Pokemon.
- `on_pokemon_use(pokemon, scene)` This function use the item on the Pokemon.
- `on_skill_choice(skill, scene)` This function returns true or false if the Item can be used on the specific Move of the Pokémon.
- `on_skill_use(pokemon, skill, scene)` This function apply the item on the choosen move.
- `on_use(scene)` This function is called if none of the proprety tells to do anything. (From bag usually.)
- `execute_battle_action` This function is called from battle engine, the item should be bound to a Pokemon,  the Battle Scene and optionally the move in order to process the item during the battle phase.
- `bind(scene, pokemon, skill = nil)` This function binds information to the wrapper so the battle engine can use it without knowing the parameters.

## How to define the condition that allows EventItem to be used

EventItem are calling common events (outside of the map), by default they will always be called. If you want to put conditions over the possibility to call the common event call the following method:

```ruby
PFM::ItemDescriptor.define_event_condition(event_id) do
  # return true or false here
end
```

Example:
```ruby
PFM::ItemDescriptor.define_event_condition(11) do
  next false if $game_player.surfing?
  
  next $game_switches[Yuki::Sw::EV_Bicycle] ||
         $game_switches[Yuki::Sw::Env_CanFly] ||
         $game_switches[Yuki::Sw::Env_CanDig]
end
```

## How to define condition preventing certain item of being use (It's not time)

Some item like sacred ash can only be used if any Pokemon of the party is dead. In order to prevent the item from being used if the condition are not meet you can use the following function:

```ruby
PFM::ItemDescriptor.define_chen_prevension(klass_or_symbol) do |item|
  # return true if chen tells it's not time
end
```

Example:
```ruby
PFM::ItemDescriptor.define_chen_prevension(:sacred_ash) do
  next $actors.none? { |pokemon| pokemon.dead? && !pokemon.egg? }
end
```

## How to define an action that is performed from bag

Some item just do something from the bag (:on_use) to define them use the following function:

```ruby
PFM::ItemDescriptor.define_bag_use(klass_or_symbol, use_before_telling) do |item, scene|
  # Code executed when item is actually used
end
```

Note: use_before_telling is set to true if you want to make the item act before the message "this item is used". Setting use_before_telling allows you to return `:unused` from the block in case the item could not be used.

Example:
```ruby
PFM::ItemDescriptor.define_bag_use(GameData::RepelItem, true) do |item, scene|
  next $pokemon_party.set_repel_count(item.repel_count) if $pokemon_party.get_repel_count <= 0

  scene.display_message(parse_text(22, 47))
  next :unused
end
```

## How to define an action that is performed on a Pokemon

This kind of action is a bit more complex because you need to define two thing:
- If the item can be used on the choosen Pokémon
- What happen if the item is applied on the Pokemon
- If the game is in battle, what should be done during battle

For that we have 3 methods:

### Define the usability of item on a Pokemon

To define if the item can be used on a Pokemon, use the following function:
```ruby
PFM::ItemDescriptor.define_on_pokemon_usability(klass) do |item, pokemon|
  # Return true if it can be used on this Pokemon
end
```

Example:
```ruby
PFM::ItemDescriptor.define_on_pokemon_usability(GameData::StoneItem) do |item, pokemon|
  next false if pokemon.egg?

  next pokemon.evolve_check(:stone, item.id)
end
```

### Define the action that is done on a Pokemon on Map

To define the item action when used on a Pokemon on map, use the following function:
```ruby
PFM::ItemDescriptor.define_on_pokemon_use(klass) do |item, pokemon, scene|
  # Perform the action
end
```

Example:
```ruby
PFM::ItemDescriptor.define_on_pokemon_use(GameData::StoneItem) do |item, pokemon, scene|
  id, form = pokemon.evolve_check(:stone, item.id)
  scene.call_scene(GamePlay::Evolve, pokemon, id, form, true) do |evolve_scene|
    scene.running = false
    $bag.add_item(item.id, 1) unless GamePlay::Evolve.from(evolve_scene).evolved
  end
end
```


### Define the action that is done on a Pokemon in Battle

To define the item action when used in Battle, use the following function:
```ruby
PFM::ItemDescriptor.define_on_pokemon_battler_use(klass) do |item, pokemon, scene|
  # Perform the action
end
```

## How to define an action performed over a move of a Pokemon

This one is even harder than defining actions performed over a Pokemon because first of all you have to define the usability over a Pokemon and then the usability over the move.

We then also have 3 methods:

### Define the usability of the item over a Move

To define if an item can act over a move, use the following function:
```ruby
PFM::ItemDescriptor.define_on_move_usability(klass, skill_message_id = 34) do |item, skill|
  # Return true if the item can be used
end
```

Note: skill_message_id defines the ID of the message shown in the Summary UI when testing the moves.

Example:
```ruby
PFM::ItemDescriptor.define_on_move_usability(GameData::PPIncreaseItem, 35) do |_, skill|
  next (skill.data.pp_max * 8 / 5) > skill.ppmax
end
```

### Define the action that is done on a Move on Map

To define the action performed by the item on a move, use the following function:
```ruby
PFM::ItemDescriptor.define_on_move_use(klass) do |item, pokemon, skill, scene|
  # Do your stuff
end
```

Example:
```ruby
PFM::ItemDescriptor.define_on_move_use(GameData::PPIncreaseItem) do |item, pokemon, skill, scene|
  pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
  if GameData::PPIncreaseItem.from(item).max
    skill.ppmax = skill.data.pp_max * 8 / 5
  else
    skill.ppmax += skill.data.pp_max * 1 / 5
  end
  skill.pp += 99
  scene.display_message_and_wait(parse_text(22, 117, PFM::Text::MOVE[0] => skill.name))
end
```


### Define the action that is done on a Move in Battle

To define the action performed by the item on a move in battle, use the following function:
```ruby
PFM::ItemDescriptor.define_on_battle_move_use(klass) do |item, pokemon, skill, scene|
  # Do your stuff
end
```
