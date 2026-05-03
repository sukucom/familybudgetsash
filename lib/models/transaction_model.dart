class TransactionModel {
  final int? id;
  final int accountId;
  final int memberId;
  final int categoryId;
  final double amount;
  final DateTime date;
  final String? note;
  final String type; // 'Credit' or 'Debit'

  TransactionModel({
    this.id,
    required this.accountId,
    required this.memberId,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'member_id': memberId,
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'type': type,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      accountId: map['account_id'],
      memberId: map['member_id'],
      categoryId: map['category_id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      type: map['type'],
    );
  }
}
