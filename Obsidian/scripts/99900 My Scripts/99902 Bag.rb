module PFM
	class Bag
        # Check if player is able to catch a Pokémon (has a ball or not)
		def has_any_ball?
            contain_item?(1) || contain_item?(2) || contain_item?(3) || contain_item?(4) || contain_item?(5) || contain_item?(6) || contain_item?(7) || contain_item?(8) || contain_item?(9) || contain_item?(10) || contain_item?(11) || contain_item?(12) || contain_item?(13) || contain_item?(14) || contain_item?(15) || contain_item?(16) || contain_item?(492) || contain_item?(493) || contain_item?(494) || contain_item?(495) || contain_item?(496) || contain_item?(497) || contain_item?(498) || contain_item?(499) || contain_item?(500) || contain_item?(576)
        end
	end
end