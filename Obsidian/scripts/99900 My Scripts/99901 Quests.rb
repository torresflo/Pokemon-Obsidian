module PFM
	class Quests
		# Hide a goal of a quest
		# @param quest_id [Integer] the ID of the quest in the database
		# @param goal_index [Integer] the index of the goal in the goal order
		def hide_goal(quest_id, goal_index)
			return if (quest = @active_quests.fetch(quest_id, nil)).nil?
			quest[:shown][goal_index] = false
		end
	end
end