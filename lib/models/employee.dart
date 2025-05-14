class Employee {
  int? id;
  String name;
  String empId;
  String department;
  String designation;
  String email;
  String? imagePath; // store image path as string

  Employee({
    this.id,
    required this.name,
    required this.empId,
    required this.department,
    required this.designation,
    required this.email,
    this.imagePath,
  });

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'empId': empId,
      'department': department,
      'designation': designation,
      'email': email,
      'imagePath': imagePath,
    };
  }

  // Convert from map
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      empId: map['empId'],
      department: map['department'],
      designation: map['designation'],
      email: map['email'],
      imagePath: map['imagePath'],
    );
  }
}
