class Object
  # Array representing an empty optional key hash
  EMPTY_OPTIONAL = [].freeze
  # Default error message
  VALIDATE_PARAM_ERROR = 'Parameter %<param_name>s sent to %<method_name>s is incorrect : %<reason>s'
  # Exception message
  EXC_MSG = 'Invalid param value passed to %s#%s, see previous errors to know what are the invalid params'
  # Function that validate the input paramters
  # @note To use a custom message, define a validate_param_message
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_names [Array<Symbol>] list of the names of the params
  # @param param_values [Hash] hash associating a param value to the expected type (description)
  # @example Param with a static type
  #   validate_param(:meth, :param, param => Type)
  # @example Param with various allowed types
  #   validate_param(:meth, :param, param => [Type1, Type2])
  # @example Param using a validation method
  #   validate_param(:meth, :param, param => :validation_method)
  # @example Param using a complex structure (Array of String)
  #   validate_param(:meth, :param, param => { Array => String })
  # @example Param using a complex structure (Array of Symbol, Integer, String, repetetive)
  #   validate_param(:meth, :param, param => { Array => [Symbol, Integer, String], :cyclic => true, min: 3, max: 9})
  # @example Param using a complex structure (Hash)
  #   validate_param(:meth, :param, param => { Hash => { key1: Type, key2: Type2, key3: [String, Symbol] },
  #                                            :optional => [:key2] })
  def validate_param(method_name, *param_names, param_values)
    index = 0
    exception = false
    param_values.each do |param_value, param_types|
      exception |= validate_param_value(method_name, param_names[index], param_value, param_types)
      index += 1
    end
    raise ArgumentError, format(EXC_MSG, self.class, method_name) if exception
  end

  private

  # Function that validate a single parameter
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Class] expected type for param
  # @return [Boolean] if an exception should be raised when all parameters will be checked
  def validate_param_value(method_name, param_name, value, types)
    if types.is_a?(Module)
      return value.is_a?(types) ? false : validate_param_error_simple(method_name, param_name, value, types)
    elsif types.is_a?(Symbol)
      return send(types, value) ? false : validate_param_error_method(method_name, param_name, value, types)
    elsif types.is_a?(Array)
      return false if types.any? { |type| value.is_a?(type) }
      return validate_param_error_multiple(method_name, param_name, value, types)
    end
    return validate_param_complex_value(method_name, param_name, value, types)
  end

  # Function that shows an error on a parameter that should be validated by its type
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Class] expected type for param
  # @return [true] there's an exception to raise
  def validate_param_error_simple(method_name, param_name, value, types)
    reason = "should be a #{types}; is a #{value.class} with value of #{value.inspect}."
    log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
    return true
  end

  # Function that shows an error on a parameter that should be validated by a method
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Symbol] expected type for param
  # @return [true] there's an exception to raise
  def validate_param_error_method(method_name, param_name, value, types)
    reason = "hasn't validated criteria from #{types} method, value=#{value.inspect}."
    log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
    return true
  end

  # Function that shows an error on a parameter that should be validated by its type
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Array<Class>] expected type for param
  # @return [true] there's an exception to raise
  def validate_param_error_multiple(method_name, param_name, value, types)
    exp_types = types.join(', ').sub(/\,([^\,]+)$/, ' or a\1')
    reason = "should be a #{exp_types}; is a #{value.class} with value of #{value.inspect}."
    log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
    return true
  end

  # Function that validate a single complex value parameter
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Hash] expected type for param
  # @return [Boolean] if an exception should be raised when all parameters will be checked
  def validate_param_complex_value(method_name, param_name, value, types)
    error = false
    if (sub_type = types[Array])
      return validate_param_error_simple(method_name, param_name, value, Array) unless value.is_a?(Array)
      validate_param_complex_value_size(method_name, param_name, value, types)
      if sub_type.is_a?(Module)
        value.each_with_index do |sub_val, index|
          error |= validate_param_value(method_name, "#{param_name}[#{index}]", sub_val, sub_type)
        end
      elsif sub_type.is_a?(Array)
        value.each_with_index do |sub_val, index|
          sub_typec = sub_type[index % sub_type.size]
          error |= validate_param_value(method_name, "#{param_name}[#{index}]", sub_val, sub_typec)
        end
      end
    elsif (type = types[Hash])
      return validate_param_error_simple(method_name, param_name, value, Hash) unless value.is_a?(Hash)
      optional = types[:optional] || EMPTY_OPTIONAL
      type.each do |key, sub_type2|
        unless value.key?(key)
          next if optional.include?(key)
          reason = "key #{key.inspect} is mandatory."
          log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
          next error = true
        end
        error |= validate_param_value(method_name, "#{param_name}[#{key.inspect}]", value[key], sub_type2)
      end
    end
    return error
  end

  # Function that validate the size of a complex array value
  # @param method_name [Symbol] name of the method which its param are being validated
  # @param param_name [Symbol] name of the param that is being validated
  # @param value [Object] value of the param
  # @param types [Hash] expected type for param
  # @return [Boolean] if an exception should be raised when all parameters will be checked
  def validate_param_complex_value_size(method_name, param_name, value, types)
    error = false
    if (min = types[:min]) && min > value.size
      reason = "param should contain at least #{min} values and contain #{value.size} values"
      log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
      error = true
    end
    if (max = types[:max]) && max < value.size
      reason = "param should not contain more than #{max} values and contain #{value.size} values"
      log_error(format(validate_param_message, param_name: param_name, method_name: method_name, reason: reason))
      error = true
    end
    return error
  end

  # Return the common error message
  # @return [String]
  def validate_param_message
    VALIDATE_PARAM_ERROR
  end
end
