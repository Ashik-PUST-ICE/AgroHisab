import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/aratdar_provider.dart';
import 'aratdar_agreement_screen.dart';

class AratdarListScreen extends StatefulWidget {
  const AratdarListScreen({super.key});

  @override
  State<AratdarListScreen> createState() => _AratdarListScreenState();
}

class _AratdarListScreenState extends State<AratdarListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AratdarProvider>(context, listen: false).fetchAratdars();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AratdarProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('আড়তদার (Aratdar)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAratdars(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'আড়তদার খুঁজুন',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              if (provider.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator()))
              else if (provider.aratdars.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined,
                            size: 50, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('কোনো আড়তদার পাওয়া যায়নি',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 15)),
                      ],
                    ),
                  ),
                )
              else
                ...provider.aratdars
                    .where((a) =>
                        _searchCtrl.text.isEmpty ||
                        a.name
                            .toLowerCase()
                            .contains(_searchCtrl.text.toLowerCase()) ||
                        (a.businessName ?? '')
                            .toLowerCase()
                            .contains(_searchCtrl.text.toLowerCase()))
                    .map((a) {
                  final commissionStr = a.commissionType == 2
                      ? '৳${a.commissionValue.toStringAsFixed(0)} / বস্তা'
                      : '${a.commissionValue.toStringAsFixed(1)}%';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AratdarAgreementScreen(aratdar: a),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.accentLight,
                              child: Icon(Icons.storefront_rounded,
                                  color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(a.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: AppColors.accentLight,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Text(
                                          'কমিশন: $commissionStr',
                                          style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${a.businessName} • ${a.district}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.handshake_outlined,
                                          size: 14, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'কমিশন চুক্তি দেখুন ও পরিবর্তন করুন',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Spacer(),
                                      Icon(Icons.chevron_right,
                                          size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}