class UserEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  final String phone;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
    required this.phone,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
}