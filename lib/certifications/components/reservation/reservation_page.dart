import 'package:flutter/material.dart';
import 'package:certiweb_flutter_application/certifications/components/reservation/vehicle_spec/vehicle_spec_component.dart';
import 'package:certiweb_flutter_application/certifications/components/reservation/calendar/calendar_component.dart';
import 'package:certiweb_flutter_application/certifications/services/reservation_service.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  VehicleSpecData vehicleData = VehicleSpecData();
  final calendarSelection = CalendarSelection();
  final service = ReservationService();
  bool isLoading = false;
  String? error;
  String? successMessage;

  void _onConfirm() async {
    setState(() { error = null; successMessage = null; });
    // Validations similar to Vue components
    if (vehicleData.brand.isEmpty) { setState(() { error = 'Please select a brand'; }); return; }
    if (vehicleData.model.isEmpty) { setState(() { error = 'Please enter model'; }); return; }
    if (!RegExp(r'^[A-Z]{3}-\d{3}$').hasMatch(vehicleData.licensePlate)) { setState(() { error = 'Invalid license plate format (ABC-123)'; }); return; }
    if (vehicleData.ownerEmail.isEmpty) { setState(() { error = 'Invalid email'; }); return; }
    if (vehicleData.sellingPrice.isEmpty) { setState(() { error = 'Enter selling price'; }); return; }
    if (calendarSelection.date == null) { setState(() { error = 'Please select a date'; }); return; }
    if (calendarSelection.time == null) { setState(() { error = 'Please select a time'; }); return; }

    // TODO: read user from Android SharedPreferences via MethodChannel
    const userId = '1';
    final notes = '${vehicleData.brand} ${vehicleData.model} - ${vehicleData.licensePlate} - PEN ${vehicleData.sellingPrice}';
    final d = calendarSelection.date!;
    final dateStr = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    setState(() { isLoading = true; });
    try {
      await service.createReservation(
        userId: userId,
        date: dateStr,
        time: calendarSelection.time!,
        serviceType: 'vehicle_certification',
        notes: notes,
      );
      setState(() { successMessage = 'Reservation confirmed'; });
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserve Inspection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Upload Vehicle Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          VehicleSpecComponent(onDataChanged: (d) => setState(() => vehicleData = d)),
          const SizedBox(height: 12),
          const Text('BOOK INSPECTION TIME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CalendarComponent(onSelectionChanged: (s) => setState(() => calendarSelection
            ..date = s.date
            ..time = s.time)),
          const SizedBox(height: 16),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          if (successMessage != null) Text(successMessage!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size.fromHeight(48)),
            child: Text(isLoading ? 'Processing...' : '✓ Confirm Reservation', style: const TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}