import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_models.dart';
import '../steps/personal_info_step.dart';
import '../steps/work_experience_step.dart';
import '../steps/education_step.dart';
import '../steps/organisational_step.dart';
import '../steps/others_step.dart';
import 'components/custom_stepper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MainWorkspace extends StatefulWidget {
  const MainWorkspace({super.key});

  @override
  State<MainWorkspace> createState() => _MainWorkspaceState();
}

class _MainWorkspaceState extends State<MainWorkspace> {
  int _activeStep = 0; // 0 sampai 5 (Step 1-6)
  String _selectedCountryCode = '+62';
  Uint8List? _profileImageBytes;

  // Step 1: Personal Info Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _addressController = TextEditingController();
  final _summaryController = TextEditingController();

  // Step 2-5: List Data (CRUD State)
  final List<Experience> _workList = [];
  final List<Education> _educationList = [];
  final List<Organisation> _orgList = [];

  // Step 5: Others (Skills & Achievements)
  List<String> _skillsList = [];
  final _languagesController = TextEditingController();
  final List<Achievement> _achievementList = [];

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      if (kDebugMode) {
        print(
        '✅ Picture selected! Size: ${result.files.first.bytes?.length} bytes',
      );
      }

      setState(() {
        _profileImageBytes = result.files.first.bytes;
      });
    } else {
      if (kDebugMode) {
        print('❌ Picture selection cancelled.');
      }
    }
  }

// --- SISTEM AUTOSAVE DRAFT ---
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kumpulkan semua data ke dalam format Map
    final draftData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'linkedin': _linkedinController.text,
      'portfolio': _portfolioController.text,
      'address': _addressController.text,
      'summary': _summaryController.text,
      'countryCode': _selectedCountryCode,
      'skillsList': _skillsList,
      'languages': _languagesController.text,
      'achievementList': _achievementList.map((e) => e.toJson()).toList(),
      'workList': _workList.map((e) => e.toJson()).toList(),
      'educationList': _educationList.map((e) => e.toJson()).toList(),
      'orgList': _orgList.map((e) => e.toJson()).toList(),
    };

    // Simpan dalam format JSON String
    await prefs.setString('cv_active_draft', jsonEncode(draftData));
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString('cv_active_draft');

    if (draftString != null) {
      final draftData = jsonDecode(draftString);

      setState(() {
        _nameController.text = draftData['name'] ?? '';
        _phoneController.text = draftData['phone'] ?? '';
        _emailController.text = draftData['email'] ?? '';
        _linkedinController.text = draftData['linkedin'] ?? '';
        _portfolioController.text = draftData['portfolio'] ?? '';
        _addressController.text = draftData['address'] ?? '';
        _summaryController.text = draftData['summary'] ?? '';
        _selectedCountryCode = draftData['countryCode'] ?? '+62';
        _skillsList = List<String>.from(draftData['skillsList'] ?? []);
        _languagesController.text = draftData['languages'] ?? '';
        
        if (draftData['achievementList'] != null) {
          _achievementList.clear();
          _achievementList.addAll(
            (draftData['achievementList'] as List)
                .map((e) => Achievement.fromJson(e))
                .toList(),
          );
        }

        if (draftData['workList'] != null) {
          _workList.clear();
          _workList.addAll(
            (draftData['workList'] as List)
                .map((e) => Experience.fromJson(e))
                .toList(),
          );
        }
        if (draftData['educationList'] != null) {
          _educationList.clear();
          _educationList.addAll(
            (draftData['educationList'] as List)
                .map((e) => Education.fromJson(e))
                .toList(),
          );
        }
        if (draftData['orgList'] != null) {
          _orgList.clear();
          _orgList.addAll(
            (draftData['orgList'] as List)
                .map((e) => Organisation.fromJson(e))
                .toList(),
          );
        }
      });
    }
  }

  Timer? _debounce;

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {});
      _saveDraft();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _languagesController.addListener(_onTextChanged);

    _nameController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
    _linkedinController.addListener(_onTextChanged);
    _portfolioController.addListener(_onTextChanged);
    _addressController.addListener(_onTextChanged);
    _summaryController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    _languagesController.addListener(_onTextChanged);
    super.dispose();
  }

  // --- PDF GENERATOR ENGINE ---
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            // HEADER SECTION
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (_profileImageBytes != null)
                    pw.Container(
                      width: 60,
                      height: 60,
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(_profileImageBytes!),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  pw.Text(
                    _nameController.text.isEmpty
                        ? 'YOUR NAME'
                        : _nameController.text.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    [
                      if (_addressController.text.isNotEmpty)
                        _addressController.text,
                      if (_phoneController.text.isNotEmpty)
                        '$_selectedCountryCode ${_phoneController.text}',
                      if (_emailController.text.isNotEmpty)
                        _emailController.text,
                    ].join(' | '),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  if (_linkedinController.text.isNotEmpty ||
                      _portfolioController.text.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.RichText(
                        text: pw.TextSpan(
                          style: const pw.TextStyle(fontSize: 9), // Style dasar
                          children: [
                            if (_linkedinController.text.isNotEmpty)
                              pw.TextSpan(
                                text: _linkedinController.text,
                                style: const pw.TextStyle(
                                  color: PdfColors.blue800,
                                ),
                              ),

                            if (_linkedinController.text.isNotEmpty &&
                                _portfolioController.text.isNotEmpty)
                              const pw.TextSpan(
                                text: ' | ',
                                style: pw.TextStyle(color: PdfColors.black),
                              ),

                            if (_portfolioController.text.isNotEmpty)
                              pw.TextSpan(
                                text: _portfolioController.text,
                                style: const pw.TextStyle(
                                  color: PdfColors.blue800,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // SUMMARY SECTION
            if (_summaryController.text.isNotEmpty) ...[
              pw.Paragraph(
                text: _summaryController.text,
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2),
              ),
              pw.SizedBox(height: 8),
            ],

            // WORK EXPERIENCE SECTION
            if (_workList.isNotEmpty) ...[
              _buildSectionHeader('WORK EXPERIENCE'),
              ..._workList.map(
                (exp) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.company,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            exp.duration,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Text(
                        exp.role,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      if (exp.description.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2, left: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: exp.description
                                .split(';')
                                .where((s) => s.trim().isNotEmpty)
                                .map(
                                  (bullet) => pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 3,
                                        height: 3,
                                        margin: const pw.EdgeInsets.only(
                                          top: 4,
                                          right: 6,
                                        ),
                                        decoration: const pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          bullet.trim(),
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            // ORGANISATIONAL EXPERIENCE SECTION
            if (_orgList.isNotEmpty) ...[
              _buildSectionHeader('ORGANISATIONAL EXPERIENCE'),
              ..._orgList.map(
                (org) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            org.name,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            org.duration,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Text(
                        org.role,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      if (org.description.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2, left: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: org.description
                                .split(';')
                                .where((s) => s.trim().isNotEmpty)
                                .map(
                                  (bullet) => pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 3,
                                        height: 3,
                                        margin: const pw.EdgeInsets.only(
                                          top: 4,
                                          right: 6,
                                        ),
                                        decoration: const pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          bullet.trim(),
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            // EDUCATION LEVEL SECTION
            if (_educationList.isNotEmpty) ...[
              _buildSectionHeader('EDUCATION'),
              ..._educationList.map(
                (edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            edu.school,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            edu.duration,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Text(
                        edu.degree,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      if (edu.description.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2, left: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: edu.description
                                .split(';')
                                .where((s) => s.trim().isNotEmpty)
                                .map(
                                  (bullet) => pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 3,
                                        height: 3,
                                        margin: const pw.EdgeInsets.only(
                                          top: 4,
                                          right: 6,
                                        ),
                                        decoration: const pw.BoxDecoration(
                                          shape: pw.BoxShape.circle,
                                          color: PdfColors.black,
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          bullet.trim(),
                                          style: const pw.TextStyle(
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            // SKILLS & ACHIEVEMENTS
            // SKILLS, LANGUAGES & ACHIEVEMENTS SECTION
            if (_skillsList.isNotEmpty ||
                _languagesController.text.isNotEmpty ||
                _achievementList.isNotEmpty) ...[
              _buildSectionHeader('SKILLS, LANGUAGES & ACHIEVEMENTS'),

              if (_skillsList.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Skills: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9.5,
                          ),
                        ),
                        pw.TextSpan(
                          text: _skillsList.join(', '),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_languagesController.text.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Languages: ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9.5,
                          ),
                        ),
                        pw.TextSpan(
                          text: _languagesController.text,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_achievementList.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'Projects & Certificates:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
                ..._achievementList.map((ach) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4, left: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 3,
                          height: 3,
                          margin: const pw.EdgeInsets.only(top: 4, right: 6),
                          decoration: const pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: '${ach.title} (${ach.year})',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                                if (ach.description.isNotEmpty)
                                  pw.TextSpan(
                                    text: ' - ${ach.description}',
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                if (ach.link.isNotEmpty)
                                  pw.TextSpan(
                                    text:
                                        ' [View]',
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                      color: PdfColors.blue800,
                                    ),
                                    annotation: pw.AnnotationUrl(
                                      ach.link,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 6),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Divider(thickness: 1, color: PdfColors.black),
        ),
      ],
    );
  }

  // --- UI UTAMA APP ---
  @override
  Widget build(BuildContext context) {
    final stepsNames = [
      'Personal',
      'Professional',
      'Education',
      'Organisational',
      'Others',
      'Review',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'sf',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Seefee Workspace',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: Row(
        children: [
          // PANEL KIRI
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gunakan custom stepper yang sudah di-import
                  CustomStepper(steps: stepsNames, activeStep: _activeStep),
                  const SizedBox(height: 24),

                  // Form Dinamis
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildActiveStepForm(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Navigasi Bawah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _activeStep > 0
                            ? () => setState(() => _activeStep--)
                            : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('BACK'),
                      ),
                      ElevatedButton(
                        onPressed: _activeStep < 5
                            ? () => setState(() => _activeStep++)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _activeStep == 4
                              ? 'SAVE & FINISH'
                              : (_activeStep == 5
                                    ? 'COMPLETED'
                                    : 'SAVE & CONTINUE'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // PANEL KANAN (Preview)
          Expanded(
            flex: 6,
            child: Container(
              color: const Color(0xFFF1F5F9),
              child: Stack(
                children: [
                  PdfPreview(
                    build: (format) => _generatePdf(format),
                    allowPrinting: false,
                    allowSharing: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    actions: [
                      PdfPreviewAction(
                        icon: const Icon(Icons.download),
                        onPressed: (context, build, pageFormat) async {
                          final bytes = await build(pageFormat);
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename:
                                'CV_${_nameController.text.isNotEmpty ? _nameController.text.replaceAll(" ", "_") : "Draft"}.pdf',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ROUTING FORM ---
  Widget _buildActiveStepForm() {
    switch (_activeStep) {
      case 0:
        return PersonalInfoStep(
          nameController: _nameController,
          phoneController: _phoneController,
          emailController: _emailController,
          addressController: _addressController,
          linkedinController: _linkedinController,
          githubController: _portfolioController,
          summaryController: _summaryController,
          countryCode: _selectedCountryCode,
          selectedPhotoBytes: _profileImageBytes,
          onCountryCodeChanged: (val) {
            setState(() => _selectedCountryCode = val!);
            _saveDraft();
          },
          onPickPhoto: () async {
            await _pickImage();
            _saveDraft();
          },
          onDeletePhoto: () {
            setState(() => _profileImageBytes = null);
            _saveDraft();
          },
        );
      case 1:
        return WorkExperienceStep(
          workList: _workList,
          onListChanged: () {
            setState(() {});
            _saveDraft();
          },
        );
      case 2:
        return EducationStep(
          educationList: _educationList,
          onListChanged: () {
            setState(() {});
            _saveDraft();
          },
        );
      case 3:
        return OrganisationalStep(
          orgList: _orgList,
          onListChanged: () {
            setState(() {});
            _saveDraft();
          },
        );
      case 4:
        return OthersStep(
          skillsList: _skillsList,
          languagesController: _languagesController,
          achievementList: _achievementList,
          onDataChanged: () {
            setState(() {});
            _saveDraft();
          },
        );
        
      case 5:
        return _buildReviewForm();
      default:
        return const SizedBox();
    }
  }

  // Widget _buildPersonalInfoForm() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Personal Information',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: _nameController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Full Name *',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.end,
  //                 children: [
  //                   DropdownButton<String>(
  //                     value: _selectedCountryCode,
  //                     items: _countryCodes
  //                         .map(
  //                           (code) => DropdownMenuItem(
  //                             value: code,
  //                             child: Text(code),
  //                           ),
  //                         )
  //                         .toList(),
  //                     onChanged: (val) =>
  //                         setState(() => _selectedCountryCode = val!),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Expanded(
  //                     child: TextField(
  //                       controller: _phoneController,
  //                       keyboardType: TextInputType.number,
  //                       inputFormatters: [
  //                         FilteringTextInputFormatter.digitsOnly,
  //                       ],
  //                       decoration: const InputDecoration(
  //                         labelText: 'Phone Number',
  //                         border: OutlineInputBorder(),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: _emailController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Email Address',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: TextField(
  //                 controller: _addressController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'City, Country',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: _linkedinController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'LinkedIn URL Profile',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: TextField(
  //                 controller: _portfolioController,
  //                 decoration: const InputDecoration(
  //                   labelText: 'portfolio / Portfolio Link',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         const Text(
  //           'Self Summary',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         TextField(
  //           controller: _summaryController,
  //           maxLines: 4,
  //           maxLength: 500,
  //           decoration: const InputDecoration(
  //             hintText: 'Describe yourself briefly...',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         const Divider(),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             GestureDetector(
  //               onTap: () async => await _pickImage(),
  //               child: Container(
  //                 width: 120,
  //                 height: 120,
  //                 clipBehavior: Clip.hardEdge,
  //                 decoration: BoxDecoration(
  //                   border: Border.all(
  //                     color: Colors.grey[300]!,
  //                     style: BorderStyle.solid,
  //                   ),
  //                   borderRadius: BorderRadius.circular(12),
  //                   color: _useDummyPhoto ? Colors.teal[50] : Colors.grey[50],
  //                 ),
  //                 child: _profileImageBytes != null
  //                     ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
  //                     : Center(
  //                         child: _useDummyPhoto
  //                             ? const Icon(
  //                                 Icons.account_circle,
  //                                 size: 64,
  //                                 color: Colors.teal,
  //                               )
  //                             : const Column(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Icon(Icons.add_a_photo, color: Colors.grey),
  //                                   SizedBox(height: 4),
  //                                   Text(
  //                                     'Add Photo',
  //                                     style: TextStyle(
  //                                       fontSize: 10,
  //                                       color: Colors.grey,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                       ),
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 16,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildOthersForm() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Skills, Languages & Achievements',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16),
  //         // AREA SKILLS DENGAN CHIPS
  //         const Text(
  //           'Key Skills',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         Wrap(
  //           spacing: 8.0,
  //           runSpacing: 4.0,
  //           children: _skillsList.map((skill) {
  //             return Chip(
  //               label: Text(skill, style: const TextStyle(fontSize: 12)),
  //               backgroundColor: Colors.blue[50],
  //               deleteIcon: const Icon(Icons.close, size: 16),
  //               onDeleted: () {
  //                 setState(() => _skillsList.remove(skill));
  //                 _saveDraft();
  //               },
  //             );
  //           }).toList(),
  //         ),
  //         const SizedBox(height: 8),
  //         TextField(
  //           controller: _skillInputController,
  //           decoration: InputDecoration(
  //             hintText: 'Type a skill and press Enter (e.g. Flutter)',
  //             border: const OutlineInputBorder(),
  //             suffixIcon: IconButton(
  //               icon: const Icon(Icons.add_circle, color: Colors.blue),
  //               onPressed: () {
  //                 if (_skillInputController.text.trim().isNotEmpty) {
  //                   setState(() {
  //                     _skillsList.add(_skillInputController.text.trim());
  //                     _skillInputController.clear();
  //                   });
  //                   _saveDraft();
  //                 }
  //               },
  //             ),
  //           ),
  //           onSubmitted: (val) {
  //             if (val.trim().isNotEmpty) {
  //               setState(() {
  //                 _skillsList.add(val.trim());
  //                 _skillInputController.clear();
  //               });
  //               _saveDraft();
  //             }
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //         // AREA BAHASA
  //         TextField(
  //           controller: _languagesController,
  //           decoration: const InputDecoration(
  //             labelText: 'Languages',
  //             hintText: 'e.g. Indonesian (Native), English (Fluent)',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         // AREA ACHIEVEMENTS
  //         TextField(
  //           controller: _achievementsController,
  //           maxLines: 3,
  //           decoration: const InputDecoration(
  //             labelText: 'Achievements / Awards',
  //             hintText: 'e.g. 1st Place National Hackathon 2024...',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  
  Widget _buildReviewForm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Your Resume is Ready!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'All details have been successfully organized. Please review the live preview layout in the right panel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
