import 'package:flutter/material.dart';
import 'login.dart';
import 'admin/dashboard.dart';
import 'admin/pending_approvals.dart';
import 'admin/user_management.dart';
import 'admin/bookings_management.dart';
import 'admin/campsite_management.dart';

enum AdminScreen { login, dashboard, approvals, users, bookings, campsites }

class AdminApp extends StatefulWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  AdminScreen currentScreen = AdminScreen.login;
  bool isLoggedIn = true; // TURN THIS TO TRUE TO SKIP LOGIN FOR TESTING

  void _handleLogin() {
    setState(() {
      isLoggedIn = true;
      currentScreen = AdminScreen.dashboard;
    });
  }

  void _navigateTo(AdminScreen screen) {
    setState(() => currentScreen = screen);
  }

  Widget _renderScreen() {
    if (!isLoggedIn) return LoginScreen();

    switch (currentScreen) {
      case AdminScreen.dashboard:
        return AdminDashboardScreen(onNavigate: _navigateTo);
      case AdminScreen.approvals:
        return PendingApprovalsScreen(onBack: () => _navigateTo(AdminScreen.dashboard));
      case AdminScreen.users:
        return UserManagementScreen(onBack: () => _navigateTo(AdminScreen.dashboard));
      case AdminScreen.bookings:
        return BookingsManagementScreen(onBack: () => _navigateTo(AdminScreen.dashboard));
      case AdminScreen.campsites:
        return CampsiteManagementScreen(onBack: () => _navigateTo(AdminScreen.dashboard));
      default:
        return AdminDashboardScreen(onNavigate: _navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 428),
      child: Scaffold(body: _renderScreen()),
    );
  }
}