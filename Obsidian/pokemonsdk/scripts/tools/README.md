# What is the `tools` folder ?

This folder contain a lot of scripts that can be used to perform some tasks. For example, there's the folder `GameData/GameData2JSON` that contain scripts that helps to convert the `PSDK` data to JSON file.

# How to use the scripts in the tools folder ?

You'll need to load the scripts using the following script command :
```ruby
ScriptLoader.load_tool(relative_path)
```
In this command relative_path is the path to the script from the `pokemonsdk/scripts/tools` folder.

Once done, you can use what the script define.