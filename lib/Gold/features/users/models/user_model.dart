class UserAccess {
  final String module;
  final bool read;
  final bool write;

  UserAccess({
    required this.module,
    this.read = false,
    this.write = false,
  });

  factory UserAccess.fromJson(Map<String, dynamic> json) => UserAccess(
        module: json['module'] ?? '',
        read: json['read'] ?? false,
        write: json['write'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'module': module,
        'read': read,
        'write': write,
      };
}

class User {
  final int? id;
  final String name;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final String? gender;
  final String? accountStatus;
  final String? createdDate;
  final int? createdBy;
  final List<String> modules;
  final List<UserAccess> userAccess;

  User({
    this.id,
    required this.name,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.gender,
    this.accountStatus,
    this.createdDate,
    this.createdBy,
    this.modules = const [],
    this.userAccess = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'] ?? '',
        lastName: json['lastName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        role: json['role'],
        gender: json['gender'],
        accountStatus: json['accountStatus'],
        createdDate: json['createdDate'] ?? json['createdAt'],
        createdBy: json['createdBy'],
        modules: (json['modules'] as List?)?.map((e) => e.toString()).toList() ?? [],
        userAccess: (json['userAccess'] as List?)
                ?.map((e) => UserAccess.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (role != null) 'role': role,
        if (gender != null) 'gender': gender,
        if (createdBy != null) 'createdBy': createdBy,
        'modules': modules,
        'userAccess': userAccess.map((e) => e.toJson()).toList(),
      };
}
