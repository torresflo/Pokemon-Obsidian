class Interpreter
	#trainer_eye_sequence_2('Hello!', eye_bgm: 'audio/bgm/pkmrs-enc7')

	def trainer_eye_sequence_2(phrase, eye_bgm: DEFAULT_EYE_BGM, exclamation_se: DEFAULT_EXCLAMATION_SE)
		character = get_character(@event_id)
		character.turn_toward_player
		front_coordinates = $game_player.front_tile
		# Unless the player triggered the event we show the exclamation
		unless character.x == front_coordinates.first && character.y == front_coordinates.last
		  Audio.se_play(*exclamation_se)
		  emotion(:exclamation)
		  EXCLAMATION_PARTICLE_DURATION.times do
			$game_player.update
			$scene.spriteset.update
			Graphics.update
		  end
		end
		Audio.bgm_play(*eye_bgm, 80, 100, false)
		# We move to the trainer
		while (($game_player.x - character.x).abs + ($game_player.y - character.y).abs) > 1
		  character.move_toward_player
		  while character.moving?
			$game_map.update
			$scene.spriteset.update
			Graphics.update
		  end
		end
		$game_player.turn_toward_character(character)
		# We do the speech
		@message_waiting = true
		$scene.display_message(phrase)
		@message_waiting = false
		@wait_count = 2
	end
end