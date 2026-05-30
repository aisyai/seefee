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

  // Sama dengan description, PDF kamu butuh properti ini.
  String get description => achievements;
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
}
