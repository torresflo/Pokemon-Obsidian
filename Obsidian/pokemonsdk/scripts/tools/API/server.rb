require 'webrick'
require 'json'

def start_api_server(config = {})
  config[:Port] ||= 8080
  server = WEBrick::HTTPServer.new(config)
  yield server if block_given?
  %w[INT TERM].each { |signal| trap(signal) { server.shutdown } }
  server.start
end

ScriptLoader.load_tool('API/RestServlet')
ScriptLoader.load_tool('API/DirServlet')

start_api_server do |server|
  server.mount('/dir', DirServlet)
end
