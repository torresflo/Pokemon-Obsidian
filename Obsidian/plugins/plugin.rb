ScriptLoader.load_tool('PluginManager')
argv = ARGV.reject { |arg| arg.start_with?('-') }
if argv[0] == 'build' && argv[1]
  argv[1..].each { |name| PluginManager.start(:build, name) }
elsif argv[0] == 'load'
  PluginManager.start(:load)
elsif argv[0] == 'list'
  PluginManager.start(:list)
else
  puts 'Unknown arguments'
  puts 'Possible calls:'
  puts 'game --util=plugin build <name> [...other_names]'
  puts 'game --util=plugin load'
  puts 'game --util=plugin list'
end