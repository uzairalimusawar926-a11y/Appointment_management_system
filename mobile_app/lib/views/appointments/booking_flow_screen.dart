import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controllers/appointment_controller.dart';
import '../../utils/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      final controller = Provider.of<AppointmentController>(context, listen: false);
      
      final result = await controller.bookAppointment(
        contactName: _nameController.text,
        email: _emailController.text,
        mobile: _phoneController.text,
        description: _descriptionController.text,
      );

      if (result != null && mounted) {
        Fluttertoast.showToast(
          msg: 'Appointment booked successfully!',
          backgroundColor: AppTheme.successColor,
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else if (mounted) {
        Fluttertoast.showToast(
          msg: controller.errorMessage ?? 'Booking failed',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                if (_currentStep == 0 && controller.selectedDate == null) {
                  Fluttertoast.showToast(msg: 'Please select a date');
                  return;
                }
                if (_currentStep == 1 && controller.selectedSlot == null) {
                  Fluttertoast.showToast(msg: 'Please select a time slot');
                  return;
                }
                setState(() => _currentStep++);
              } else {
                _bookAppointment();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: [
              Step(
                title: const Text('Select Date'),
                content: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: controller.selectedDate ?? DateTime.now(),
                  selectedDayPredicate: (day) => isSameDay(controller.selectedDate, day),
                  onDaySelected: (selected, focused) {
                    controller.selectDate(selected);
                  },
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Select Time'),
                content: controller.isSlotsLoading
                    ? const CircularProgressIndicator()
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: controller.availableSlots.length,
                        itemBuilder: (context, index) {
                          final slot = controller.availableSlots[index];
                          final isSelected = controller.selectedSlot?.id == slot.id;
                          return ElevatedButton(
                            onPressed: slot.isBooked ? null : () => controller.selectSlot(slot),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? AppTheme.primaryColor : null,
                            ),
                            child: Text(slot.name, style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Contact Details'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          );
        },
      ),
    );
  }
}
