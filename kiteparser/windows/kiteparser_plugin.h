#ifndef FLUTTER_PLUGIN_KITEPARSER_PLUGIN_H_
#define FLUTTER_PLUGIN_KITEPARSER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace kiteparser {

class KiteparserPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  KiteparserPlugin();

  virtual ~KiteparserPlugin();

  // Disallow copy and assign.
  KiteparserPlugin(const KiteparserPlugin&) = delete;
  KiteparserPlugin& operator=(const KiteparserPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace kiteparser

#endif  // FLUTTER_PLUGIN_KITEPARSER_PLUGIN_H_
