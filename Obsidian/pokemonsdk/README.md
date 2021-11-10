# Pokémon SDK

`PSDK` is a Starter Kit allowing to create Pokémon Games using various tools like RPG Maker XP and custom data base editors.

[![Discord](https://img.shields.io/discord/143824995867557888.svg?logo=discord&colorB=728ADA&label=Discord)](https://discord.gg/0noB0gBDd91B8pMk)
[![Twitter PSDK](https://img.shields.io/twitter/follow/PokemonSDK?label=Twitter%20PSDK&logoColor=%23333333&style=social)](https://twitter.com/PokemonSDK)
[![Twitter PW](https://img.shields.io/twitter/follow/PokemonWorkshop?label=Twitter%20PW&logoColor=%23333333&style=social)](https://twitter.com/PokemonWorkshop)


### Generic Links

[Downloads](https://download.psdk.pokemonworkshop.com/)
| [Event Making Tutorial](https://psdk.pokemonworkshop.fr/wiki/en/event_making/index.html)
| [Edit Database](https://psdk.pokemonworkshop.fr/wiki/en/ruby_host/index.html)
| [Wiki](https://psdk.pokemonworkshop.com/en/)
| [LiteRGSS Documentation](https://psdk.pokemonworkshop.com/litergss/)

### Database Indexes

[Pokémon](https://psdk.pokemonworkshop.com/db/db_pokemon.html)
| [Abilities](https://psdk.pokemonworkshop.com/db/db_ability.html)
| [Items](https://psdk.pokemonworkshop.com/db/db_item.html)
| [Moves](https://psdk.pokemonworkshop.com/db/db_skill.html)

## Specifications

Contrary to `PSP` or `Essentials`, `PSDK` doesn't use the RGSS. We wrote a graphic engine called `LiteRGSS` using `SFML`, which allows a better mastering of the Graphic part of PSDK like adding Shaders, turning some graphic process to C++ side etc...

* Game Engine : `LiteRGSS` (under `Ruby 2.5.0`)
* Default screen size : `320x240` (upscaled to `640x480`)
* Sound : [FMOD](http://www.fmod.org/) (Support: Midi, WMA, MP3, OGG, MOD, WAVE)
* Map Editor
    * `RMXP`
    * [Tiled](https://pokemonworkshop.fr/forum/index.php?topic=4617.0)
* Event Editor
    * `RMXP`
    * WIP : VSCODE
* Database Editor
    * `RubyHost`
* Dependencies : `SFML`, `LodePNG`, `libnsgif`, `FMOD`, `OpenGL`

## PSDK Features
### System Features

- [Time & Tint System](https://psdk.pokemonworkshop.fr/wiki/en/event_making/time-system.html) (using virtual or real clock)
- Particle System (display animation on characters according to the terrain without using RMXP animations)
- [FollowMe](https://psdk.pokemonworkshop.fr/wiki/en/event_making/followme.html) (also known as Following Pokémon)
- [Quests](https://psdk.pokemonworkshop.fr/wiki/en/ruby_host/quest.html)
- Double & Online Battles (P2P)
- Running shoes
- Key Binding UI (F1)
- Multi-DayCare
- Berry System
- Online Trades (P2P)
- GTS (you need to add an [external script](https://reliccastle.com/resources/314/))

### Mapping & Event Making Features

- Shadow under events system (also known as Overworld Shadows)
- Extended event info (using the event name)  
    This feature allow the maker to specify various thing like the event graphics y offset, if the event display shadow or even if the event needs to display a sprite (optimization).
- SystemTags (Give more info about the terrain and allow specific interactions)
    - Wild info System Tags (+Particles) : Tall Grass, Cave, Sea/Ocean, Pond/River, Sand, Snow etc…
    - Mach Bike tiles (muddy slopes & cracked tiles)
    - Acro Bike tiles (white rails & bunny hop rocks)
    - Slopes (HGSS thing)
    - Stairs (4G+ stairs)
    - Bridges (With event support)
    - Ledges
    - Rapid water tiles (forcing direction) / Ice (sliding)
    - Wet sand (Water particle on player)
    - Headbutt
- Dialog / Text Database allowing easier translation for the game using CSV format
- Special Warp fades (5G out->in & 3G transition)
- Weathers : Rain, Harsh sunlight, Sandstorm, Snow, Fog
- Premade common events : Strength, Dig, Fly, DayCare Hosts, Berry Trees, Dowsing Machine, Head Butt, Cut, Rods, Rock Smash, WaterFall, Flash, Whirlpool, Rock Climb, Teleport, Defog

### Mini-Games
- Voltorb Flip
- Ruins of Alph puzzle
