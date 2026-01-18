import 'package:flutter/material.dart';
import '../models/campsite.dart';
import 'client/client_home.dart';
import 'client/campsite_details.dart';
import 'client/booking_form.dart';
import 'client/my_bookings.dart';
import 'client/client_profile.dart';
import 'client/weather_forecast.dart';
import 'client/client_about.dart'; // Uncomment jika file sudah dipisah

enum ClientScreen {
  home,
  campsiteDetails,
  bookingForm,
  myBookings,
  profile,
  weatherForecast,
  about,
}

class ClientApp extends StatefulWidget {
  const ClientApp({Key? key}) : super(key: key);

  @override
  State<ClientApp> createState() => _ClientAppState();
}

class _ClientAppState extends State<ClientApp> {
  ClientScreen currentScreen = ClientScreen.home;
  int selectedBottomNavIndex = 0;
  Campsite? selectedCampsite;

  void _navigateTo(ClientScreen screen) {
    setState(() => currentScreen = screen);
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      selectedBottomNavIndex = index;
      switch (index) {
        case 0:
          currentScreen = ClientScreen.home;
          break;
        case 1:
          currentScreen = ClientScreen.myBookings;
          break;
        case 2:
          currentScreen = ClientScreen.profile;
          break;
        case 3: // Logic untuk About
          currentScreen = ClientScreen.about;
          break;
      }
    });
  }

  void _selectCampsite(Campsite campsite) {
    setState(() {
      selectedCampsite = campsite;
      currentScreen = ClientScreen.campsiteDetails;
    });
  }

  void _bookCampsite() {
    if (selectedCampsite != null) {
      setState(() {
        currentScreen = ClientScreen.bookingForm;
      });
    }
  }

  void _viewWeather() {
    if (selectedCampsite != null) {
      setState(() {
        currentScreen = ClientScreen.weatherForecast;
      });
    }
  }

  void _backToHome() {
    setState(() {
      currentScreen = ClientScreen.home;
      selectedBottomNavIndex = 0;
    });
  }

  void _backToCampsiteDetails() {
    setState(() {
      currentScreen = ClientScreen.campsiteDetails;
    });
  }

  void _confirmBooking() {
    setState(() {
      currentScreen = ClientScreen.myBookings;
      selectedBottomNavIndex = 1;
    });
  }

  bool _shouldShowBottomNav() {
    return currentScreen == ClientScreen.home ||
        currentScreen == ClientScreen.myBookings ||
        currentScreen == ClientScreen.profile ||
        currentScreen == ClientScreen.about; // Tambahkan About di sini
  }

  Widget _renderScreen() {
    switch (currentScreen) {
      case ClientScreen.home:
        return ClientHome(onSelectCampsite: _selectCampsite);

      case ClientScreen.campsiteDetails:
        return selectedCampsite != null
            ? CampsiteDetails(
                campsite: selectedCampsite!,
                onBack: _backToHome,
                onBookNow: _bookCampsite,
                onViewWeather: _viewWeather,
              )
            : ClientHome(onSelectCampsite: _selectCampsite);

      case ClientScreen.bookingForm:
        return selectedCampsite != null
            ? BookingForm(
                campsite: selectedCampsite!,
                onBack: _backToCampsiteDetails,
                onConfirm: _confirmBooking,
              )
            : ClientHome(onSelectCampsite: _selectCampsite);

      case ClientScreen.myBookings:
        return MyBookings(onBack: _backToHome);

      case ClientScreen.profile:
        return ClientProfile(onBack: _backToHome);
        
      case ClientScreen.about: // Tambahkan render screen About
        return AboutScreen(onBack: _backToHome);

      case ClientScreen.weatherForecast:
        return selectedCampsite != null
            ? WeatherForecast(
                campsite: selectedCampsite!,
                onBack: _backToCampsiteDetails,
              )
            : ClientHome(onSelectCampsite: _selectCampsite);

      default:
        return ClientHome(onSelectCampsite: _selectCampsite);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 428),
      child: Scaffold(
        body: _renderScreen(),
        bottomNavigationBar: _shouldShowBottomNav()
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBottomNavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: 'Home',
                          index: 0,
                        ),
                        _buildBottomNavItem(
                          icon: Icons.calendar_today_outlined,
                          activeIcon: Icons.calendar_today,
                          label: 'Bookings',
                          index: 1,
                        ),
                        _buildBottomNavItem(
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          label: 'Profile',
                          index: 2,
                        ),
                        // Tambahkan item About (Index 3)
                        _buildBottomNavItem(
                          icon: Icons.info_outline,
                          activeIcon: Icons.info,
                          label: 'About',
                          index: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = selectedBottomNavIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _handleBottomNavTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DUMMY ABOUT SCREEN (Bisa dipindah ke file client/about_screen.dart) ---
