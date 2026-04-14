/// Represents a pet owner (veterinary customer) in the system.
///
/// Contains personal details and optional insurance information.
class PetOwner {
  /// Unique database ID. Null before the first insert.
  int? id;

  /// Owner's first name.
  String firstName;

  /// Owner's last name.
  String lastName;

  /// Owner's home address.
  String address;

  /// Owner's date of birth formatted as YYYY-MM-DD.
  String dateOfBirth;

  /// Optional pet insurance policy number.
  String insuranceNumber;

  /// Creates a [PetOwner] with all required fields.
  PetOwner({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth,
    this.insuranceNumber = '',
  });

  /// Returns the owner's full name.
  String get fullName => '$firstName $lastName';

  /// Converts this object to a map suitable for database storage.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'insuranceNumber': insuranceNumber,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  /// Creates a [PetOwner] from a database row map.
  factory PetOwner.fromMap(Map<String, dynamic> map) {
    return PetOwner(
      id: map['id'] as int?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      address: map['address'] as String,
      dateOfBirth: map['dateOfBirth'] as String,
      insuranceNumber: map['insuranceNumber'] as String? ?? '',
    );
  }

  /// Returns a copy of this owner with the given fields replaced.
  PetOwner copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? address,
    String? dateOfBirth,
    String? insuranceNumber,
  }) {
    return PetOwner(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
    );
  }
}