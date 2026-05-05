import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZingPlayer extends StatelessWidget {
  const ZingPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zing Player")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(
            Uri.parse("https://zingmp3.vn/embed/song/Z8F7UUDU?start=false"),
          ),
      ),
    );
  }
}
