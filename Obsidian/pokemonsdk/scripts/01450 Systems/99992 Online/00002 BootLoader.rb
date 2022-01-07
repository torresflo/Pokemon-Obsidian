# ProjectCompilation: BootLoader
# ProjectCompilationCondition: Configs.online_configs.enabled
if !PSDK_CONFIG.release? && Configs.online_configs.enabled
  require_relative 'ngop/lib/nuri_game/online/proxy/version'
  require_relative 'ngop/lib/nuri_game/online/proxy/packet'
  require_relative 'ngop/lib/nuri_game/online/proxy/client'
end
