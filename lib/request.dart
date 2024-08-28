import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';

class Request {
  Webview? webview;
  Timer? timer;

  Future<String?> request(String url, {Duration timeout = const Duration(seconds: 10)}) async {
    webview ??= await WebviewWindow.create(
      configuration: const CreateConfiguration(
        windowHeight: 0,
        windowWidth: 0,
      ),
    );

    Completer<String?> completer = Completer<String?>();

    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    webview!.isNavigating.addListener(() async {
      if (!webview!.isNavigating.value && !completer.isCompleted) {
        timer?.cancel();
        var html = await webview!.evaluateJavaScript('document.documentElement.outerHTML');
        if (html == r'<html><head></head><body></body></html>') {
          html = null;
        }
        completer.complete(html);
      }
    });

    webview!.launch(url);

    return completer.future;
  }

  void dispose() {
    timer?.cancel();
    webview?.close();
  }
}

final HttpGetter = Request();