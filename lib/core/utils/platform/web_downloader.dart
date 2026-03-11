import 'web_downloader_stub.dart'
    if (dart.library.html) 'web_downloader_web.dart';

void downloadCsvWeb(String content, String fileName) =>
    downloadFileWeb(content, fileName);
