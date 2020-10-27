module Repository
  # Save a class/module in the repository
  # @param name [Symbol] name of the object
  # @param priority [Integer] priority of the object (last decision) higher or equal means better chance to be the saved object
  # @param object [Module] Any class / module
  def declare(name, priority, object)
    current_priority = @repository.dig(name, :priority) || -1
    return if current_priority > priority

    @repository[name] = { object: object, priority: priority }
  end

  # Find a class/module from the repository
  # @param name [Symbol] name of the object
  def find(name)
    return @repository.dig(name, :object)
  end

  # Method called when extend Repository is written in a module
  # @param mod [Module] module that will receive the extended methods
  def self.extended(mod)
    mod.instance_variable_set(:@repository, {})
  end
end

module PFM
  extend Repository
end

module UI
  extend Repository
end

module GameData
  extend Repository
end

module GamePlay
  extend Repository
end
