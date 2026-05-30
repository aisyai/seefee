import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seefee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk menangkap input teks secara real-time
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tiap kali ngetik, aplikasi bakal nge-trigger rebuild buat live preview
    _nameController.addListener(() => setState(() {}));
    _roleController.addListener(() => setState(() {}));
  }

  // FUNGSI UTAMA: Mengubah data input menjadi dokumen PDF
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                _roleController.text.isEmpty ? 'Professional Role' : _roleController.text,
                style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
              ),
              pw.Divider(),
              // Nanti di sini tinggal ditambahin komponen tile dsb.
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        elevation: 2,
      ),
      body: Row(
        children: [
          // PANEL KIRI: Tempat Input CRUD Data
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Personal Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role (e.g. Flutter Developer)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // PANEL KANAN: Live Preview PDF & Download Button
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                allowPrinting: false, // Matikan fitur print biasa jika gak butuh
                canChangePageFormat: false, // Kunci ke format A4/default
                initialPageFormat: PdfPageFormat.a4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}