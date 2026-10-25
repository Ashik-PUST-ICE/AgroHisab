import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('হিসাব বিবরণী ও রিপোর্ট',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'লাভ-ক্ষতি'),
            Tab(text: 'ক্যাশ বহি'),
            Tab(text: 'আড়ত বকেয়া (Receivables)'),
            Tab(text: 'চাষী দেনা (Payables)'),
            Tab(text: 'পণ্যভিত্তিক বিক্রয়'),
            Tab(text: 'গুদাম স্টক'),
          ],
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading &&
              provider.profitability == null &&
              provider.cashbook == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfitabilityTab(provider),
              _buildCashbookTab(provider),
              _buildReceivablesAgingTab(provider),
              _buildPayablesAgingTab(provider),
              _buildSalesByProductTab(provider),
              _buildInventoryValuationTab(provider),
            ],
          );
        },
      ),
    );
  }

  // Tab 1: Profitability
  Widget _buildProfitabilityTab(ReportsProvider provider) {
    final p = provider.profitability;
    if (p == null) {
      return const Center(
          child: Text('রিপোর্ট পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final isProfit = p.netProfit >= 0;

    return RefreshIndicator(
      onRefresh: () => provider.fetchReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProfit
                    ? [AppColors.primary, AppColors.secondary]
                    : [Colors.red.shade700, Colors.red.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('মোট অর্জিত লাভ / ক্ষতি (Net Profit)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '৳ ${p.netProfit.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit
                      ? 'আলহামদুলিল্লাহ, সামগ্রিক ব্যবসায় মুনাফা রয়েছে'
                      : 'সতর্কতা: সামগ্রিক হিসাবে ক্ষতি রয়েছে',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow('মোট বিক্রয় আয় (Revenue):',
                      '৳ ${p.totalRevenue.toStringAsFixed(0)}', Colors.blue.shade800),
                  const Divider(),
                  _buildMetricRow('মাল কেনার খরচ (COGS):',
                      '৳ ${p.totalCogs.toStringAsFixed(0)}', Colors.black87),
                  const Divider(),
                  _buildMetricRow('মোট মোট লাভ (Gross Profit):',
                      '৳ ${p.grossProfit.toStringAsFixed(0)}', AppColors.primary),
                  const Divider(),
                  _buildMetricRow('মোট পরিচালন ব্যয় (Expenses):',
                      '৳ ${p.totalExpenses.toStringAsFixed(0)}', Colors.red.shade700),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Cashbook Statement (API 13)
  Widget _buildCashbookTab(ReportsProvider provider) {
    final cb = provider.cashbook;

    if (provider.isCashbookLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (cb == null) {
      return const Center(
          child: Text('ক্যাশ বহি বিবরণী পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final sum = cb.summary;

    return RefreshIndicator(
      onRefresh: () => provider.fetchCashbook(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('বর্তমান সমাপনী স্থিতি (Closing Balance)',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '৳ ${sum.closingBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('প্রারম্ভিক জের: ৳ ${sum.openingBalance.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'নিট প্রবাহ: ৳ ${sum.netCashflow.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded,
                              size: 16, color: Colors.green.shade800),
                          const SizedBox(width: 4),
                          Text('মোট জমা (In)',
                              style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳ ${sum.totalInflows.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded,
                              size: 16, color: Colors.red.shade800),
                          const SizedBox(width: 4),
                          Text('মোট খরচ (Out)',
                              style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳ ${sum.totalOutflows.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('লেনদেন খাতা (Ledger)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('মোট: ${cb.transactions.length} টি',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          if (cb.transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('এই সময়ের মধ্যে কোনো লেনদেন রেকর্ড নেই।',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...cb.transactions.map((tx) {
              final isCredit = tx.isCredit;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isCredit ? 'জমা (+)' : 'খরচ (-)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCredit
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(tx.date,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          Text(
                            isCredit
                                ? '+ ৳ ${tx.creditAmount.toStringAsFixed(2)}'
                                : '- ৳ ${tx.debitAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isCredit
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tx.partyName ?? tx.typeLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'হিসাব: ${tx.accountName ?? "ক্যাশ"}${tx.reference != null ? " • #${tx.reference}" : ""}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          Text(
                            'জের: ৳ ${tx.runningBalance.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Tab 3: Receivables Aging (API 14)
  Widget _buildReceivablesAgingTab(ReportsProvider provider) {
    final ra = provider.receivablesAging;

    if (provider.isReceivablesLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (ra == null) {
      return const Center(
          child: Text('আড়ত পাওনা বয়স বিশ্লেষণ পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final s = ra.summary;

    return RefreshIndicator(
      onRefresh: () => provider.fetchReceivablesAging(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.indigo.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('আড়তদারদের কাছে মোট বকেয়া পাওনা',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '৳ ${s.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('রিপোর্টের তারিখ: ${ra.reportDate}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAgingBucketBox(
                    '০ - ৩০ দিন', s.bucket030, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgingBucketBox(
                    '৩১ - ৬০ দিন', s.bucket3160, Colors.amber.shade800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAgingBucketBox(
                    '৬১ - ৯০ দিন', s.bucket6190, Colors.orange.shade800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgingBucketBox(
                    '৯০+ দিন (ঝুঁকিপূর্ণ)', s.bucket90Plus, Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('আড়ত অনুযায়ী পাওনা বিবরণ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('মোট: ${ra.rows.length} জন',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          if (ra.rows.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('কোনো বকেয়া পাওনা নেই। সমস্ত চালান পরিশোধিত!',
                    style: TextStyle(color: Colors.green)),
              ),
            )
          else
            ...ra.rows.map((row) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.aratdarName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                if (row.city != null && row.city!.isNotEmpty)
                                  Text(row.city!,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('মোট পাওনা',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                              Text(
                                '৳ ${row.totalDue.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (row.bucket030 > 0)
                            _buildMiniChip(
                                '0-30 দিন', row.bucket030, Colors.green),
                          if (row.bucket3160 > 0)
                            _buildMiniChip('31-60 দিন', row.bucket3160,
                                Colors.amber.shade800),
                          if (row.bucket6190 > 0)
                            _buildMiniChip('61-90 দিন', row.bucket6190,
                                Colors.orange.shade800),
                          if (row.bucket90Plus > 0)
                            _buildMiniChip(
                                '90+ দিন', row.bucket90Plus, Colors.red.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Tab 4: Payables Aging (API 15)
  Widget _buildPayablesAgingTab(ReportsProvider provider) {
    final pa = provider.payablesAging;

    if (provider.isPayablesLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (pa == null) {
      return const Center(
          child: Text('চাষী দেনা বয়স বিশ্লেষণ পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final s = pa.summary;

    return RefreshIndicator(
      onRefresh: () => provider.fetchPayablesAging(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade800, Colors.brown.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('চাষী ও মহাজনদের কাছে মোট বকেয়া দেনা',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '৳ ${s.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('রিপোর্টের তারিখ: ${pa.reportDate}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAgingBucketBox(
                    '০ - ৩০ দিন', s.bucket030, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgingBucketBox(
                    '৩১ - ৬০ দিন', s.bucket3160, Colors.amber.shade800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAgingBucketBox(
                    '৬১ - ৯০ দিন', s.bucket6190, Colors.orange.shade800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgingBucketBox(
                    '৯০+ দিন (দীর্ঘমেয়াদী)', s.bucket90Plus, Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('চাষী ও সরবরাহকারী দেনা বিবরণ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('মোট: ${pa.rows.length} জন',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          if (pa.rows.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('কোনো বকেয়া দেনা নেই। সমস্ত ক্রয়মূল্য পরিশোধিত!',
                    style: TextStyle(color: Colors.green)),
              ),
            )
          else
            ...pa.rows.map((row) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(row.supplierName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('মোট দেনা',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                              Text(
                                '৳ ${row.totalDue.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (row.bucket030 > 0)
                            _buildMiniChip(
                                '0-30 দিন', row.bucket030, Colors.green),
                          if (row.bucket3160 > 0)
                            _buildMiniChip('31-60 দিন', row.bucket3160,
                                Colors.amber.shade800),
                          if (row.bucket6190 > 0)
                            _buildMiniChip('61-90 দিন', row.bucket6190,
                                Colors.orange.shade800),
                          if (row.bucket90Plus > 0)
                            _buildMiniChip(
                                '90+ দিন', row.bucket90Plus, Colors.red.shade700),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Tab 5: Sales By Product (API 16)
  Widget _buildSalesByProductTab(ReportsProvider provider) {
    final sp = provider.salesByProduct;

    if (provider.isSalesByProductLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (sp == null) {
      return const Center(
          child: Text('পণ্যভিত্তিক বিক্রয় বিবরণী পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final sum = sp.summary;

    return RefreshIndicator(
      onRefresh: () => provider.fetchSalesByProduct(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('সর্বমোট বিক্রয়মূল্য (Gross Sales)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '৳ ${sum.totalGross.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('আড়ত কমিশন: ৳ ${sum.totalCommission.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('নিট প্রাপ্তি: ৳ ${sum.totalNet.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ফসল অনুযায়ী বিক্রয় বিশ্লেষণ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('মোট চালান বিক্রয়: ${sum.totalSales} টি',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          if (sp.rows.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('এখনো কোনো ফসল বিক্রয় সম্পন্ন হয়নি।',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...sp.rows.map((row) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.accentLight,
                                child: Icon(Icons.grass,
                                    size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Text(row.productName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'বিক্রয়: ${row.saleCount} টি',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('মোট পরিমাণ',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '${row.totalQuantity.toStringAsFixed(1)} কেজি',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('মোট বিক্রয়মূল্য',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '৳ ${row.totalGross.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('নিট প্রাপ্তি',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(
                                  '৳ ${row.totalNet.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAgingBucketBox(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '৳ ${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        '$label: ৳${amount.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  // Tab 6: Inventory Valuation
  Widget _buildInventoryValuationTab(ReportsProvider provider) {
    if (provider.inventoryValuation.isEmpty) {
      return const Center(
          child: Text('কোনো গুদাম ভ্যালুয়েশন পাওয়া যায়নি।',
              style: TextStyle(color: Colors.grey)));
    }

    final totalVal = provider.inventoryValuation
        .fold<double>(0.0, (sum, i) => sum + i.totalValue);

    return RefreshIndicator(
      onRefresh: () => provider.fetchReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট গুদাম পণ্যের আনুমানিক বাজার মূল্য',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      '৳ ${totalVal.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...provider.inventoryValuation.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.accentLight,
                    child: Icon(Icons.grass, color: AppColors.primary),
                  ),
                  title: Text(item.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'মজুদ: ${item.currentStockKg.toStringAsFixed(1)} কেজি • গড় দর: ৳${item.averageRate.toStringAsFixed(1)}/কেজি'),
                  trailing: Text(
                    '৳ ${item.totalValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(val,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}