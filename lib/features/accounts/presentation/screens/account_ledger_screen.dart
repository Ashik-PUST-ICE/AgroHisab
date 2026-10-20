import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/account_model.dart';
import '../providers/account_provider.dart';

class AccountLedgerScreen extends StatelessWidget {
  final AccountModel account;

  const AccountLedgerScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${account.name} - খতিয়ান', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AccountProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.ledger.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.ledger.isEmpty) {
            return const Center(child: Text('এই একাউন্টে এখনো কোনো লেনদেনের রেকর্ড নেই।', style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ledger.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final tx = provider.ledger[i];
              final isCredit = tx.credit > 0; // জমা

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isCredit ? AppColors.accentLight : Colors.red.shade50,
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? AppColors.primary : Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(tx.date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isCredit ? "+" : "-"}৳ ${isCredit ? tx.credit.toStringAsFixed(2) : tx.debit.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isCredit ? AppColors.primary : Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'উদ্বৃত্ত: ৳${tx.balance.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}