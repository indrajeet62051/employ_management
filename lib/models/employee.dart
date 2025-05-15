class Employee {
  int? id;
  String name;
  String contactNumber;
  String hobby;
  String designation;
  String email;
  String? imagePath;

  Employee({
    this.id,
    required this.name,
    required this.contactNumber,
    required this.hobby,
    required this.designation,
    required this.email,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactNumber': contactNumber,
      'hobby': hobby,
      'designation': designation,
      'email': email,
      'imagePath': imagePath,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      contactNumber: map['contactNumber'] ?? '',
      hobby: map['hobby'] ?? '',
      designation: map['designation'] ?? '',
      email: map['email'],
      imagePath: map['imagePath'],
    );
  }
}
