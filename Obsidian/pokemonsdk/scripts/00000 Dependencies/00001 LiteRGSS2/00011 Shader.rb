raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Shader loaded applicable to a Sprite/Viewport or Graphics
#
# Special features:
#   Shader.register(name_sym, frag_file, vert_file = nil, tone_process: false, color_process: false, alpha_process: false)
#     This function registers a shader as name name_sym
#       if frag_file contains `void main()` it'll assume its the file contents of the shader
#       otherwise it'll assume it's the filename and load it from disc
#       if vert_file is nil, it won't load the vertex shader
#       if vert_file contains `void main()` it'll assume it's the file contents of the shader
#       otherwise it'll assume it's the filename and load it from disc
#       tone_process adds tone process to the shader (fragment color needs to be called frag), it'll add the required constant and uniforms (tone)
#       color_process adds the color process to the shader (fragment color needs to be called frag), it'll add the required uniforms (color)
#       alpha_process adds the alpha process to the shader (fragment color needs to be called frag), it'll use gl_Color.a
#   Shader.create(name_sym)
#     This function instanciate a shader by it's name_sym so you don't have to load the files several time and you have all the correct data
# @note `#version 120` will be automatically added to the begining of the file if not present
class Shader < LiteRGSS::Shader
  SHADER_VERSION = PSDK_RUNNING_UNDER_MAC ? "#version 120\n" : "#version 130\n"
  COLOR_UNIFORM = "\\0uniform vec4 color;\n"
  COLOR_PROCESS = "\n  frag.rgb = mix(frag.rgb, color.rgb, color.a);\\0"
  TONE_UNIFORM = "\\0uniform vec4 tone;\nconst vec3 lumaF = vec3(.299, .587, .114);\n"
  TONE_PROCESS = "\n  float luma = dot(frag.rgb, lumaF);\n  frag.rgb = mix(frag.rgb, vec3(luma), tone.w);\n  frag.rgb += tone.rgb;\\0"
  ALPHA_PROCESS = "\n  frag.a *= gl_Color.a;\\0"
  DEFAULT_SHADER = <<~EODEFAULTSHADER
    #{SHADER_VERSION}
    uniform sampler2D texture;
    void main() {
      vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
      gl_FragColor = frag;
    }
  EODEFAULTSHADER
  SHADER_CONTENT_DETECTION = 'void main()'
  SHADER_VERSION_DETECTION = '#version '
  SHADER_FRAG_FEATURE_ADD = /\n( |)+gl_FragColor( |)+=/
  SHADER_UNIFORM_ADD = /#version[^\n]+\n/
  # List of registered shaders
  @registered_shaders = {}

  class << self
    # Register a new shader by it's name
    # @param name_sym [Symbol] name of the shader
    # @param frag_file [String] file content or filename of the frag shader, the function will look at void main() to know
    # @param vert_file [String] file content or filename of the vertex shader, the function will look at void main() to know
    # @param tone_process [Boolean] if the function should add tone_process to the shader
    # @param color_process [Boolean] if the function should add color_process to the shader
    # @param alpha_process [Boolean] if the function should add alpha_process to the shader
    def register(name_sym, frag_file, vert_file = nil, tone_process: false, color_process: false, alpha_process: false)
      frag = load_shader_file(frag_file)
      vert = vert_file && load_shader_file(vert_file)
      frag = add_frag_color(frag) if color_process
      frag = add_frag_tone(frag) if tone_process
      frag = add_frag_alpha(frag) if alpha_process

      @registered_shaders[name_sym] = [vert, frag].compact
    end

    # Function that creates a shader by its name
    # @param name_sym [Symbol] name of the shader
    # @return [Shader]
    def create(name_sym)
      Shader.new(*@registered_shaders[name_sym])
    end

    # Load a shader data from a file
    # @param filename [String] name of the file in Graphics/Shaders
    # @return [String] the shader string
    def load_to_string(filename)
      log_error('Calling Shader.load_to_string is deprecated, please use Shader.create(name) instead to get the right shader.
The game will sleep 10 seconds to make sure you see this message')
      sleep(10)
      return File.read("graphics/shaders/#{filename.downcase}.txt")
    rescue StandardError
      log_error("Failed to load shader #{filename}, sprite using this shader will not display correctly")
      return @registered_shaders[:full_shader]&.last || DEFAULT_SHADER
    end

    private

    # Function that loads the shader file
    # @param filecontent_or_name [String]
    # @return [String]
    def load_shader_file(filecontent_or_name)
      contents = filecontent_or_name.include?(SHADER_CONTENT_DETECTION) ? filecontent_or_name : File.read(filecontent_or_name)
      return SHADER_VERSION + contents unless contents.include?(SHADER_VERSION_DETECTION)

      return contents
    end

    # Function that adds the color processing to shader
    # @param shader [String] shader code
    # @return [String]
    def add_frag_color(shader)
      return shader.sub(SHADER_UNIFORM_ADD, COLOR_UNIFORM).sub(SHADER_FRAG_FEATURE_ADD, COLOR_PROCESS)
    end

    # Function that adds the tone processing to shader
    # @param shader [String] shader code
    # @return [String]
    def add_frag_tone(shader)
      return shader.sub(SHADER_UNIFORM_ADD, TONE_UNIFORM).sub(SHADER_FRAG_FEATURE_ADD, TONE_PROCESS)
    end

    # Function that adds the alpha processing to shader
    # @param shader [String] shader code
    # @return [String]
    def add_frag_alpha(shader)
      return shader.sub(SHADER_FRAG_FEATURE_ADD, ALPHA_PROCESS)
    end
  end

  safe_code('Default shader loading') do
    Graphics.on_start do
      background_color_shader = DEFAULT_SHADER.sub(SHADER_FRAG_FEATURE_ADD, "\n  frag.a = max(frag.a, color.a);\\0")
      register(:map_shader, background_color_shader, tone_process: true, color_process: true)
      register(:tone_shader, DEFAULT_SHADER, tone_process: true, alpha_process: true)
      register(:color_shader, DEFAULT_SHADER, color_process: true, alpha_process: true)
      register(:color_shader_with_background, background_color_shader, color_process: true, alpha_process: true)
      register(:full_shader, DEFAULT_SHADER, tone_process: true, color_process: true, alpha_process: true)
      register(:yuki_circular, 'graphics/shaders/yuki_transition_circular.txt')
      register(:yuki_directed, 'graphics/shaders/yuki_transition_directed.txt')
      register(:yuki_weird, 'graphics/shaders/yuki_transition_weird.txt')
      register(:blur, 'graphics/shaders/blur.txt')
      register(:battle_shadow, 'graphics/shaders/battle_shadow.frag', 'graphics/shaders/battle_shadow.vert')
      register(:battle_backout, 'graphics/shaders/battle_backout.frag')
      register(:graphics_transition, Graphics::TRANSITION_FRAG_SHADER)
      register(:graphics_transition_static, Graphics::STATIC_TRANSITION_FRAG_SHADER)
    end
  end
end
