begin
  puts 'Loading Game...'
  scripts = Marshal.load(Zlib::Inflate.inflate(File.binread('Data/Scripts.dat')))
  scripts.each { |script| RubyVM::InstructionSequence.load_from_binary(script).eval }
  scripts = nil
  SafeExec.load
  GC.start
rescue StandardError
  display_game_exception('An error occured during Script Loading.')
end
