module PFM
  class Pokemon
    # Tell if the Pokemon likes flavor
    def flavor_liked?(flavor)
      return false if no_preferences?

      return GameData::Flavors::LIKED_FLAVORS[flavor].include?(nature_id)
    end

    # Tell if the Pokemon dislikes flavor
    def flavor_disliked?(flavor)
      return false if no_preferences?

      return GameData::Flavors::DISLIKED_FLAVORS[flavor].include?(nature_id)
    end

    # Check if the Pokemon has a nature with no preferences
    def no_preferences?
      return GameData::Flavors::NO_PREF_NATURES.include?(nature_id)
    end
  end
end
