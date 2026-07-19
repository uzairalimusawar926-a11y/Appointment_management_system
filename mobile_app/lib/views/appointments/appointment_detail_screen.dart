import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';
import '../../utils/app_theme.dart';
import 'booking_flow_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (appointment.image != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(appointment.image!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.name, style: AppTheme.headingStyle),
                  const SizedBox(height: 16),
                  if (appointment.location != null)
                    _InfoRow(icon: Icons.location_on, label: 'Location', value: appointment.location!),
                  _InfoRow(icon: Icons.access_time, label: 'Duration', value: '${appointment.slotDuration} min'),
                  _InfoRow(icon: Icons.attach_money, label: 'Fee', value: '\$${appointment.fees}'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<AppointmentController>(context, listen: false).selectAppointment(appointment);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFlowScreen()));
                    },
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.captionStyle),
                Text(value, style: AppTheme.bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
