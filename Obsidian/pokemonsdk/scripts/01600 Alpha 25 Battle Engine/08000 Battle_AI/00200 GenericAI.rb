module Battle
  # Module holding the whole AI code
  module AI
    # AI corresponding to the wild Pokemon
    class Wild < Base
      Base.register(0, self)
    end

    # AI corresponding to the youngster & similar trainers (base money < 20)
    class TrainerLv1 < Base
      private

      def init_capability
        super
        @can_see_power = true
      end

      Base.register(1, self)
    end

    # AI corresponding to the bird keeper (base money < 36)
    class TrainerLv2 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
      end

      Base.register(2, self)
    end

    # AI coreresponding to sailor (base money < 48)
    class TrainerLv3 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
        @can_see_move_kind = true
      end

      Base.register(3, self)
    end

    # AI corresponding to gambler (base money < 80)
    class TrainerLv4 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
        @can_see_move_kind = true
        @can_mega_evolve = true
        @can_switch = true
        @can_use_item = true
      end

      Base.register(4, self)
    end

    # AI corresponding to Boss (base money < 100)
    class TrainerLv5 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
        @can_see_move_kind = true
        @can_mega_evolve = true
        @can_switch = true
        @can_use_item = true
        @can_choose_target = true
      end

      Base.register(5, self)
    end

    # AI corresponding to rival, gym leader, elite four (base money < 200)
    class TrainerLv6 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
        @can_see_move_kind = true
        @can_mega_evolve = true
        @can_switch = true
        @can_use_item = true
        @can_choose_target = true
        @can_heal = true
      end

      Base.register(6, self)
    end

    # AI corresponding to champion (base money >= 200)
    class TrainerLv7 < Base
      private

      def init_capability
        super
        @can_see_effectiveness = true
        @can_see_power = true
        @can_see_move_kind = true
        @can_mega_evolve = true
        @can_switch = true
        @can_use_item = true
        @can_choose_target = true
        @can_heal = true
        @can_read_opponent_movepool = true
      end

      Base.register(7, self)
    end

    # AI corresponding to roaming Pokemon
    class RoamingWild < TrainerLv3
      private

      def init_capability
        super
        @can_flee = true
      end

      Base.register(-1, self)
    end
  end
end
