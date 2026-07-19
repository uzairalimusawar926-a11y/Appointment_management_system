import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/appointment_controller.dart';
import '../../utils/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    await Provider.of<AppointmentController>(context, listen: false).fetchMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.myBookings.isEmpty) {
            return const Center(child: Text('No bookings found'));
          }

          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.myBookings.length,
              itemBuilder: (context, index) {
                final booking = controller.myBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(booking.appointmentName ?? 'Appointment'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${booking.bookingDate}'),
                        Text('Time: ${booking.timeSlots}'),
                        Text('Status: ${booking.stateDisplay}'),
                      ],
                    ),
                    trailing: booking.state == 'draft'
                        ? IconButton(
                            icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Booking'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                final success = await controller.cancelAppointment(booking.id);
                                if (success && mounted) {
                                  Fluttertoast.showToast(
                                    msg: 'Booking cancelled',
                                    backgroundColor: AppTheme.successColor,
                                  );
                                }
                              }
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
