import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<String, dynamic>? userData;
  String? prefillBrandName;

  static const platform = MethodChannel('reservation_channel');

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 Inicializando ReservationPage...');
    debugPrint('📱 MethodChannel configurado: ${platform.name}');
    _getUserData();
    _getPrefillData();
  }

  Future<void> _getUserData() async {
    try {
      debugPrint('🔄 Intentando obtener datos de usuario desde MethodChannel...');
      final result = await platform.invokeMethod('getUserData');
      debugPrint('Datos de usuario obtenidos exitosamente: ${result.toString()}');
      setState(() {
        userData = {
          'id': result['id'],
          'name': result['name'],
          'email': result['email'],
        };
      });
    } catch (e) {
      debugPrint('Error obteniendo datos desde getUserData: $e');
      
      debugPrint('Intentando fallback con getUserPrefs...');
      final ok = await _getUserDataFromNativePrefs();
      if (!ok) {
        debugPrint('Fallback también fallo');
        setState(() { error = 'Error obteniendo datos de usuario: $e'; });
      } else {
        debugPrint('Fallback exitoso');
      }
    }
  } 
  
  Future<bool> _getUserDataFromNativePrefs() async {
    try {
      debugPrint('Llamando a getUserPrefs desde Flutter...');
      final result = await platform.invokeMethod('getUserPrefs');
      debugPrint('Resultado de getUserPrefs: ${result.toString()}');
      if (result != null) {
        final email = (result['email'] as String?) ?? '';
        debugPrint('Email recibido: "$email"');
        if (email.isNotEmpty) {
          setState(() {
            userData = {
              'id': (result['id'] as String?) ?? '',
              'name': (result['name'] as String?) ?? '',
              'email': email,
            };
          });
          debugPrint('Usuario configurado desde preferencias: ${userData.toString()}');
          return true;
        } else {
          debugPrint('Email vacío en preferencias');
        }
      } else {
        debugPrint('Resultado nulo de getUserPrefs');
      }
    } catch (e) {
      debugPrint('Error en getUserDataFromNativePrefs: $e');
    }
    return false;
  }

  Future<void> _getPrefillData() async {
    try {
      final result = await platform.invokeMethod('getReservationPrefill');
      if (result != null) {
        setState(() {
          prefillBrandName = (result['brandName'] as String?)?.trim();
          final model = (result['model'] as String?) ?? '';
          final plate = (result['licensePlate'] as String?) ?? '';
          final email = (result['ownerEmail'] as String?) ?? '';
          final price = (result['sellingPrice'] as String?) ?? '';
          vehicleData.model = model;
          vehicleData.licensePlate = plate;
          vehicleData.ownerEmail = email;
          vehicleData.sellingPrice = price;
          final dateStr = (result['selectedDate'] as String?) ?? '';
          final timeStr = (result['selectedTime'] as String?) ?? '';
          if (dateStr.isNotEmpty && timeStr.isNotEmpty) {
            try {
              final ds = dateStr.split('-');
              final ts = timeStr.split(':');
              final year = int.parse(ds[0]);
              final month = int.parse(ds[1]);
              final day = int.parse(ds[2]);
              final hour = int.parse(ts[0]);
              final minute = int.parse(ts[1]);
              calendarSelection.selectedDateTime = DateTime(year, month, day, hour, minute);
            } catch (_) {
              
            }
          }
        });
      }
    } catch (_) {
      
    }
  }

  void _onConfirm() async {
    debugPrint('Iniciando proceso de confirmación de reserva...');
    debugPrint('Datos de usuario actuales: ${userData.toString()}');
    setState(() { error = null; successMessage = null; });
    if (userData == null) { 
      debugPrint('No hay datos de usuario disponibles');
      setState(() { error = 'Datos de usuario no disponibles'; }); 
      return; 
    }
    if (vehicleData.brand.isEmpty) { setState(() { error = 'Seleccione una marca'; }); return; }
    if (vehicleData.model.isEmpty) { setState(() { error = 'Ingrese el modelo'; }); return; }
    
    if (!RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$').hasMatch(vehicleData.licensePlate)) { setState(() { error = 'Formato de placa inválido (ABC-123)'; }); return; }
    if (vehicleData.ownerEmail.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(vehicleData.ownerEmail)) { setState(() { error = 'Email inválido'; }); return; }
    final priceValue = int.tryParse(vehicleData.sellingPrice);
    if (vehicleData.sellingPrice.isEmpty || priceValue == null || priceValue <= 0) { setState(() { error = 'Ingrese un precio de venta válido (mayor que 0)'; }); return; }
    if (vehicleData.imageUrl == null) { setState(() { error = 'Suba una imagen del vehículo'; }); return; }
    if (calendarSelection.selectedDateTime == null) { setState(() { error = 'Seleccione fecha y hora'; }); return; }

    final dt = calendarSelection.selectedDateTime!;
    const validHours = [9, 11, 13, 15, 17];
    if (!validHours.contains(dt.hour) || dt.minute != 0 || dt.second != 0) {
      setState(() { error = 'Por favor, seleccione una hora válida: 9:00 AM, 11:00 AM, 1:00 PM, 3:00 PM o 5:00 PM.'; });
      return;
    }

    final inspectionDateTime = calendarSelection.selectedDateTime!.toUtc().toIso8601String();

    final payload = {
      'userId': userData!['id'],
      'reservationName': userData!['name'],
      'reservationEmail': userData!['email'],
      'imageUrl': vehicleData.imageUrl,
      'brand': vehicleData.brand,
      'model': vehicleData.model,
      'licensePlate': vehicleData.licensePlate,
      'inspectionDateTime': inspectionDateTime,
      'price': vehicleData.sellingPrice,
      'status': 'pending',
    };

    setState(() { isLoading = true; });
    try {
      await service.createReservation(payload);
      setState(() { successMessage = 'Reserva confirmada exitosamente'; });
      
      try {
        final moved = await platform.invokeMethod('navigateToDashboard');
        if (mounted && (moved == true)) {
        
          SystemNavigator.pop();
        }
      } catch (e) {
        
        setState(() { error = 'No se pudo navegar al dashboard: $e'; });
      }
    } catch (e) {
      setState(() { error = 'Error al crear reserva: $e'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar Inspección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Foto del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          VehicleSpecComponent(
            onDataChanged: (d) => setState(() => vehicleData = d),
            initialData: vehicleData,
            initialBrandName: prefillBrandName,
          ),
          const SizedBox(height: 12),
          const Text('RESERVAR HORA DE INSPECCIÓN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CalendarComponent(onSelectionChanged: (s) => setState(() => calendarSelection.selectedDateTime = s.selectedDateTime)),
          const SizedBox(height: 16),
          if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
          if (successMessage != null) Text(successMessage!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _onConfirm,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size.fromHeight(48)),
            child: Text(isLoading ? 'Procesando...' : 'Confirmar Reserva', style: const TextStyle(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}