module GameData
  # Kind of item allowing to flee wild battles
  class FleeingItem < Item
  end
end

safe_code('Register FleeingItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::FleeingItem) do
    !$game_temp.in_battle
  end
  PFM::ItemDescriptor.define_bag_use(GameData::FleeingItem, true) do |item, scene|
    GamePlay.bag_mixin.from(scene).battle_item_wrapper = PFM::ItemDescriptor.actions(item.id)
    $scene = scene.__last_scene # This prevent the message from displaying now
  end
end
