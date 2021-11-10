vp = Viewport.create(:main, 10_000)
txt = UI::TextScroller.new(vp, texts = <<~Texts.each_line.to_a.compact, 12, 60.0)
  # Engine related credits

  ## Pokémon Universe
  Game Freak
  CREATURES INC.
  The Pokémon Company

  ## LiteRGSS

  ### Backend
  SFML

  ### Contributors
  Scorbutics
  nthoang-apcs
  SuperFola
  Nuri Yuri

  ## API
  ### FMOD lowlevel API
  FIRELIGHT TECHNOLOGIES PTY LTD.

  ### Data input for newer versions
  PokeAPI and its contributor

  ## Softwares
  Microsoft : Visual Code

  ## Contributors
  Nuri Yuri || Aerun
  Rey || SirMalo
  Leikt || Palbolsky

  ### PSDK Wiki
  Aerun || Akiyra
  Bugfix || buttjuice
  Guizmo || Jaizu
  Metaiko || Mud'
  Nuri Yuri || ralandel
  Rey || SMB64
  yyyyj || Zenos

  ### DataBase
  AEliso || Aerun
  Avori || Bentoxx
  dragon935 || Eurons
  joeyw || Mauduss
  Nuri Yuri || Palbolsky
  PokeAPI || RebelIce
  Tokeur || Redder
  Schneitizel || Walven

  ### Translation
  Aerun || Dax
  Eduardo Dorantes || Gehtdich Nichtsan
  Helio || Jaizu
  Kaizer || Leikt
  PadawanMoses || Rey
  SirMalo || SoloReprise
  SMB64 || yyyyj

  ### Ruby Host
  Aerun || AEliso
  Bentoxx || Buttjuice
  Maxoumi || Nuri Yuri
  Splifingald || yyyyj

  ### Other Contributors
  Amras || Anti-NT
  Aye || Bentoxx
  BigOrN0t || Bouzouw
  Cayrac || Diaband.onceron
  Fafa || Jarakaa
  Kiros97 || Likton
  MrSuperluigis || oldu49
  Otaku || Shamoke
  Solfay || sylvaintr
  UltimaShayra || Unbreakables

  # Resource related credits

  ## Tilesets

  ### Epic Adventures tileset
  Alistair || Alucus
  Bakura155 || Bati'
  Blue Beedrill || BoOmxBiG
  CNickC/CNC || CrimsonTakai
  Cuddlesthefatcat || ThePokemonChronicles
  Dewitty || EpicDay
  Fused || Gigatom
  Chimcharsfireworkd || Heavy-Metal-Lover
  Hek-el-grande || Kage-No-Sensei
  Kyledove || LaPampa
  LotusKing || New-titeuf
  Novus || Pokemon_Diamond
  Kizemaru_Kurunosuke || PrinceLegendario
  Reck || Red-Gyrados
  REMY35 || Saurav
  SL249 || Spaceemotion
  SirMalo || Stefpoke
  sylver1984 || ThatsSoWitty
  TheEnglishKiwi || Thegreatblaid
  TwentyOne || UltimoSpriter
  Warpras || WesleyFG
  Yoh || Nuri Yuri
  19dante91 || 27alexmad27
  07harris/Paranoid ||  

  ## Overworlds Sprites

  ### Gen1 to 5 Overworlds
  2and2makes5 || Aerun
  Chocosrawlooid || cSc-A7X
  Fernandojl || Gallanty
  Getsuei-H || Gizamimi-Pichu
  help-14 || kdiamo11
  Kid1513 || Kyle-Dove
  Kyt666 || Milomilotic11
  MissingLukey || Pokegirl4ever
  Silver-Skies || Syledude
  TyranitarDark || Zyon17
  Zenos ||  

  ### Gen6 Overworlds
  Princess-Phoenix
  LunarDusk6

  ## Pokémon Sprites

  ### Gen6 Pokémon Battlers (including megas)
  Amras || BladeRed
  Diegotoon20 || Domino99designs
  Falgaia || GeoisEvil
  Juan-Amador || N-Kin
  Noscium || SirAquaKip
  Zermonious || Zerudez
  Smogon XY Sprite Project ||  

  ### Gen7 Pokémon Battlers (including Alolan)
  Alex || Amethyst
  Bazaro || conyjams
  DatLopunnyTho || Falgaia
  fishbowlsoul90 || Jan
  kaji atsu || Koyo
  Leparagon || Lord-Myre
  LuigiPlayer || N-kin
  Noscium || Pikafan2000
  Smeargletail || Smogon
  princess-phoenix || The cynical poet
  Zumi ||  

  ### Gen8 Pokémon Battlers
  WolfPP
  conyjams

  ### Pokémon Offsets
  Don

  ## Icon Sprites

  ### Animated Pokémon icons
  Pikachumazzinga

  ### Gen7 Pokémon icons
  Otaku
  Poképedia

  ### Item icons
  Maxoumi (Brick icon & ADN Berserk)
  yyyyj (Pink Ribon icons)

  ## Texts

  ### Official Pokémon X/Y Texts
  Kaphotics || Peterko
  Smogon || X-Act

  ### Official Sun & Moon Texts
  Asia81

  ## UI Design

  ### Alpha Ruins puzzle
  FL0RENT_

  ### Default Message Windowskin
  ralandel

  ### Key Binding UI
  Eurons

  ### Language Selection UI
  Mud'

  ### Options UI
  Mud'

  ### Quests UI
  Renkys

  ### Shop & Pokémon Shop UI
  Aerun

  ### Trainer Card
  Eurons

  ### Mining Game UI and resources
  Aerun || Bentoxx
  redblueyellow || Rey

  ### XBOX 360 keys
  Yumekua

  ## Animations

  ### Gen6 Battle Entry
  Jayzon

  ### PSP Animations
  bibiantonio || ghioa
  Metaiko || Isomir
  KLNOTHINCOMIN ||  

  ### Shiny Animations
  Neslug

  ## Miscellaneous

  ### Battle Backs
  Midnitez-REMIX

  # Special Thanks
  PSDK would never have happened without Krosk
  the former creator of Pokémon Script Project
  which introduced Nuri Yuri to
  Pokémon Fangame Making in 2008.

Texts

txt.start
until txt.done?
  txt.update
  Graphics.update
end

vp.dispose