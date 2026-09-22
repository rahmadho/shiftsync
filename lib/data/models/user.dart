/// Employee / app user.
class User {
  const User({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.department,
    required this.email,
    required this.shiftLabel,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String employeeCode; // #EMP-2024-89
  final String department; // Marketing
  final String email;
  final String shiftLabel; // Mon-Fri Shift
  final String? avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        employeeCode: json['employee_code'] as String,
        department: json['department'] as String,
        email: json['email'] as String,
        shiftLabel: json['shift_label'] as String,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'employee_code': employeeCode,
        'department': department,
        'email': email,
        'shift_label': shiftLabel,
        'avatar_url': avatarUrl,
      };

  User copyWith({String? name, String? department, String? avatarUrl}) => User(
        id: id,
        name: name ?? this.name,
        employeeCode: employeeCode,
        department: department ?? this.department,
        email: email,
        shiftLabel: shiftLabel,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
