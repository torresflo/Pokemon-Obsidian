module Yuki
  module Animation
    # Class handling several animation at once
    class Handler < Hash
      # Update all the animations
      def update
        each_value(&:update)
        delete_if { |_, v| v.done? }
      end

      # Tell if all animation are done
      def done?
        all? { |_, v| v.done? }
      end
    end
  end
end
