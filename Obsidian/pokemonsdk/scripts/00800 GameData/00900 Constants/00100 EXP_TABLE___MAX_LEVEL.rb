module GameData
  # The maximum level in the Game
  MAX_LEVEL = PSDK_CONFIG.pokemon_max_level
  # The Experience table (common exp curves)
  EXP_TABLE = load_data('Data/Exptable.rxdata') rescue []
  if EXP_TABLE.empty? || EXP_TABLE[0].size < MAX_LEVEL + 1
    log_info 'ExpTable recalculée'
    6.times do |j|
      EXP_TABLE[j] = Array.new(MAX_LEVEL + 1, 0)
      EXP_TABLE[j][0] = nil
    end
    # Fast
    2.upto(MAX_LEVEL) do |i|
      EXP_TABLE[0][i] = Integer(4 * (i**3) / 5)
    end
    # Normal
    2.upto(MAX_LEVEL) do |i|
      EXP_TABLE[1][i] = Integer(i**3)
    end
    # Slow
    2.upto(MAX_LEVEL) do |i|
      EXP_TABLE[2][i] = Integer(5 * (i**3) / 4)
    end
    # Parabolic
    2.upto(MAX_LEVEL) do |i|
      EXP_TABLE[3][i] = Integer((6 * (i**3) / 5 - 15 * (i**2) + 100 * i - 140))
    end
    # Eratic
    2.upto(50) { |i| EXP_TABLE[4][i] = Integer(i**3 * (100 - i) / 50) }
    51.upto(68) { |i| EXP_TABLE[4][i] = Integer(i**3 * (150 - i) / 100) }
    69.upto(98) do |i|
      EXP_TABLE[4][i] = Integer((i**3) * ((1911 - 10 * i) / 3) / 500)
    end
    99.upto(100) { |i| EXP_TABLE[4][i] = Integer(i**3 * (160 - i) / 100) }
    101.upto(MAX_LEVEL) do |i|
      EXP_TABLE[4][i] = Integer(600_000 + 103_364 * (i - 100) + Math.cos(i) * 30_000)
    end
    # Fluctuating
    2.upto(15) { |i| EXP_TABLE[5][i] = Integer(i**3 * (24 + (i + 1) / 3) / 50) }
    16.upto(35) { |i| EXP_TABLE[5][i] = Integer(i**3 * (14 + i) / 50) }
    36.upto(MAX_LEVEL) { |i| EXP_TABLE[5][i] = Integer(i**3 * (32 + (i / 2)) / 50) }
    save_data(EXP_TABLE, 'Data/Exptable.rxdata')
  end
end
