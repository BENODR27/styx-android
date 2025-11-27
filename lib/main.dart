import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Mobile/Web
import 'package:webview_flutter/webview_flutter.dart' as mobile_webview;

// Windows
import 'package:webview_windows/webview_windows.dart' as win_webview;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final bool isWindows;

  mobile_webview.WebViewController? mobileController;

  final winController = win_webview.WebviewController();

  final String url = "https://cfdt.cfadmin.cfaiteam.com";

  @override
  void initState() {
    super.initState();
    isWindows = !kIsWeb && Platform.isWindows;

    if (isWindows) {
      _initWindowsWebView();
    } else {
      _initMobileWebView();
    }
  }

  void _initMobileWebView() {
    mobileController = mobile_webview.WebViewController()
      ..setJavaScriptMode(mobile_webview.JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  Future<void> _initWindowsWebView() async {
    await winController.initialize();
    await winController.setBackgroundColor(Colors.white);
    await winController.setPopupWindowPolicy(
      win_webview.WebviewPopupWindowPolicy.deny,
    );
    await winController.loadUrl(url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isWindows ? _buildWindowsWebView() : _buildMobileWebView(),
      ),
    );
  }

  Widget _buildWindowsWebView() {
    if (!winController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return win_webview.Webview(
      winController,
      permissionRequested: (url, kind, isUserInitiated) async {
        return win_webview.WebviewPermissionDecision.allow;
      },
    );
  }

  Widget _buildMobileWebView() {
    return mobile_webview.WebViewWidget(controller: mobileController!);
  }
}
