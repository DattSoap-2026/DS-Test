#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

LONG WINAPI TopLevelExceptionFilter(EXCEPTION_POINTERS* exception_info) {
  if (exception_info == nullptr || exception_info->ExceptionRecord == nullptr) {
    return EXCEPTION_EXECUTE_HANDLER;
  }

  const auto code = exception_info->ExceptionRecord->ExceptionCode;
  if (code == EXCEPTION_ACCESS_VIOLATION || code == EXCEPTION_STACK_OVERFLOW ||
      code == EXCEPTION_ILLEGAL_INSTRUCTION || code == 0xE06D7363) {
    // Prevent Windows "stopped working" dialog during plugin shutdown races.
    OutputDebugStringW(
        L"[Runner] Unhandled exception intercepted, forcing graceful exit.\n");
    return EXCEPTION_EXECUTE_HANDLER;
  }
  return EXCEPTION_CONTINUE_SEARCH;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  SetErrorMode(GetErrorMode() | SEM_NOGPFAULTERRORBOX | SEM_FAILCRITICALERRORS |
               SEM_NOOPENFILEERRORBOX);
  SetUnhandledExceptionFilter(TopLevelExceptionFilter);

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  HRESULT hr = ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(hr) && hr != RPC_E_CHANGED_MODE) {
    return EXIT_FAILURE;
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"DattSoap", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0) > 0) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (SUCCEEDED(hr)) {
    ::CoUninitialize();
  }
  return EXIT_SUCCESS;
}
