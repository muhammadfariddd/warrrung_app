import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warrrung_app/data/repositories/product_repository.dart';
import 'package:warrrung_app/providers/home_provider.dart';
import 'package:warrrung_app/providers/auth_provider.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';
import 'package:warrrung_app/splash_screen.dart';

import 'package:warrrung_app/data/repositories/outlet_repository.dart';
import 'package:warrrung_app/providers/location_provider.dart';

void main() {
  final pbService = PocketBaseService();
  final productRepository = ProductRepository(pbService);
  final outletRepository = OutletRepository(pbService);

  runApp(
    MultiProvider(
      providers: [
        Provider<PocketBaseService>.value(value: pbService),
        Provider<ProductRepository>.value(value: productRepository),
        Provider<OutletRepository>.value(value: outletRepository),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(productRepository),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(pbService),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(outletRepository),
        ),
      ],
      child: const SplashScreenApp(),
    ),
  );
}

class SplashScreenApp extends StatelessWidget {
  const SplashScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
