return unless PSDK_CONFIG.debug?

module InspectElements
  include Hooks
  extend Hooks

  module_function

  @@display_datas = []
  @@selected_display_datas = []

  def selected_display_datas
    return @@selected_display_datas
  end

  def register_display_data(display_data)
    @@display_datas << display_data
  end

  def unregister_display_data(display_data)
    @@display_datas.delete(display_data)
  end

  def display_show
    settings = Graphics.window.settings
    # Mouse visible
    settings[8] = true
    Graphics.window.settings = settings

    @@display_datas.sort_by!(&:z)
    @@display_datas.each(&:draw)
  end

  def display_clear_screen
    @@selected_display_datas = []
    @@display_datas.each(&:destroy_shapes)
    exec_hooks(InspectElements, :selected_elements, binding)
  end

  def display_select_at(pos_x, pos_y)
    selected_display_datas = []
    @@selected_display_datas = []
    @@display_datas.reverse_each do | display_data |
      display_data.for_data_at(pos_x, pos_y, proc {|unmatching_data| unmatching_data.unselect} ) do |matching_data|
        matching_data.unselect
        unless @@display_datas.include?(matching_data)
          selected_display_datas << matching_data
        end
      end
    end

    min_select_display_data = selected_display_datas.min_by {|display_data| display_data.box&.width * display_data.box&.height }
    unless min_select_display_data.nil?
      min_select_display_data.select
      @@selected_display_datas << min_select_display_data
    end
    exec_hooks(InspectElements, :selected_elements, binding)
  end

  def display_move_selected(offset_x, offset_y)
    @@selected_display_datas.each do |display_data|
      display_data.move(offset_x, offset_y)
    end
    exec_hooks(InspectElements, :move_selected_elements, binding) if @@selected_display_datas.length > 0
  end

  def display_hide_selected
    @@selected_display_datas.each(&:hide)
    @@selected_display_datas = []
  end

end
