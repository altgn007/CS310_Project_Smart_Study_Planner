class DummyUser {
  final String fullName;
  final String email;
  final String password;
  final String dateOfBirth;
  final String educationLevel;

  const DummyUser({
    required this.fullName,
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.educationLevel,
  });
}

class DummyUsersRepository {
  static final List<DummyUser> users = [
    const DummyUser(
      fullName: 'Salih Kobaş',
      email: 'salih@university.edu',
      password: '123456',
      dateOfBirth: '19/04/2003',
      educationLevel: 'University',
    ),
  ];

  static bool emailExists(String email) {
    return users.any(
      (user) => user.email.toLowerCase().trim() == email.toLowerCase().trim(),
    );
  }

  static void addUser(DummyUser user) {
    users.add(user);
  }
}