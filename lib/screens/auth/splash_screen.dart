import 'package:flutter/material.dart';

import 'erp_startup_splash.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ErpStartupSplash());
  }
}
