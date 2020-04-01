#encoding: utf-8

# Module that contain helpers for various scripts
module Util
  # Item Helper
  # @author Nuri Yuri
  module Item
    # Use an item in a GamePlay::Base child class
    # @param item_id [Integer] ID of the item in the database
    def util_item_useitem(item_id, &result_process)
      #>Récupération des données d'actions de l'objet
      extend_data = ::PFM::ItemDescriptor.actions(item_id)
      #> Vérification des messages
      if(extend_data[:chen])
        display_message(parse_text(22, 43))
        return false
      elsif(extend_data[:no_effect])
        display_message(parse_text(22, 108))
        return false
      end
      #> Si l'objet demande l'ouverture de l'interface de l'équipe
      if(extend_data[:open_party])
        @__result_process = proc do |scene|
          if $game_temp.in_battle && scene.return_data != -1
            @return_data = [item_id, extend_data, scene.return_data]
            @running = false
            next
          end
          $bag.remove_item(item_id, 1) if GameData::Item.limited_use?(item_id) and scene.return_data != -1
          result_process&.call
        end
        call_scene(GamePlay::Party_Menu, @team ? @team : $actors, :item, extend_data, no_leave: false)
        return false unless @running
      #> Si utilisation classique
      elsif(extend_data[:on_use])
        if(extend_data[:use_before_telling])
          if(extend_data[:on_use].call != :unused)
            $bag.remove_item(item_id, 1) if GameData::Item.limited_use?(item_id)
            display_message(parse_text(22, 46, ::PFM::Text::TRNAME[0] => $trainer.name, 
              ::PFM::Text::ITEM2[1] => GameData::Item.name(item_id))) if $scene == self
            return extend_data
          end
          return false
        end
        $bag.remove_item(item_id, 1) if GameData::Item.limited_use?(item_id)
        display_message(parse_text(22, 46, ::PFM::Text::TRNAME[0] => $trainer.name, 
          ::PFM::Text::ITEM2[1] => GameData::Item.name(item_id)))
        extend_data[:on_use].call
      elsif(extend_data[:action_to_push] || extend_data[:ball_data])
        @return_data = [item_id, extend_data, false]
        @running = false
      end
      return extend_data
    end
    #====
  end
end
