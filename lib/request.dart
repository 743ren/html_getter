import 'package:desktop_webview_window/desktop_webview_window.dart';

class Request {
  Webview? webview;
  Function()? listener;

  void request(String url, Function(String?) callback) async {
    webview ??= await WebviewWindow.create(
      configuration: const CreateConfiguration(
        windowHeight: 0,
        windowWidth: 0,
      ),
    );
    if (listener == null) {
      // 没有用 Widget，就不用 ValueListenableBuilder 了，直接自己 listen
      listener = () async {
        if (!webview!.isNavigating.value) { // fasle 表示加载据说
          var html = await webview!.evaluateJavaScript('document.documentElement.outerHTML');
          // 如果页面加载出错，返回 <html><head></head><body></body></html>
          if (html == r'<html><head></head><body></body></html>') {
            html = null;
          }
          callback(html);
          webview!.close();
        }
      };
      webview!.isNavigating.addListener(listener!);
    }
    webview!.launch(url);
  }

  void dispose() {
    if (listener != null) {
      webview?.isNavigating.removeListener(listener!);
    }
  }
}

final HttpGetter = Request();