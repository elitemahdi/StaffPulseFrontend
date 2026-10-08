import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staffpulseapp/login/presentation/screens/login_screen.dart';
import 'package:staffpulseapp/splash/presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('میز کار سازمانی استاف‌پالس')),
        body: const Center(
          child: Text(
            'ورود با موفقیت انجام شد! به سامانه خوش آمدید.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    ),
  ],
);