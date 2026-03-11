#include "speech_to_text_windows_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <iostream>
#include <string>

namespace speech_to_text_windows {

void SpeechToTextWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(),
          "speech_to_text_windows",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<SpeechToTextWindowsPlugin>();
  plugin->m_channel = std::move(channel);

  plugin->m_channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

SpeechToTextWindowsPlugin::SpeechToTextWindowsPlugin()
    : m_cpRecognizer(nullptr),
      m_cpRecoContext(nullptr),
      m_cpRecoGrammar(nullptr),
      m_cpAudio(nullptr),
      m_initialized(false),
      m_listening(false) {
  std::cout << "SpeechToTextWindowsPlugin created (safe mode)" << std::endl;
}

SpeechToTextWindowsPlugin::~SpeechToTextWindowsPlugin() {
  std::lock_guard<std::mutex> lock(m_mutex);
  m_listening = false;
  m_initialized = false;
  std::cout << "SpeechToTextWindowsPlugin destroyed (safe mode)" << std::endl;
}

void SpeechToTextWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method_name = method_call.method_name();

  if (method_name == "hasPermission") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_name == "initialize") {
    Initialize(method_call, std::move(result));
  } else if (method_name == "listen") {
    Listen(method_call, std::move(result));
  } else if (method_name == "stop") {
    Stop(std::move(result));
  } else if (method_name == "cancel") {
    Cancel(std::move(result));
  } else if (method_name == "locales") {
    GetLocales(std::move(result));
  } else {
    result->NotImplemented();
  }
}

void SpeechToTextWindowsPlugin::Initialize(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::lock_guard<std::mutex> lock(m_mutex);
  (void)method_call;
  m_initialized = true;
  result->Success(flutter::EncodableValue(true));
}

void SpeechToTextWindowsPlugin::Listen(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::lock_guard<std::mutex> lock(m_mutex);
  (void)method_call;
  if (!m_initialized) {
    result->Success(flutter::EncodableValue(false));
    return;
  }

  m_listening = true;
  SendStatus("listening");
  result->Success(flutter::EncodableValue(true));
}

void SpeechToTextWindowsPlugin::Stop(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::lock_guard<std::mutex> lock(m_mutex);
  if (m_listening) {
    m_listening = false;
    SendStatus("notListening");
  }
  if (result) {
    result->Success(flutter::EncodableValue(nullptr));
  }
}

void SpeechToTextWindowsPlugin::Cancel(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  Stop(std::move(result));
}

void SpeechToTextWindowsPlugin::GetLocales(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  flutter::EncodableList locales;
  locales.push_back(flutter::EncodableValue("en-US:English (United States)"));
  locales.push_back(flutter::EncodableValue("en-GB:English (United Kingdom)"));
  result->Success(flutter::EncodableValue(locales));
}

void SpeechToTextWindowsPlugin::SendTextRecognition(
    const std::string& text,
    bool is_final) {
  if (m_channel) {
    const auto payload = text + (is_final ? " [final]" : " [partial]");
    m_channel->InvokeMethod(
        "textRecognition",
        std::make_unique<flutter::EncodableValue>(payload));
  }
}

void SpeechToTextWindowsPlugin::SendError(const std::string& error) {
  if (m_channel) {
    m_channel->InvokeMethod(
        "notifyError",
        std::make_unique<flutter::EncodableValue>(error));
  }
}

void SpeechToTextWindowsPlugin::SendStatus(const std::string& status) {
  if (m_channel) {
    m_channel->InvokeMethod(
        "notifyStatus",
        std::make_unique<flutter::EncodableValue>(status));
  }
}

}  // namespace speech_to_text_windows

extern "C" __declspec(dllexport) void SpeechToTextWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  speech_to_text_windows::SpeechToTextWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
