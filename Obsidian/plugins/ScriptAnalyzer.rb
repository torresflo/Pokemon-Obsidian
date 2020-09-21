#encoding: utf-8
# Class that Analyze scripts
# It find references to methods and constants (it's its goal)
# 
# Structure of a method definition : "method_name" => {begin: line_no_where_def_is_written, end: line_no_where_end_is_written, script: name_of_the_script}
# Structure of a constant definition : ConstantName: {define: line_no_where_the_const_affectation_is_defined, script: name_of_the_script}
class ScriptAnalyzer
  # Get the scripts the object analyzed
  # @return [Hash<String => Array<String>>] script name associated to a script_content (splited)
  attr_reader :scripts
  # Get the classe tree
  # @return [Hash<Symbol => Hash>] the symbol is the name of the class. :methods is a hash containing methods , :constants is a Hash containing constants
  attr_reader :classes
  # Get the order of the analyzed scripts
  # @return [Array<String>] list of script name in the right order
  attr_reader :order
  # Create a new ScriptAnalyzer
  def initialize
    @scripts = {}
    @classes = {Object: {name: :Object, last_def: nil, methods: {}, constants: {}}}
    @classes[:Object][:parent] = @classes[:Object]
    @classes[:Object][:Object] = @classes[:Object]
    @order = []
  end
  # Analyze a script
  # @param name [String] name of the script
  # @param contents [String] contents of the script
  # @return [self]
  def analyze(name, contents)
    _classes = @classes
    return if name.empty? or contents.empty?
    name = correct_name(name)
    @order << name
    lines = @scripts[name] = contents.split(/[\r]*\n/)#"\n")
    current_class = _classes[:Object]
    level = 0 # 0 : inside class, 1 : inside def, 2+ inside a if/unless/case/while/until/do/begin/for
    class_def_index = 0 # Index of class/module we're inside
    in_multiline_condition = false
    outside_cond = [] # All the outside condition found outside of a def referenced by their class_def_count
    lines.each_with_index do |line, i|
      current_class, level, class_def_index, in_multiline_condition = process_line(name, current_class, level, class_def_index, in_multiline_condition, outside_cond, line, i+1)
    end
    return self
  end
  private
  # Regexp that helps to remove comments
  LazyCommentRemove = /(\#[^\{]+.*|#$)/
  # Proccess the analysis of a line of code
  # @param name [String] name of the current script
  # @param current_class [Hash] current class info
  # @param level [Integer] current level 0 : inside class, 1 : inside def, 2+ inside a if/unless/case/while/until/do/begin/for
  # @param class_def_index [Integer] Index of class/module we're inside
  # @param in_multiline_condition [Boolean] if we are in a multiline condition
  # @param outside_cond [Array<Integer>] All the outside condition found outside of a def referenced by their class_def_count
  # @param line [String] current line of code
  # @param lineno [Integer] current line number
  # @return [Array] new local variable state
  def process_line(name, current_class, level, class_def_index, in_multiline_condition, outside_cond, line, lineno)
    stripped_line = detect_and_remove_string(line).gsub(LazyCommentRemove, '').strip
    unless in_multiline_condition
      if match_class(line, stripped_line)
        if level > 0
          # assuming it's class << object
          level += 1
        else
          tmp_class = get_class(current_class, line, stripped_line)
          if tmp_class != current_class
            class_def_index += 1
            current_class = tmp_class
          else #< It's a << self or a redifinition of Object
            outside_cond << class_def_index
          end
        end
      elsif match_def(line, stripped_line)
        if level >= 1
          # assuming it's a singleton def
          level += 1
        else
          process_def(name, current_class, line, lineno, stripped_line)
          level = 1
        end
      elsif match_condition_close(line, stripped_line)
        if level == 0
          outside_cond << class_def_index
        else
          level += 1
        end
      elsif match_constant_def(line, stripped_line)
        process_constant_def(name, current_class, line, lineno, stripped_line)
      elsif match_end(line, stripped_line)
        return process_end(current_class, level, class_def_index, in_multiline_condition, outside_cond, line, lineno, stripped_line)
      elsif match_eq_begin(line, stripped_line)
        return current_class, level, class_def_index, true
      end
      if match_do(line, stripped_line) and !match_non_do_condition_close(line, stripped_line) # while true do stuff end is allowed, until do, for do
        if level == 0
          outside_cond << class_def_index
        else
          level += 1
        end
      end
      if match_end_at_end_line(line, stripped_line)
        warn "end found at the end of the line #{lineno} of #{name} : #{line}"
        return process_end(current_class, level, class_def_index, in_multiline_condition, outside_cond, line, lineno, stripped_line) #< Penser à processer le last_def: dans le end
      end
    else
      in_multiline_condition = false if match_eq_end(line, stripped_line)
    end
    return current_class, level, class_def_index, in_multiline_condition
  end
  # Regexp that detects a class definition
  ClassDefDetect = /(module |class |class<<|class <<)[ :]*([A-Z]|self)/
  # Function that match a class definition
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_class(line, stripped_line)
    return (stripped_line =~ ClassDefDetect) == 0
  end
  # Regexp that detects a method definition
  CondDefDetect = /\(*(if|unless|case|while|until|begin|for)[ \/*\-+$@\[%!(~]{0,1}/ # might get problem with * & < > | ^ = ?
  # Regexp that detects a method definition after a block
  CondSpeDefDetect = /({|do[ (]+)\(*(if|unless|case|while|until|begin|for)[ \/*\-+$@\[%!(~]{0,1}/
  # Function that match a method definition
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_condition_close(line, stripped_line)
    if (stripped_line =~ CondDefDetect) == 0
      return true
    #elsif (stripped_line =~ CondSpeDefDetect) #< For now we won't do that because fuck off the people that write code like pigs
    #  return true
    end
    return false
  end
  # Regexp that detects a method definition
  DefDefDetect = /\(*def[ \/*\-+$@\[=%!<>&|^~]/
  # Regexp that detects a method definition after a block
  DefSpeDefDetect = /({|do[ (]+)\(*def[ \/*\-+$@\[=%!<>&|^~]/
  # Function that match condition defition
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_def(line, stripped_line)
    if (stripped_line =~ DefDefDetect) == 0
      return true
    #elsif (stripped_line =~ DefSpeDefDetect) #< For now we won't do that because fuck off the people that write code like pigs
    #  return true
    end
    return false
  end
  # Regexp that detects a constant definition
  ConstantDefDetect = /[A-Z][^^.\/*\-+\[=%!<>&|^~:]*(=[^=]|=$)/#/(::){0,1}[A-Z][^.\/*\-+\[=%!<>&|^~]*(=[^=]|=$)/
  # Function that match a constant definition
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_constant_def(line, stripped_line)
    return (stripped_line =~ ConstantDefDetect) == 0#!= nil
  end
  # Regexp that detects a end statement
  EndDetect = /end$/#/[)}; ](end[)};]|end$)/
  # Function that match a end statement
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_end(line, stripped_line)
    return (stripped_line =~ EndDetect) == 0
  end
  # Regexp that detects a end statement at the end of a line
  EndEndLineDetect = /[)}; ](end[)}; ]|end$)/
  # Function that match a end statement at the end of a line
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_end_at_end_line(line, stripped_line)
    return (stripped_line =~ EndEndLineDetect) != nil
  end
  # Regexp that detects a do statement
  DoDetect = /[) ](do[ |]|do$)/
  # Function that match a do statement
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_do(line, stripped_line)
    return (stripped_line =~ DoDetect) != nil
  end
  # Regexp that detects a method definition
  CondNonDoDefDetect = /\(*(if|unless|case|begin)[ \/*\-+$@\[%!(~]{0,1}/ # might get problem with * & < > | ^ = ?
  # Function that match a method definition
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_non_do_condition_close(line, stripped_line)
    return (stripped_line =~ CondNonDoDefDetect) == 0
  end
  # Regexp that detects =begin
  EqBeginDetect = /=(begin |begin$)/
  # Function that match a =begin comment
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_eq_begin(line, stripped_line)
    return (line.rstrip =~ EqBeginDetect) == 0
  end
  # Regexp that detects =begin
  EqEndDetect = /=(end |end$)/
  # Function that match a the end of an =begin comment
  # @param line [String] current line
  # @param stripped_line [String] stripped line
  # @return [Boolean] if matched
  def match_eq_end(line, stripped_line)
    return (line.rstrip =~ EqEndDetect) == 0
  end
  # Regexp that get the class name
  ClassNameGetter = /(module |class |class<<|class <<)[ :]*([A-Z][^< ]*|self)/
  # Get the new current class
  # @param current_class [Hash] current class info
  # @param line [String] current line of code
  # @param stripped_line [String] stripped line
  # @return [Hash]
  def get_class(current_class, line, stripped_line)
    name = stripped_line.match(ClassNameGetter)[2]
    if name != 'self'
      name_arr = name.split('::').collect! { |el| el.to_sym }
      name_arr.each do |class_name|
        if current_class[class_name]
          current_class = current_class[class_name]
          current_class[:last_def] = nil
        else
          current_class = current_class[class_name] = {name: class_name, last_def: nil, parent: current_class, methods: {}, constants: {}}
        end
      end
      if name_arr.size > 1
        current_class[:parent_count_return] = name_arr.size #tell end to load a specific amount of parents
      end
    end
    return current_class
  end
  # Regexp that get the method name
  MethodNameGetter = /\(*def( ([^ (]+)|([\/*\-+$@\[=%!<>&|^~][^ (]))/
  # Process the def definition
  # @param name [String] name of the current script
  # @param current_class [Hash] current class info
  # @param line [String] current line of code
  # @param lineno [Integer] current line number
  # @param stripped_line [String] stripped line
  def process_def(name, current_class, line, lineno, stripped_line)
    match_data = stripped_line.match(MethodNameGetter)
    method_name = (match_data[2] || match_data[3]).to_sym
    return if current_class[:methods][method_name]
    current_class[:last_def] = current_class[:methods][method_name] = {
      begin: lineno,
      end: lineno,
      script: name
    }
  end
  # Regexp that get the constant name
  ConstaneNameGetter = /([A-Z][^^.\/*\-+\[=%!<>&|^~:]*)(=[^=]|=$)/
  # Process the de definition
  # @param name [String] name of the current script
  # @param current_class [Hash] current class info
  # @param line [String] current line of code
  # @param lineno [Integer] current line number
  # @param stripped_line [String] stripped line
  def process_constant_def(name, current_class, line, lineno, stripped_line)
    match_data = stripped_line.match(ConstaneNameGetter)
    const_name = match_data[1].gsub(' ','').to_sym
    return if current_class[:constants][const_name]
    current_class[:constants][const_name] = {define: lineno, script: name}
  end
  # Process the end statement
  # @param name [String] name of the current script
  # @param current_class [Hash] current class info
  # @param level [Integer] current level 0 : inside class, 1 : inside def, 2+ inside a if/unless/case/while/until/do/begin/for
  # @param class_def_index [Integer] Index of class/module we're inside
  # @param in_multiline_condition [Boolean] if we are in a multiline condition
  # @param outside_cond [Array<Integer>] All the outside condition found outside of a def referenced by their class_def_count
  # @param line [String] current line of code
  # @param lineno [Integer] current line number
  # @param stripped_line [String] stripped line
  # @return [Array] new local variable state
  def process_end(current_class, level, class_def_index, in_multiline_condition, outside_cond, line, lineno, stripped_line)
    #puts "#{lineno} #{level}"
    if level > 1
      level -= 1
    elsif level == 1
      level = 0
      if current_class[:last_def]
        current_class[:last_def][:end] = lineno
        current_class[:last_def] = nil
      end
    else
      if outside_cond.last == class_def_index
        outside_cond.pop
      else
        class_def_index -= 1 if class_def_index > 0
        if count = current_class[:parent_count_return]
          current_class[:parent_count_return] = nil
          count.times do 
            current_class = current_class[:parent]
          end
        else
          current_class = current_class[:parent]
        end
      end
    end
    return current_class, level, class_def_index, in_multiline_condition
  end
  # Function that remove strings from string (Lazy for now)
  # @param str [String] string that could contain strings
  # @return [String] cleaned string
  def detect_and_remove_string(str)
    while ind = str.index('"')
      if ind2 = str.rindex('"')
        str = str[0...ind] + str[(ind2+1)..-1]
      else
        str = str[0...ind]
      end
    end
    while ind = str.index("'")
      if ind2 = str.rindex("'")
        str = str[0...ind] + str[(ind2+1)..-1]
      else
        str = str[0...ind]
      end
    end
    return str
  end
  # Detect if the name is already used and try to correct the name
  # @param name [String] original name
  # @return [String] corrected name
  def correct_name(name)
    return name unless @scripts[name]
    nb = 2
    while @scripts[sub_name = "#{name}_#{nb}"]
      nb += 1
    end
    warn "Warning : a script named #{name} has been analyzed, this script has been renamed #{sub_name}"
    return sub_name
  end
  public
  # Prints the classes in an IO
  # @param io [IO] the IO that receive the classe print
  # @param small_output [Boolean] tell the function to minimize the number of words in the output
  def print_classes(io = STDOUT, small_output = true)
    print_all_classes_of(@classes[:Object], nil, io, small_output)
    return nil
  end
  IgnoreSym = [:name, :last_def, :parent, :methods, :constants, :parent_count_return]
  # Print all the classes of a class and its constants/methods
  # @param current_class [Hash] the class info
  # @param base_name [String] the name that helps to display the full class name
  # @param io [IO] the IO that receive the classe print
  # @param small_output [Boolean] tell the function to minimize the number of words in the output
  def print_all_classes_of(current_class, base_name, io, small_output)
    name = base_name ? "#{base_name}::#{current_class[:name]}" : current_class[:name].to_s
    io.puts name if current_class[:methods].size > 0 or current_class[:constants].size > 0
    last_script = nil
    current_class[:methods].each do |meth_name, method|
      if last_script != method[:script]
        last_script = method[:script]
        io.puts("> in #{last_script}")
      end
      io.puts(small_output ? "\t##{meth_name} => #{method[:begin]} to #{method[:end]}" : "\t##{meth_name} is defined from line #{method[:begin]} to #{method[:end]}")
    end
    last_script = nil
    current_class[:constants].each do |const_name, constant|
      if last_script != constant[:script]
        last_script = constant[:script]
        io.puts("> in #{last_script}")
      end
      io.puts(small_output ? "\t#{const_name} => #{constant[:define]}" : "\t#{const_name} is defined at line #{constant[:define]}")
    end
    current_class.each do |sym, contents|
      next if IgnoreSym.include?(sym) or contents == current_class
      print_all_classes_of(contents, name, io, small_output)
    end
  end
end