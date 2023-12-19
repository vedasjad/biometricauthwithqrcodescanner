class Employee {
  final String empID;
  final String id;
  final String key;
  final String username;
  final String role;

  Employee({
    required this.empID,
    required this.id,
    required this.key,
    required this.username,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empID: json['empID'],
      id: json['id'],
      key: json['key'],
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empID': empID,
      'id': id,
      'key': key,
      'username': username,
      'role': role,
    };
  }
}
