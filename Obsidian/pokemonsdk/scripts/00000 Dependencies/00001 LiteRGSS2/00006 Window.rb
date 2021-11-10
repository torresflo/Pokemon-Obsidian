raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Class used to show a Window object on screen.
#
# A Window is an object that has a frame (built from #window_builder and #windowskin) and some contents that can be Sprites or Texts.
class Window < LiteRGSS::Window
end
