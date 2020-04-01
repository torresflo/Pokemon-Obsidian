#encoding: utf-8

#noyard
class Scene_Battle
  #===
  #>_tutos : déclence des actions pour les tutos
  #===
  def _tuto(id)
    tuto=GameData::Tutos[id]
    set_actions(tuto) if tuto
  end
  #==
  #>set_actions : définition des actions à réaliser
  #===
  def set_actions(arr)
    @Actions_To_DO+=arr
  end
  #===
  #>get_action : retourne l'action à réaliser
  #===
  def get_action
    if(@Actions_To_DO.size>0)
      if(@Actions_Counter==0)
        @Actions_Counter+=1
        act=@Actions_To_DO.shift
        action_interpreter(act)
        return act
      else
        @Actions_Counter+=1
        @Actions_Counter=0 if @Actions_Counter>12
        return true
      end
    end
    return false
  end
  #===
  #>action_interpreter : Interpretation de certaines actions
  #===
  def action_interpreter(act)
    if act.class==Array
      case act[0]
      when :msg
        unless(act[1])
          @message_window.contents.clear
        else
          display_message(act[1],true)
        end
      when :@action_selector
        @action_selector.visible=act[1]
        #@message_window.width=(act[1] ? 201 : 320)
        @Actions_Counter=0
      when :@skill_selector
        @skill_selector.visible=act[1]
        @message_window.visible=!act[1]
        @Actions_Counter=0
      when :@Actions_Counter
        @Actions_Counter=act[1]
      when :@atk_index
        @atk_index=act[1]
        @Actions_Counter=0
      when :select_atk_caract
        pos=0
        actor=@actors[@actor_actions.size]
        actor.skills_set.each_index do |i|
          skill=actor.skills_set[i]
          if skill and skill.atk_class==act[1]
            pos=i
            break
          end
        end
        case pos
        when 0
          @Actions_To_DO=[:A]+@Actions_To_DO
        when 1
          @Actions_To_DO=[:RIGHT,:A]+@Actions_To_DO
        when 2
          @Actions_To_DO=[:DOWN,:A]+@Actions_To_DO
        else
          @Actions_To_DO=[:RIGHT,:DOWN,:A]+@Actions_To_DO
        end
      #>
      end
    end
  end
end
