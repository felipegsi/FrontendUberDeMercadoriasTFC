class Client {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final int taxPayerNumber;
  final String street;
  final String city;
  final int postalCode;

  Client({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.taxPayerNumber,
    required this.street,
    required this.city,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'taxPayerNumber': taxPayerNumber,
      'street': street,
      'city': city,
      'postalCode': postalCode,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      taxPayerNumber: json['taxPayerNumber'],
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
    );
  }
}
