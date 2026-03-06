import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:home_widget/home_widget.dart';
import 'core/theme/app_theme.dart';
import 'modules/home/controllers/crypto_controller.dart';
import 'modules/home/views/home_view.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await GetStorage.init();

  // Initialize home_widget — required for iOS app groups; also ensures the
  // plugin is ready before any widget data is written on all platforms.
  HomeWidget.setAppGroupId('group.com.example.cryptopulse');

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
        Get.put(CryptoController());
      }),
      home: const HomeView(),
    );
  }
}