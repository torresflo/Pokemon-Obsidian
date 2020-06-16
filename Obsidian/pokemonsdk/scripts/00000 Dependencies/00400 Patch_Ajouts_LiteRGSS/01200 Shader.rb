module LiteRGSS
  class Shader
    FALLBACK_SHADER = <<-EOFALLBACKSHADER
    // Viewport tone (required)
    uniform vec4 tone;
    // Viewport color (required)
    uniform vec4 color;
    // Gray scale transformation vector
    const vec3 lumaF = vec3(.299, .587, .114);
    // Texture source
    uniform sampler2D texture;
    // Main process
    void main()
    {
      vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
      // Tone&Color process
      frag.rgb = mix(frag.rgb, color.rgb, color.a);
      float luma = dot(frag.rgb, lumaF);
      frag.rgb += tone.rgb;
      frag.rgb = mix(frag.rgb, vec3(luma), tone.w);
      frag.a *= gl_Color.a;
      // Result
      gl_FragColor = frag;
    }
    EOFALLBACKSHADER
    # Load a shader data from a file
    # @param filename [String] name of the file in Graphics/Shaders
    # @return [String] the shader string
    def self.load_to_string(filename)
      return File.read("graphics/shaders/#{filename.downcase}.txt")
    rescue StandardError
      log_error("Failed to load shader #{filename}, sprite using this shader will not display correctly")
      return FALLBACK_SHADER
    end
    # General Shader of Sprite that need color mix
    GeneralColorSprite = load_to_string('GenColorSprite')
  end
end
