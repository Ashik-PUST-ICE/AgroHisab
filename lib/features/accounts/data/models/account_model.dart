class AccountModel {
  final int id;
  final String name;
  final String type; // cash, bank, mobile_banking
  final String typeLabel;
  final String? accountNumber;
  final String? bankName;
  final double currentBalance;
  final bool isDefault;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.typeLabel,
    this.accountNumber,
    this.bankName,
    required this.currentBalance,
    required this.isDefault,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'cash',
      typeLabel: json['type_label'] ?? json['type'] ?? 'নগদ ক্যাশ',
      accountNumber: json['account_number'],
      bankName: json['bank_name'],
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 
                      (json['balance'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}

class LedgerTransactionModel {
  final int id;
  final String date;
  final String description;
  final String? referenceType;
  final String? referenceId;
  final double debit; // টাকা খরচ / প্রদান
  final double credit; // টাকা জমা / গ্রহণ
  final double balance;

  LedgerTransactionModel({
    required this.id,
    required this.date,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory LedgerTransactionModel.fromJson(Map<String, dynamic> json) {
    return LedgerTransactionModel(
      id: json['id'] ?? 0,
      date: json['transaction_date'] ?? json['created_at'] ?? '',
      description: json['description'] ?? json['notes'] ?? 'লেনদেন',
      referenceType: json['reference_type'],
      referenceId: json['reference_id']?.toString(),
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}