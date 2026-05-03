class AccountModel {
  final int? id;
  final int familyId;
  final String name;
  final String type; // 'Bank', 'Wallet', 'Credit Card'
  final double balance;

  AccountModel({
    this.id,
    required this.familyId,
    required this.name,
    required this.type,
    this.balance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'family_id': familyId,
      'name': name,
      'type': type,
      'balance': balance,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      familyId: map['family_id'],
      name: map['name'],
      type: map['type'],
      balance: map['balance'],
    );
  }
}
