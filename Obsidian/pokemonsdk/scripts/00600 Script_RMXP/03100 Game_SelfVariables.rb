#encoding: utf-8

# Hash gérant les variables locales. Des variables propres à l'évènement, 
# Permet de ne pas devoir utiliser de variable de jeu pour gérer ce qui est propre
# à un évènement
# Dans les scrpit, la variable globale $game_self_variables contient les variables
# locales
# 
# @note This script should be after Interpreter 7
# @author Leikt
class Game_SelfVariables
  # Default initialization
  def initialize
    @data = {}
  end
  # Fetch the value of a self variable
  # @param key [Array] the key that identify the self variable
  # @return [Object]
  def [](key)
    return @data[key]
  end
  # Set the value of a self variable
  # @param key [Array] the key that identify the self variable
  # @param value [Object] the new value
  def []=(key, value)
    @data[key] = value
  end
  # Perform an action on the specific variable and return the result
  # @param key [Array] the key that identify the self variable
  # @param operation [Symbol] symbol of the operation to do on the variable
  # @param value [Object] value associated to the operation
  def do(key, operation=nil, value=nil)
    @data[key]=0 unless @data.has_key?(key)
    case operation
    when :set
        @data[key]=value
    when :del
        @data.delete(key)

    # Numeric
    when :add
        @data[key]+=value
    when :sub
        @data[key]-=value
    when :div
        @data[key]/=value
    when :mul
        @data[key]*=value
    when :mod
        @data[key]=@data[key]%value
    when :count
        @data[key]+=1
    when :uncount
        @data[key]-=1

    # Boolean
    when :toggle
        @data[key]=!@data[key]
    when :and
        @data[key]=(@data[key] and value)
    when :or
        @data[key]=(@data[key] or value)
    when :xor
        @data[key]=(@data[key]^value)
    end
    # Return the data
    return @data[key]
  end
end

class Interpreter < Interpreter_RMXP
  # @note Details here : https://pokemonworkshop.com/forum/index.php?topic=3770.msg109814#msg109814
  # @overload get_local_variable(id_var)
  #   Get a local variable
  #   @param id_var [Symbol] the id of the variable
  # @overload get_local_variable(id_var, operation, value = nil)
  #   Perform an operation on a local variable and get the result
  #   @param id_var [Symbol] the id of the variable
  #   @param operation [Symbol] symbol of the operation to do on the variable
  #   @param value [Object] value associated to the operation
  # @overload get_local_variable(id_event, id_var)
  #   Get a local variable of a specific event
  #   @param id_event [Integer] the id of the event
  #   @param id_var [Symbol] the id of the variable
  # @overload get_local_variable(id_event, id_var, operation, value = nil)
  #   Perform an operation on a local variable of an specific event and get the result
  #   @param id_event [Integer] the id of the event
  #   @param id_var [Symbol] the id of the variable
  #   @param operation [Symbol] symbol of the operation to do on the variable
  #   @param value [Object] value associated to the operation
  # @overload get_local_variable(id_map, id_event, id_var)
  #   Get a local variable of a specific event on a specific map
  #   @param id_map [Integer] the id of the map
  #   @param id_event [Integer] the id of the event
  #   @param id_var [Symbol] the id of the variable
  # @overload get_local_variable(id_map, id_event, id_var, operation, value = nil)
  #   Perform an operation on a local variable of an specific event on a specific map and get the result
  #   @param id_map [Integer] the id of the map
  #   @param id_event [Integer] the id of the event
  #   @param id_var [Symbol] the id of the variable
  #   @param operation [Symbol] symbol of the operation to do on the variable
  #   @param value [Object] value associated to the operation
  # @return [Object]
  def get_local_variable(*args)
    if args.first.is_a?(Symbol) # [var_loc, operation, value]
      return $game_self_variables.do([@map_id, @event_id, args.first], args[1], args[2])
    elsif args[1].is_a?(Integer)# [map_id, event_id, var_loc, operation, value]
      return $game_self_variables.do([args.first, args[1], args[2]], args[3], args[4])
    else # [event_id, var_loc, operation, value]
      return $game_self_variables.do([@map_id, args.first, args[1]], args[2], args[3])
    end
    return nil
  end
  alias VL get_local_variable
  alias LV get_local_variable

  # Set a local variable
  # @param value [Object] the new value of the variable
  # @param id_var [Symbol] the id of the variable
  # @param id_event [Integer] the id of the event
  # @param id_map [Integer] the id of the map
  def set_local_variable(value, id_var, id_event = @event_id, id_map = @map_id)
    key = [id_map, id_event, id_var]
    $game_self_variables[key] = value
  end
  alias set_VL set_local_variable
  alias set_LV set_local_variable
end
