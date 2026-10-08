import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staffpulseapp/home/presentation/screens/home_screen.dart';
import 'package:staffpulseapp/leave/presentation/screens/leave_history_screen.dart';
import 'package:staffpulseapp/leave/presentation/screens/leave_request_screen.dart';
import 'package:staffpulseapp/leave/presentation/screens/manager_tasks_screen.dart';
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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/leave/submit',
      name: 'leave_submit',
      builder: (context, state) => const LeaveRequestScreen(),
    ),
    GoRoute(
      path: '/leave/history',
      name: 'leave_history',
      builder: (context, state) => const LeaveHistoryScreen(),
    ),
    GoRoute(
      path: '/manager/tasks',
      name: 'manager_tasks',
      builder: (context, state) => const ManagerTasksScreen(),
    ),
  ],
);