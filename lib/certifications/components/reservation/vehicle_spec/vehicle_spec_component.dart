import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:certiweb_flutter_application/certifications/services/imgbb_api_service.dart';

class VehicleSpecData {
  String brand = '';
  String model = '';
  String licensePlate = '';
  String ownerEmail = '';
  String sellingPrice = '';
  Uint8List? imageBytes;
  String? imageUrl;
  String? imageId;
  bool imageUploaded = false;

  VehicleSpecData();
}

class VehicleSpecComponent extends StatefulWidget {
  final void Function(VehicleSpecData data) onDataChanged;
  final VehicleSpecData? initialData;
  final String? initialBrandName;
  const VehicleSpecComponent({super.key, required this.onDataChanged, this.initialData, this.initialBrandName});

  @override
  State<VehicleSpecComponent> createState() => _VehicleSpecComponentState();
}

class _VehicleSpecComponentState extends State<VehicleSpecComponent> {
  final brands = const [
    'Toyota', 'Nissan', 'Hyundai', 'Kia', 'Chevrolet', 'Suzuki', 'Mitsubishi', 'Honda', 'Volkswagen', 'Ford', 'Mercedes-Benz', 'Audi', 'BMW'
  ];
  final data = VehicleSpecData();
  bool isUploading = false;
  String selectedBrandName = '';
  final _imgbbService = ImgBBApiService();

  String brandToCode(String name) {
    switch (name) {
      case 'Toyota':
        return 'toyota';
      case 'Nissan':
        return 'nissan';
      case 'Hyundai':
        return 'hyundai';
      case 'Kia':
        return 'kia';
      case 'Chevrolet':
        return 'chevrolet';
      case 'Suzuki':
        return 'suzuki';
      case 'Mitsubishi':
        return 'mitsubishi';
      case 'Honda':
        return 'honda';
      case 'Volkswagen':
        return 'volkswagen';
      case 'Ford':
        return 'ford';
      case 'Mercedes-Benz':
        return 'mercedes';
      case 'Audi':
        return 'audi';
      case 'BMW':
        return 'bmw';
      default:
        return name.toLowerCase();
    }
  }

  String _formatPlateString(String v) {
    String formatted = v.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9-]'), '');
    formatted = formatted.replaceAll('-', '');
    if (formatted.length > 3) {
      formatted = '${formatted.substring(0, 3)}-${formatted.substring(3)}';
    }
    if (formatted.length > 7) formatted = formatted.substring(0, 7);
    return formatted;
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.initialBrandName != null && widget.initialBrandName!.isNotEmpty) {
      selectedBrandName = widget.initialBrandName!;
      data.brand = brandToCode(widget.initialBrandName!);
    }
    final initial = widget.initialData;
    if (initial != null) {
      if (initial.model.isNotEmpty) {
        data.model = initial.model;
      }
      if (initial.licensePlate.isNotEmpty) {
        data.licensePlate = _formatPlateString(initial.licensePlate);
      }
      if (initial.ownerEmail.isNotEmpty) {
        data.ownerEmail = initial.ownerEmail;
      }
      if (initial.sellingPrice.isNotEmpty) {
        data.sellingPrice = initial.sellingPrice.replaceAll(RegExp(r'[^0-9]'), '');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDataChanged(data);
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    
    final messenger = ScaffoldMessenger.maybeOf(context);
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (!mounted) return;
    if (res != null && res.files.isNotEmpty) {
      final f = res.files.first;
      if (f.extension?.toLowerCase() != 'jpg' && f.extension?.toLowerCase() != 'jpeg') {
        
        messenger?.showSnackBar(const SnackBar(content: Text('Solo se permiten imágenes JPG')));
        return;
      }
      setState(() {
        data.imageBytes = f.bytes;
        data.imageUploaded = false;
        isUploading = true;
      });
      try {
        final result = await _imgbbService.uploadImageBytes(f.bytes!, fileName: f.name);
        if (!mounted) return;
        final url = result['url'] as String?;
        final id = result['id'] as String?;
        if (url == null) throw Exception('Respuesta inválida de ImgBB');
        setState(() {
          data.imageUrl = url;
          data.imageId = id;
          data.imageUploaded = true;
        });
        messenger?.showSnackBar(SnackBar(content: Text('Imagen subida exitosamente: $url${id != null ? ' (ID: $id)' : ''}')));
      } catch (e) {
        
        messenger?.showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
        if (mounted) { setState(() { data.imageUploaded = false; }); }
      } finally {
        if (mounted) { setState(() { isUploading = false; }); }
        if (mounted) { widget.onDataChanged(data); }
      }
    }
  }

  void _formatPlate(String v) {
    String formatted = v.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9-]'), '');
    formatted = formatted.replaceAll('-', '');
    if (formatted.length > 3) {
      formatted = '${formatted.substring(0, 3)}-${formatted.substring(3)}';
    }
    if (formatted.length > 7) formatted = formatted.substring(0, 7);
    setState(() => data.licensePlate = formatted);
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFEFF7ED),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Vehicle Photo', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF2E7D32))),
          const SizedBox(height: 12),
          Row(children: [
            OutlinedButton(onPressed: isUploading ? null : _pickAndUploadImage, child: Text(isUploading ? 'Subiendo...' : '+Seleccionar JPG')),
            const SizedBox(width: 12),
            Expanded(child: Text(data.imageUrl != null ? 'Imagen subida' : (data.imageBytes != null ? 'Imagen seleccionada' : 'Ningún archivo elegido'))),
          ]),
          const SizedBox(height: 8),
          Text('Solo JPG. Máx ~1MB', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          Text('Datos del Vehículo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Marca'),
            items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            initialValue: selectedBrandName.isEmpty ? null : selectedBrandName,
            onChanged: (v) {
              setState(() {
                selectedBrandName = v ?? '';
                data.brand = v != null ? brandToCode(v) : '';
              });
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Modelo', hintText: 'Ej: Corolla, Yaris, Hilux'),
            initialValue: data.model.isNotEmpty ? data.model : null,
            onChanged: (v) {
              setState(() => data.model = v);
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Placa', hintText: 'Formato: ABC-123'),
            initialValue: data.licensePlate.isNotEmpty ? data.licensePlate : null,
            onChanged: _formatPlate,
            maxLength: 7,
          ),
          const SizedBox(height: 4),
          Text('Formato: ABC-123', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email del Propietario'),
            keyboardType: TextInputType.emailAddress,
            initialValue: data.ownerEmail.isNotEmpty ? data.ownerEmail : null,
            onChanged: (v) {
              setState(() => data.ownerEmail = v);
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Precio de Venta (PEN)', hintText: 'Ej: 50000'),
            keyboardType: TextInputType.number,
            initialValue: data.sellingPrice.isNotEmpty ? data.sellingPrice : null,
            onChanged: (v) {
              setState(() => data.sellingPrice = v.replaceAll(RegExp(r'[^0-9]'), ''));
              widget.onDataChanged(data);
            },
          ),
        ]),
      ),
    );
  }
}