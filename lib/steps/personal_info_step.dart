import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // List default untuk dropdown kode negara
    final List<String> countryCodes = ['+62', '+1', '+44', '+65', '+60'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // BARIS 1: Nama dan Telepon
          Row(
            children: [
              Expanded(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: countryCode,
                      items: countryCodes
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                      onChanged: onCountryCodeChanged,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // BARIS 2: Email dan Alamat
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

          // BARIS 3: LinkedIn dan GitHub
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: linkedinController,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn URL Profile',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: githubController,
                  decoration: const InputDecoration(
                    labelText: 'GitHub / Portfolio Link',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BARIS 4: Summary
          const Text(
            'Self Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: summaryController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Describe yourself briefly...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // BARIS 5: Upload Foto
          Row(
            children: [
              GestureDetector(
                onTap: onPickPhoto,
                child: Container(
                  width: 120,
                  height: 120,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: selectedPhotoBytes != null
                      ? Image.memory(selectedPhotoBytes!, fit: BoxFit.cover)
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Add Photo',
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
                  onPressed: onDeletePhoto,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
