=begin
# Declaration of the Storage system of PSDK
ScriptLoader.declare_scripts(
  category: 'System',
  name: 'Storage',
  sub_modules: {
    pfm: '00001 PFM_Storage',
    ui: '00002 UI_Storage',
    gameplay: '00003 GamePlay_Storage'
  }
)
# How to disable some part of the system
# Open the file scripts/ScriptLoader.yml
# In the section disabled you can add:
# - System::Storage.ui
# - System::Storage.gameplay
# Add one of those to the section will tell the ScriptLoader not to load the ui and/or gameplay section of the native PSDK Storage System.
=end
