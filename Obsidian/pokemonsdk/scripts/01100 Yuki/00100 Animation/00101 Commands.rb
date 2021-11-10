module Yuki
  module Animation
    module_function

    # Class executing commands for animations (takes 0 seconds to proceed and then needs no time information)
    # @note This class inherit from TimedAnimation to allow composition with it but it overwrite some components
    # @note Animation inheriting from this class has a `update_internal` with no parameters!
    class Command < TimedAnimation
      # Create a new Command
      def initialize
        @sub_animation = nil
        @parallel_animations = []
        @root = self # We make self as default root so the animations will always have a root
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        # Start all the parallel animation
        @parallel_animations.each { |animation| animation.start(begin_offset) }
        # Start the sub animation
        @sub_animation&.start(begin_offset)
        # Boolean telling if the animation has been processed until the end (to prevent some display error)
        @played_until_end = false
      end

      # Update the animation internal time and call update_internal with no parameter
      # @note should always be called after start
      def update
        return if done?
        @parallel_animations.each(&:update)
        # Update the sub animation if the current animation is actually done
        if private_done?
          unless @played_until_end
            @played_until_end = true
            update_internal
          end
          return unless @parallel_animations.all?(&:done?)
          return @sub_animation&.update
        end
      end

      private

      # Indicate if this animation in particular is done (not the parallel, not the sub, this one)
      # @return [Boolean]
      def private_done?
        true
      end

      # Indicate if this animation in particular has started
      def private_began?
        true
      end

      # Perform the animation action
      def update_internal
        # Does nothing
      end
    end

    # Play a BGM
    # @param filename [String] name of the file inside Audio/BGM
    # @param volume [Integer] volume to play the bgm
    # @param pitch [Integer] pitch used to play the bgm
    def bgm_play(filename, volume = 100, pitch = 100)
      AudioCommand.new(:bgm_play, filename, volume, pitch)
    end

    # Stop the bgm
    def bgm_stop
      AudioCommand.new(:bgm_stop)
    end

    # Play a BGS
    # @param filename [String] name of the file inside Audio/BGS
    # @param volume [Integer] volume to play the bgs
    # @param pitch [Integer] pitch used to play the bgs
    def bgs_play(filename, volume = 100, pitch = 100)
      AudioCommand.new(:bgs_play, filename, volume, pitch)
    end

    # Stop the bgs
    def bgs_stop
      AudioCommand.new(:bgs_stop)
    end

    # Play a ME
    # @param filename [String] name of the file inside Audio/ME
    # @param volume [Integer] volume to play the me
    # @param pitch [Integer] pitch used to play the me
    def me_play(filename, volume = 100, pitch = 100)
      AudioCommand.new(:me_play, filename, volume, pitch)
    end

    # Play a SE
    # @param filename [String] name of the file inside Audio/SE
    # @param volume [Integer] volume to play the se
    # @param pitch [Integer] pitch used to play the se
    def se_play(filename, volume = 100, pitch = 100)
      AudioCommand.new(:se_play, filename, volume, pitch)
    end

    # Animation command responsive of playing / stopping audio.
    # It sends the type command to Audio with *args as parameter.
    #
    # Example: Playing a SE
    #   AudioCommand.new(:se_play, 'audio/se/filename', 80, 80)
    class AudioCommand < Command
      # Create a new AudioCommand
      # @param type [Symbol] name of the method of Audio to call
      # @param args [Array] parameter to send to the command
      def initialize(type, *args)
        super()
        @type = type
        @args = args
        @args.each_with_index { |arg, i| @args[i] = resolve(arg) }
        @args[0] &&= 'Audio/' + @type.to_s.sub('_play', '') + '/' + @args.first
      end

      private

      # Execute the audio command
      def update_internal
        Audio.send(@type, *@args)
      end
    end

    # Create a new sprite
    # @param viewport [Symbol] viewport to use inside the resolver
    # @param name [Symbol] name of the sprite inside the resolver
    # @param type [Class] class to use in order to create the sprite
    # @param args [Array] argument to send to the sprite in order to create it (sent after viewport)
    # @param properties [Array<Array>] list of properties to call with their values
    def create_sprite(viewport, name, type, args = nil, *properties)
      SpriteCreationCommand.new(viewport, name, type, args, *properties)
    end

    # Animation command responsive of creating sprites and storing them inside the resolver
    #
    # Example :
    #   SpriteCreationCommand.new(:main, :star1, SpriteSheet, [1, 3], [:select, 0, 1], [:set_position, 160, 120])
    #   # This will create a spritesheet at the coordinate 160, 120 and display the cell 0,1
    class SpriteCreationCommand < Command
      # Create a new SpriteCreationCommand
      # @param viewport [Symbol] viewport to use inside the resolver
      # @param name [Symbol] name of the sprite inside the resolver
      # @param type [Class] class to use in order to create the sprite
      # @param args [Array] argument to send to the sprite in order to create it (sent after viewport)
      # @param properties [Array<Array>] list of properties to call with their values
      def initialize(viewport, name, type, args, *properties)
        super()
        @viewport = viewport
        @name = name
        @type = type
        @args = args
        @properties = properties
      end

      private

      # Execute the sprite creation command
      def update_internal
        sprite = @type.new(resolve(@viewport), *@args)
        @properties.each { |property| sprite.send(*property) }
        @resolver.receiver[@name] = sprite
      end
    end

    # Send a command to an object in the resolver
    # @param name [Symbol] name of the object in the resolver
    # @param command [Symbol] name of the method to call
    # @param args [Array] arguments to send to the method
    def send_command_to(name, command, *args)
      ResolverObjectCommand.new(name, command, *args)
    end

    # Dispose a sprite
    # @param name [Symbol] name of the sprite in the resolver
    def dispose_sprite(name)
      ResolverObjectCommand.new(name, :dispose)
    end

    # Animation command that sends a message to an object in the resolver
    #
    # Example :
    #   ResolverObjectCommand.new(:star1, :set_position, 0, 0)
    #   # This will call set_position(0, 0) on the star1 object in the resolver
    class ResolverObjectCommand < Command
      # Create a new ResolverObjectCommand
      # @param name [Symbol] name of the object in the resolver
      # @param command [Symbol] name of the method to call
      # @param args [Array] arguments to send to the method
      def initialize(name, command, *args)
        super()
        @name = name
        @command = command
        @args = args
      end

      private

      # Execute the command
      def update_internal
        resolve(@name).send(@command, *@args)
      end
    end

    # Try to run commands during a specific duration and giving a fair repartition of the duraction for each commands
    # @note Never put dispose command inside this command, there's risk that it does not execute
    # @param duration [Float] number of seconds (with generic time) to process the animation
    # @param animation_commands [Array<Command>]
    def run_commands_during(duration, *animation_commands)
      TimedCommands.new(duration, *animation_commands)
    end

    # Animation that try to execute all the given command at total_time / n_command * command_index
    # Example :
    #   TimedCommands.new(1,
    #     create_sprite(:main, :star1, SpriteSheet, [1, 3], [:select, 0, 0]),
    #     send_command_to(:star1, :select, 0, 1),
    #     send_command_to(:star1, :select, 0, 2),
    #   )
    #   # Will create the start at 0
    #   # Will set the second cell at 0.33
    #   # Will set the third cell at 0.66
    # @note It'll skip all the commands that are not SpriteCreationCommand if it's "too late"
    class TimedCommands < DiscreetAnimation
      # Create a new TimedCommands object
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param animation_commands [Array<Command>]
      def initialize(time_to_process, *animation_commands)
        raise 'TimedCommands requires at least one command' if animation_commands.empty?
        super(time_to_process, self, :run_command, 0, animation_commands.size - 1)
        @animation_commands = animation_commands
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        @animation_commands.each { |cmd| cmd.start(begin_offset) }
        @last_command = nil
      end

      # Define the resolver (and transmit it to all the childs / parallel)
      # @param resolver [#call] callable that takes 1 parameter and return an object
      def resolver=(resolver)
        super
        @animation_commands.each { |animation| animation.resolver = resolver }
      end

      private

      # Execute a command
      # @param index [Integer] index of the command
      def run_command(index)
        if index != @last_command
          @last_command ||= 0
          # Try to execute all the commands that are SpriteCreationCommand and that was not processed
          (@last_command + 1).upto(index - 1) do |command_index|
            @animation_commands[command_index].update if @animation_commands[command_index].is_a?(SpriteCreationCommand)
          end
          @animation_commands[index].update
          @last_command = index
        end
      end
    end
  end
end
