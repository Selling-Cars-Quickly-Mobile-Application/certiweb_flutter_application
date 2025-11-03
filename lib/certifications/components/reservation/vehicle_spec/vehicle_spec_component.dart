import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VehicleSpecData {
  String brand;
  String model;
  String licensePlate;
  String ownerEmail;
  String sellingPrice;
  Uint8List? imageBytes;
  String? imageUrl;

  VehicleSpecData({
    this.brand = '',
    this.model = '',
    this.licensePlate = '',
    this.ownerEmail = '',
    this.sellingPrice = '',
    this.imageBytes,
    this.imageUrl,
  });
}

class VehicleSpecComponent extends StatefulWidget {
  final void Function(VehicleSpecData data) onDataChanged;
  const VehicleSpecComponent({super.key, required this.onDataChanged});

  @override
  State<VehicleSpecComponent> createState() => _VehicleSpecComponentState();
}

class _VehicleSpecComponentState extends State<VehicleSpecComponent> {
  final brands = const ['Toyota', 'Honda', 'Nissan', 'Hyundai', 'Kia', 'Ford'];
  final data = VehicleSpecData();

  final _plateReg = RegExp(r'^[A-Z]{3}-\d{3}$');

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null && res.files.isNotEmpty) {
      final f = res.files.first;
      setState(() {
        data.imageBytes = f.bytes;
      });
      widget.onDataChanged(data);
    }
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
            OutlinedButton(onPressed: _pickImage, child: const Text('+Select JPG File')),
            const SizedBox(width: 12),
            Expanded(child: Text(data.imageBytes != null ? 'Image selected' : 'No file chosen')),
          ]),
          const SizedBox(height: 8),
          Text('JPG files only. Max ~2MB', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          Text('Vehicle Data', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Brand'),
            items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            value: data.brand.isEmpty ? null : data.brand,
            onChanged: (v) {
              setState(() => data.brand = v ?? '');
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Model', hintText: 'E.g.: Corolla, Yaris, Hilux'),
            onChanged: (v) {
              setState(() => data.model = v);
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'License Plate', hintText: 'Format: ABC-123'),
            onChanged: (v) {
              setState(() => data.licensePlate = v.toUpperCase());
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 4),
          Text('Format: ABC-123', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: "Owner's Email"),
            onChanged: (v) {
              setState(() => data.ownerEmail = v);
              widget.onDataChanged(data);
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Selling Price (PEN)', hintText: 'E.g: 50000'),
            keyboardType: TextInputType.number,
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