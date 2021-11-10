ScriptLoader.load_tool('StateMachineBuilder/StateMachineBuilder')
argv = ARGV.reject { |arg| arg.start_with?('-') }
if argv[0]
  argv.each { |filename| StateMachineBuilder.run(filename) }
end