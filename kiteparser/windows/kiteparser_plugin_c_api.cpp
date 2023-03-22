#include "include/kiteparser/kiteparser_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "kiteparser_plugin.h"

void KiteparserPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  kiteparser::KiteparserPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
