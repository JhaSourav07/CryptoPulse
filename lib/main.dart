import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'modules/home/views/home_view.dart';
import 'modules/home/controllers/crypto_controller.dart';

void main() {
  runApp(const CryptoPulseApp());
}

class CryptoPulseApp extends StatelessWidget {
  const CryptoPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CryptoPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: BindingsBuilder(() {
        // Dependency Injection
        Get.put(CryptoController());
      }),
      home: const HomeView(),
    );
  }
}