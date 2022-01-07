module UI
  class NameInputBaseUI < GenericBase
    private void_method :create_button_background
    public void_method :update_background_animation

    private

    def create_background
      @background = UI::BlurScreenshot.new($scene.__last_scene)
      $scene.add_disposable(@background)
    end

    def create_control_button
      @ctrl = []
    end
  end
end
