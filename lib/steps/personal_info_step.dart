import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';

class PersonalInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController linkedinController;
  final TextEditingController githubController;
  final TextEditingController summaryController;

  final String countryCode;
  final Uint8List? selectedPhotoBytes;
  final ValueChanged<String?> onCountryCodeChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onDeletePhoto;

  const PersonalInfoStep({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.linkedinController,
    required this.githubController,
    required this.summaryController,
    required this.countryCode,
    required this.selectedPhotoBytes,
    required this.onCountryCodeChanged,
    required this.onPickPhoto,
    required this.onDeletePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: countryCode,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onCountryCodeChanged,
                  items: const [
                    DropdownMenuItem(value: '+62', child: Text('🇮🇩 +62')),
                    DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                    DropdownMenuItem(value: '+65', child: Text('🇸🇬 +65')),
                    DropdownMenuItem(value: '+60', child: Text('🇲🇾 +60')),
                    DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'City, Country',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: linkedinController,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn URL (e.g. linkedin.com/in/user)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: githubController,
                  decoration: const InputDecoration(
                    labelText: 'Portfolio Link (e.g. portfolio.me/user)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Karakter info counter interaktif di Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Self Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder(
                valueListenable: summaryController,
                builder: (context, value, child) {
                  final len = value.text.length;
                  final isIdeal = len >= 100 && len <= 150;
                  return Text(
                    'Recommended: 100 to 150 chars ($len)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isIdeal
                          ? Colors.green
                          : (len > 150 ? Colors.red : Colors.grey),
                      fontWeight: isIdeal ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: summaryController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Describe yourself briefly...',
              border: OutlineInputBorder(),
              counterText: '', // Hide default counter
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onPickPhoto,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedPhotoBytes != null
                        ? Colors.blue[50]
                        : Colors.grey[50],
                  ),
                  child: Center(
                    child: selectedPhotoBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              selectedPhotoBytes!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Upload Photo',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '(Optional)',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (selectedPhotoBytes != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Hapus Foto',
                  onPressed: onDeletePhoto,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
