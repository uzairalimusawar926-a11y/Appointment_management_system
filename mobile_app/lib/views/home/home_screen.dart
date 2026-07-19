import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/company_controller.dart';
import '../../utils/app_theme.dart';
import '../appointments/appointments_list_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../portal/portal_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AppointmentsListScreen(),
    const MyBookingsScreen(),
    const PortalScreen(),
    const ProfileScreen(),
  ];

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

  Future<void> _loadData() async {
    final appointmentController = Provider.of<AppointmentController>(context, listen: false);
    final companyController = Provider.of<CompanyController>(context, listen: false);
    
    await appointmentController.fetchAppointments();
    await appointmentController.fetchMyBookings();
    if (companyController.company == null) {
      await companyController.fetchCompanySettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 1) {
                    context.read<AppointmentController>().fetchMyBookings();
                  }
                },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLightColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Portal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
