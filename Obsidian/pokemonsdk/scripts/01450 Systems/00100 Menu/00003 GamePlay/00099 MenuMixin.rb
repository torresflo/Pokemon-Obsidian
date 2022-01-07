module GamePlay
  # Module defining the IO of the menu scene so user know what to expect
  module MenuMixin
    # Get the process that is executed when a skill is used somewhere
    # @return [Array, Proc]
    attr_accessor :call_skill_process

    # Execute the skill process
    def execute_skill_process
      return unless @call_skill_process

      case @call_skill_process
      when Array
        return if @call_skill_process.empty?

        block = @call_skill_process.shift
        block.call(*@call_skill_process)
        @call_skill_process = nil
      when Proc
        @call_skill_process.call
        @call_skill_process = nil
      end
    end
  end
end

GamePlay.menu_mixin = GamePlay::MenuMixin
