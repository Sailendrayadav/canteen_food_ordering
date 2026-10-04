class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String studentId;
  final String canteenName;
  final String role;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.studentId,
    required this.canteenName,
    this.role = 'Student Canteen Admin',
  });
}
