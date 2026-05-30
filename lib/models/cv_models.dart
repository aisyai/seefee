// lib/models/cv_models.dart

class Experience {
  String id;
  String company;
  String role;
  String location;
  String companyDescription;
  String startMonth;
  String startYear;
  String endMonth;
  String endYear;
  bool isCurrent;
  String achievements;

  Experience({
    required this.id,
    this.company = '',
    this.role = '',
    this.location = '',
    this.companyDescription = '',
    this.startMonth = 'January',
    this.startYear = '2023',
    this.endMonth = 'January',
    this.endYear = '2024',
    this.isCurrent = false,
    this.achievements = '',
  });

  // Getter 'duration' akan otomatis menggabungkan bulan & tahun
  // Ini bikin fungsi PDF tetep aman dan gak error.
  String get duration {
    if (startMonth.isEmpty || startYear.isEmpty) return '';
    final start = '$startMonth $startYear';
    final end = isCurrent ? 'Present' : '$endMonth $endYear';
    return '$start - $end';
  }

  // Sama dengan description, PDF butuh properti ini.
  String get description => achievements;

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'role': role,
    'location': location,
    'companyDescription': companyDescription,
    'startMonth': startMonth,
    'startYear': startYear,
    'endMonth': endMonth,
    'endYear': endYear,
    'isCurrent': isCurrent,
    'achievements': achievements,
  };

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    id: json['id'],
    company: json['company'] ?? '',
    role: json['role'] ?? '',
    location: json['location'] ?? '',
    companyDescription: json['companyDescription'] ?? '',
    startMonth: json['startMonth'] ?? 'January',
    startYear: json['startYear'] ?? '2023',
    endMonth: json['endMonth'] ?? 'January',
    endYear: json['endYear'] ?? '2024',
    isCurrent: json['isCurrent'] ?? false,
    achievements: json['achievements'] ?? '',
  );
}

class Education {
  String id;
  String school;
  String degree;
  String startYear;
  String endYear;
  bool isCurrent;
  String description;

  Education({
    required this.id,
    this.school = '',
    this.degree = '',
    this.startYear = '2021',
    this.endYear = '2025',
    this.isCurrent = false,
    this.description = '',
  });

  // Getter otomatis buat ke PDF
  String get duration {
    if (startYear.isEmpty) return '';
    final end = isCurrent ? 'Present' : endYear;
    return '$startYear - $end';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'school': school,
    'degree': degree,
    'startYear': startYear,
    'endYear': endYear,
    'isCurrent': isCurrent,
    'description': description,
  };

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    id: json['id'],
    school: json['school'] ?? '',
    degree: json['degree'] ?? '',
    startYear: json['startYear'] ?? '2021',
    endYear: json['endYear'] ?? '2025',
    isCurrent: json['isCurrent'] ?? false,
    description: json['description'] ?? '',
  );
}

class Organisation {
  String id;
  String name;
  String role;
  String startMonth;
  String startYear;
  String endMonth;
  String endYear;
  bool isCurrent;
  String description;

  Organisation({
    required this.id,
    this.name = '',
    this.role = '',
    this.startMonth = 'January',
    this.startYear = '2023',
    this.endMonth = 'January',
    this.endYear = '2024',
    this.isCurrent = false,
    this.description = '',
  });

  String get duration {
    if (startMonth.isEmpty || startYear.isEmpty) return '';
    final start = '$startMonth $startYear';
    final end = isCurrent ? 'Present' : '$endMonth $endYear';
    return '$start - $end';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'startMonth': startMonth,
    'startYear': startYear,
    'endMonth': endMonth,
    'endYear': endYear,
    'isCurrent': isCurrent,
    'description': description,
  };

  factory Organisation.fromJson(Map<String, dynamic> json) => Organisation(
    id: json['id'],
    name: json['name'] ?? '',
    role: json['role'] ?? '',
    startMonth: json['startMonth'] ?? 'January',
    startYear: json['startYear'] ?? '2023',
    endMonth: json['endMonth'] ?? 'January',
    endYear: json['endYear'] ?? '2024',
    isCurrent: json['isCurrent'] ?? false,
    description: json['description'] ?? '',
  );
}
