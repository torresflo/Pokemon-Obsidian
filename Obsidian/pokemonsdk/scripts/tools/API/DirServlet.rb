# REST servlet responsive of giving information about files
class DirServlet < RestServlet
  ENDPOINTS = {
    %r{^/dir/$} => {
      get: :dir_location_get,
      post: :dir_location_post,
      id: '/dir/',
      description: 'Dir status of the current opened game'
    }
  }

  # Get location of the current game dir
  # @param request [WEBrick::HTTPRequest]
  # @return [Array(Integer, String)]
  def dir_location_get(request)
    return 200, Dir.pwd
  end

  # Set current location of the game dir
  # @param request [WEBrick::HTTPRequest]
  # @return [Array(Integer, Hash)]
  def dir_location_post(request)
    dir = JSON.parse(request.body).gsub('\\', '/')
    return 404, { error: 'Directory not found!' } unless Dir.exist?(dir)
    return 403, { error: 'Directory is not readable!' } unless File.readable?(dir)
    return 403, { error: 'Directory is not writable!' } unless File.writable?(dir)
    unless File.exist?(File.join(dir, 'Game.rxproj'))
      return 404, { error: 'Game.rxproj not found in desired directory!' }
    end

    Dir.chdir(dir)
    return 200, true
  end
end
