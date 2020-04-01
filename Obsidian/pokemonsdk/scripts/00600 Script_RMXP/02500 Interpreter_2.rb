class Interpreter_RMXP
  # Execute a command of the current event
  def execute_command
    # We execute the fiber if it exists
    return @fiber.resume if @fiber
    # We stop interpretation if we reached the end of the list
    if @index >= @list.size - 1
      command_end
      return true
    end
    # We store the parameters in @parameters
    @parameters = @list[@index].parameters
    method_name = COMMAND_TRANSLATION[@list[@index].code]
    return true unless method_name
    return send(method_name)
  end

  # Command that end the interpretation of the current event
  def command_end
    # 実行内容リストをクリア
    @list = nil
    # メインのマップイベント かつ イベント ID が有効の場合
    if @main and @event_id > 0
      # イベントのロックを解除
      $game_map.events[@event_id].unlock
    end
  end

  # Command that skip the next commands until it find a command with the same indent
  def command_skip
    # インデントを取得
    indent = @list[@index].indent
    # ループ
    loop do
      # 次のイベントコマンドが同レベルのインデントの場合
      if @list[@index+1].indent == indent
        # 継続
        return true
      end
      # インデックスを進める
      @index += 1
    end
  end

  # Command that retrieve a Game_Character object
  # @param parameter [Integer, Symbol] > 0 : id of the event, 0 : current event, -1 : player or follower, Symbol : alias
  # @return [Game_Event, Game_Player, Game_Character]
  def get_character(parameter)
    # Get the character from alias if the parameter is a Symbol
    parameter = $game_map.events_sym_to_id[parameter] if parameter.is_a?(Symbol)
    # パラメータで分岐
    case parameter
    when -1 # プレイヤー
      if $game_variables[Yuki::Var::FM_Sel_Foll] > 0
        return Yuki::FollowMe.get_follower($game_variables[Yuki::Var::FM_Sel_Foll] - 1)
      end
      return $game_player
    when 0  # このイベント
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else # 特定のイベント
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end

  # Command that retrieve a value and negate it if wanted
  # @param operation [Integer] if 1 negate the value
  # @param operand_type [Integer] if 0 takes operand, otherwise take the game variable n°operand
  # @param operand [Integer] the value or index
  def operate_value(operation, operand_type, operand)
    # オペランドを取得
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # 操作が [減らす] の場合は符号を反転
    if operation == 1
      value = -value
    end
    # value を返す
    return value
  end

  # Hash containing the command translation from code to method name
  COMMAND_TRANSLATION = {
    101 => :command_101,
    102 => :command_102, 402 => :command_402, 403 => :command_403,
    103 => :command_103,
    104 => :command_104,
    105 => :command_105,
    106 => :command_106,
    111 => :command_111, 411 => :command_411,
    112 => :command_112, 413 => :command_413,
    113 => :command_113,
    115 => :command_115,
    116 => :command_116,
    117 => :command_117,
    118 => :command_118,
    119 => :command_119,
    121 => :command_121,
    122 => :command_122,
    123 => :command_123,
    124 => :command_124,
    125 => :command_125,
    126 => :command_126,
    127 => :command_127,
    128 => :command_128,
    129 => :command_129,
    131 => :command_131,
    132 => :command_132,
    133 => :command_133,
    134 => :command_134,
    135 => :command_135,
    136 => :command_136,
    201 => :command_201,
    202 => :command_202,
    203 => :command_203,
    204 => :command_204,
    205 => :command_205,
    206 => :command_206,
    207 => :command_207,
    208 => :command_208,
    209 => :command_209,
    210 => :command_210,
    221 => :command_221,
    222 => :command_222,
    223 => :command_223,
    224 => :command_224,
    225 => :command_225,
    231 => :command_231,
    232 => :command_232,
    233 => :command_233,
    234 => :command_234,
    235 => :command_235,
    236 => :command_236,
    241 => :command_241,
    242 => :command_242,
    245 => :command_245,
    246 => :command_246,
    247 => :command_247,
    248 => :command_248,
    249 => :command_249,
    250 => :command_250,
    251 => :command_251,
    301 => :command_301, 601 => :command_601, 602 => :command_602, 603 => :command_603,
    302 => :command_302,
    303 => :command_303,
    311 => :command_311,
    312 => :command_312,
    313 => :command_313,
    314 => :command_314,
    315 => :command_315,
    316 => :command_316,
    317 => :command_317,
    318 => :command_318,
    319 => :command_319,
    320 => :command_320,
    321 => :command_321,
    322 => :command_322,
    331 => :command_331,
    332 => :command_332,
    333 => :command_333,
    334 => :command_334,
    335 => :command_335,
    336 => :command_336,
    337 => :command_337,
    338 => :command_338,
    339 => :command_339,
    340 => :command_340,
    351 => :command_351,
    352 => :command_352,
    353 => :command_353,
    354 => :command_354,
    355 => :command_355
  }
end
