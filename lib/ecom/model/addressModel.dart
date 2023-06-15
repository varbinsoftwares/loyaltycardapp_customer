class ContactAddress {
  String name;
  String address1;
  String zipcode;
  String contact_no;
  String email;

  ContactAddress(
      {required this.name,
      required this.address1,
      required this.zipcode,
      required this.contact_no,
      required this.email});

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'address1': address1,
      'zipcode': zipcode,
      'contact_no': contact_no,
      'email': email,
    };
  }

  factory ContactAddress.fromJson(Map<String, dynamic> json) {
    return ContactAddress(
      name: json["name"],
      address1: json["address1"],
      zipcode: json["zipcode"],
      contact_no: json["contact_no"],
      email: json["email"],
    );
  }
}
