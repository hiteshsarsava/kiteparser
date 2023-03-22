//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <kiteparser/kiteparser_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) kiteparser_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KiteparserPlugin");
  kiteparser_plugin_register_with_registrar(kiteparser_registrar);
}
