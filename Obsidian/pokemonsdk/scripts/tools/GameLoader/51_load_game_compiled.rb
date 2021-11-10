begin
  puts 'Loading Game...'
  scripts = Marshal.load(Zlib::Inflate.inflate(File.binread('Data/Scripts.dat')))
  from_launcher = !ENV['GAMEDEPS'].nil?
  scripts.each_with_index do |script, index|
    RubyVM::InstructionSequence.load_from_binary(script).eval
    if from_launcher
      STDOUT.puts "progress: #{index.to_f / scripts.size}"
      STDOUT.flush
    end
  end
  scripts = nil
  SafeExec.load
  GC.start
  if from_launcher
    STDOUT.puts 'close'
    STDOUT.flush
    STDOUT.reopen(IO::NULL)
  end
rescue StandardError
  display_game_exception('An error occured during Script Loading.')
end
