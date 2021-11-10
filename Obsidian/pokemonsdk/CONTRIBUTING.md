# How to contribute to PSDK scripts

## Fork PSDK

* Go to the [PSDK Repo](https://gitlab.com/NuriYuri/pokemonsdk)
* Click on the fork button
* In your fork
    * Click on the Settings -> Repository button
    * Go to the `Mirroring repositories` section
    * Put this URL in the Git Repository URL : ` https://gitlab.com/pokemonsdk/pokemonsdk.git`
    * Set Mirror Direction to `Pull`
    * Check `Only mirror protected branches`

## Set your local repository

In your Pokémon SDK folder, you'll open `cmd.bat` and write the following commands :
* `cd pokemonsdk`
* `git remote set-url origin your_ssh_url`
    * You can get the url by clicking on `clone` in your PSDK Fork details. Take the SSH URL otherwise it'll be hard to push.
* `git pull`

## When Making a new feature or a bugfix

You should follow the branch naming :

* Feature branche are named like this : `feature/us-ID name`
* The bug fix branche are named like this : `bugfix/us-ID name`

To make your new feature/bugfix enter the following commands your pokemonsdk folder :

* `git checkout development`
* `git pull`
* `git checkout -b name_of_the_branch`

You'll be now able to work on what you need to work.

**Note** : You should **never** commit inside `development`. If you do so you'll break your fork (mirroring will never work again).

## When commiting to your branch

If your branch aim to fix a bug, make sure the last commit contains the following in the commit message : `fix #id_of_the_issue`

When you'll merge with the official development branch it'll close the issue.

## Before merging to development

First thing to know. You **should not** merge your change to the `development` branch. You **have to make a merge request** from your feature/bugfix branch to the **official** (`NuriYuri/pokemonsdk`) development branch.

Second thing : You have to test your feature or your bugfix. 

* The PSDK project should be able to boot
* All the PSDK feature should work like they worked before (except the one you fixed obviously)
* Your feature/bugfix should not introduce a new bug (we won't get mad if you didn't see any new bugs)

Third thing : You have to be up to date

* You should merged the `development` branch in your feature/bugfix branch in order to be upto date
* You should solve all the conflict

## When making the Merge Request

* In `Source branch`
    * Select your project
    * Select the branch you want to merge with PSDK `development`
* In `Target branch`
    * Select the project `NuriYuri/pokemonsdk`
    * Select the branch `development`
* Click on the `Compare branches and continue` button

You'll see the `New Merge Request` UI

* In Title put a title that is a bit more explicit than the branch name
* In description
    * describe the goal of the merge
    * add reference to issues if needed
    * tell us if you added files that aren't supposed to be in the `pokemonsdk` folder (graphics for example)
        * You can put a link to a 7z archive that adds all the new ressources by simply extracting it in the project root
* Assign the Merge to `NuriYuri` if it's possible
* Add labels that can make the merge more obvious about the field of application
* Check `Delete source branch when merge request is accepted.`
* Check `Squash commits when merge request is accepted.`
* Click on `Submit merge request` button

If your merge request didn't get any comment or didn't get merged after **one week** contact Nuri Yuri through the `Pokémon Workshop` Discord (you'll find a link int the website). We have a webhook that tells all the action on the main `Gitlab` repo so `NuriYuri` should see the request but no-one is perfect and `NuriYuri` can forget about it...

# The coding rule

PSDK is a `Ruby` Project. It uses tools that work well with Ruby.

## What editor to use ?

To edit the scripts :
* You need to use [Visual Studio Code](https://code.visualstudio.com). 
* You'll need to install `ruby` 2.5.x with the devkit (MSYS2 on Windows, Ruby Installer gives you the choice to install it).
* You'll have to install `SolarGraph` using the command `gem install solargraph --no-doc` in cmd.
* You'll need to add the `SolarGraph` extension in `VS Code`
* You'll configure the Ruby language to use two space for indentation (it's really important)

## What folder to open with VS Code ?

With VS Code you'll have to open the `scripts` folder of the `pokemonsdk` local repo. This folder is configured to define all the `rubocop` rules that PSDK uses.

## What are the exact coding rules ?

### Inside a script

* All the thing you add or change should not be undelined in green or orange. (If you think a rule is stupid, tell us we can change it).
* You should not lose time to fix old lines that are underlined in green or orange.
* You should document your code using the [YARD format](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md) ([List of tags](https://rubydoc.info/gems/yard/file/docs/Tags.md)).
* You should frament your function to allow easy patching if a maker wants to change a little the behaviors of the script without rewriting everything.
* If SolarGraph fail to give your the right completion for a instance variable, use the `# @type [ClassName]` before creating the instance variable.

### Naming of the script

All the PSDK script are named like this : `XXXX Name.rb`
* X are a number between 0 and 9, it allow sorting between scripts
* Name should be the name of the class/module + the context when the class is separated in various scripts.

Note : Old script has the following name `Module__Class`, don't do this any more, the folder already tell us the module.

### In which module to put the new features ?

I'll give you the official list of PSDK module with their meaning :
* `Scheduler` : This module is not used to contain classes. This is the module responsive of executing `tasks` at certain point of the game without adding lines inside the scripts to explicitely call your features. A tutorial about how to use it will be made later, you can check the `00100 PSDK_Task` script to see how it's used.
* `GameData` : This module contain all the class & `dead data` helpers. The `dead data` is the data that are stored inside the `.rxdata`, `.csv` or `.dat` files, it's data that PSDK should not edit/change/save and uses as source of information (exp curve of a Pokemon for example).
* `Yuki` : This is a old module comming from the time PSDK didn't existed. This contain all the feature that `NuriYuri` made. You should never add any script inside it. (But you can fix some features)
* `PFM` : This module contain all the class & `living data` helpers. The `living data` is the data that is manipulated during `runtime` and that can be expected to be saved in the player save file.
* `UI` : This module contain all the classes that are expected to perform `Graphic` display/help. Those classe should not have logic inside (or just tiny logic if that helps the display like index adjustment). Most of the class inside `UI` should inherit from `UI::SpriteStack`, `Sprite` or `UI::Window`.
* `GamePlay` : This module contain all the scene that are called and stored inside the `$scene` global. If you make a new scene, you **have to** make it inherit from `GamePlay::Base` (or a specialized `GamePlay::Base` class) and you should **never** edit the `main` functions or read/write the `$scene` variable. A tutorial will be made later about `GamePlay::Base`.
* `BattleEngine` : This module is the logic of the Alpha 24 battles, it'll be removed in Alpha 25.
* `Online` : This module define some stuff related to Online interactions.
* `BattleUI` : This module contain all the UI of the Alpha 25 battle. That's somehow the same as `UI` but `UI` is currently not included inside so you need to explicitely write `UI::ClassName` if you use a class from `UI` in `BattleUI`.
* `Battle` : This module contains all the Alpha 25 Battle related classes (`Scene`, `Logic`, `Visual`, `AI` and `Move`).

If you write a feature, you should write it in the correct module according to what the feature do. When you make a scene, it's important to not write graphics related stuff inside the scene (do it inside `UI` with a dedicated classs) and spawn the UI class instance inside an `init_xxx` of your Scene. (This allow the maker or specialized class to change the UI used by modifiying the `init_xxx` method).

## Specific rules

As you may see inside PSDK (putting the RMXP basic scripts aside) we do thing a certain way, here's some rule you should follow to be compatible with PSDK or make good scripts :

### Never use for or dynamic Ranges

The `for` keyword is forbidden because it's meaning in Ruby is not the same as in `C` or `Algorythme`. 

```ruby
for i in 0...5 do
  p i
end
```

Is the strict same as :
```ruby
(0...5).each do |i|
  p i
end
```

Ruby has a powerfull Iteration/Enumeration system, you should use the following methods instead of `for` loops :
* `int.times { |i| ... }` instead of : 
    ```ruby 
    for i in 0...int do
      ...
    end
    ```
* `min.upto(max) { |i| ... }` instead of :
    ```ruby
    for i in min..max do
      ...
    end
* `max.downto(min) { |i| ... }` instead of :
    ```ruby
    for i in min..max do
      j = max - (i - min)
      ...
    end
    ```
* `beg.step(last, step_val) { |i| ... }` instead of :
    ```ruby
    for i in beg..last do
      next if i % step_val != 0
      ...
    end
    ```
* Use
    ```ruby
    var = Array.new(size) do |i|
      ...
      next(element)
    end
    ```
    instead of :
    ```ruby
    var = []
    for i in 0...size do
      ...
      var.push(element)
    end
    ```
* `ary.select { |element| condition }` instead of :
    ```ruby
    result = []
    for i in 0...ary.size do
      result.push(ary[i]) if condition
    end
    ```
    Alternativeley, use `reject` to perform the opposite.
* `ary.collect { |element| transformation }` or `ary.map { |element| transformtion }` instead of :
    ```ruby
    array = ary.clone
    for i in 0...ary.size do
      array[i] = transformation
    end
    ```
* `ary.any? { |element| condition }` instead of :
    ```ruby
    result = false
    for i in 0...ary.size do
      next unless condition
      result = true
      break
    end
    ```
* `ary.all? { |element| condition }` instead of :
    ```ruby
    result = true
    for i in 0...ary.size do
      next if condition
      result = false
      break
    end
    ```
* `ary.inject(0) { |sum, element| sum + element.property }` if you need to get the sum of a property of the element in an array. (Like the total level sum of the party).


Note about the block syntax : If the code use only one line we use the `{ |*params|  }` syntax, if the code use more lines we use the `do |i| lines end` syntax. Rubocop will tell you if you don't respect the rule.

We strongly discourage the use of dynamic Ranges when it's not needed because it creates unnecessary objects when there's other alternatives.

### If you want to allow maker customization, use methods or constants

For example if the use wants to change the background of the UI, for a darker one, you may probably use a `COLORS` constant that list all the color id you use in the Interface. This way the maker can change the content of `COLORS` to use colors that are more adapted to its UI.

If you only use one or two colors you can make methods like `default_color` or `highlight_color` that returns the ID of the color you use.

The same goes for filenames, window builders etc...

### Don't write all the logic inside `update` in Scenes

The best thing is to make your Scene inherit from `GamePlay::BaseCleanUpdate` and define :
- `update_inputs` for the inputs logic (not called if message are processing)
- `update_mouse(moved)` for the mouse logic (not called if update_inputs return false or message are processing)
- `update_graphics` to update the graphics animation each frames

### Don't update texts each frame

Text is a heavy process, you should only update it when needed and if the update can change something. Btw, the scene should not manage text objects, it should only manage `UI::ClassName` object that are either `UI::SpriteStack` or `UI::Window` specializations.

### Call the `data=` method of `UI::ClassName` only if the content it shows change.

The PSDK UI system relies on a `data=` method for dynamic text, sprites, stack or window. It allows to tell what to show without writing everything inside the Scene. You should only call this method when index change (`index_changed` method from `GamePlay::Base`) or when the display object has to be changed (update of it's internal info like the item held for a Pokémon).

### Make the method that should not be called outside of the class private

In a class, some methods like `init_ui` should not be called from the exterior (encapsulation). Make them private by putting them at the end of the script after the `private` keyword.

Example :
```ruby
class Thing < GamePlay::BaseCleanUpdate
  def initialize
    super
    init_viewport
    init_ui
  end

  def update_inputs
    # ...
  end

  private

  def init_viewport
    @viewport = Viewport.create(:main, 500)
  end

  def init_ui
    @ui = UI::Thing.new(@viewport)
  end
end
```

### Use `attr_reader` instead of `attr_accessor` and define the `property=` method

This rule has the goal to ensure you validate all the data. For example, setting the HP of a Pokémon should not allow `Float` hp value and has to update the `hp_rate` (to help HP bars).

### Define `property_text` methods instead of using `format` `sprintf` etc...

When a property has to be displayed in a UI, it's better to define a `property_text` method that generate the string the UI should show. This way you reduce the code & code duplication inside the UIs since you only need to add a `SymText` with `:property_text` as parameter.

### Never use `set_` or `get_` name

We did this in the past but it's a bad idea. In the web documentation that separate the methods since they're sorted by name (and it also makes harder for someone to find the method).

Favor the direct property name or `property=` method. If you have specialization like a property that is an Integer ID but you want to return the db_symbol add the specialization after the name of the proprety : `proprety_db_symbol` for example. (Like we did for `property_text`).

### Try to limit the number of lines in one script to 500 or 1000

If the script has too much lines, it's doing too much thing (no Graphics / Logic Separation, God Classes). We should not have such thing if the script is too long (because sometimes it shows various menu for example) you have different way of do the thing :
* Use specialization : The way `Party_Menu` is done is wrong, it's doing too much thing and it should be separated in various specialized classes.
* Split the script in contextual scripts : The solution we took for most script, you can put the initialization in the first script, the update in the second script, mouse specific stuff in the third script etc...
* Make a better seperation of the actions. If your logic is too complicated (like the Battle logic) don't put it in the Scene, make a dedicated classe. When we read the few lines of a script, we should understand what is done without reading the contents of the methods.

