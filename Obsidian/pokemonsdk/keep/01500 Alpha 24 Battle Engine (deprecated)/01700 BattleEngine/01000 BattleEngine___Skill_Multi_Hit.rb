#encoding: utf-8

#noyard
module BattleEngine
	module_function

  # Beat Up skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_beat_up(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    result = true
    if ::GameData::Flag_4G
      skill.power2 = 10
      allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
      allies.each do |launcher|
        next if launcher.status != 0
        skill.type2 = launcher.type_dark? ? nil : 0
        hp = _damage_calculation(launcher, target, skill).to_i
        result &= __s_hp_down_check(hp, target)
      end
    else
      allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
      allies.each do |ally|
        skill.power2 = (ally.atk_basis / 10) + 5
        hp = _damage_calculation(launcher, target, skill).to_i
        result &= __s_hp_down_check(hp, target)
      end
    end
    skill.power2 = nil
    skill.type2 = nil
    _mp(MSG_Fail) unless result
  end

end