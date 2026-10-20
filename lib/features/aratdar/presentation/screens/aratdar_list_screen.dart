import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/aratdar_provider.dart';

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
        title: const Text('আড়তদার (Aratdar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              ),
              const SizedBox(height: 16),

              if (provider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (provider.aratdars.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(Icons.storefront_outlined, size: 50, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('কোনো আড়তদার পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.aratdars.length,
                  itemBuilder: (ctx, idx) {
                    final a = provider.aratdars[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.accentLight,
                            child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(6)),
                                      child: const Text('সক্রিয়', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text('${a.businessName} • ${a.district}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_rounded, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(a.phone?.isNotEmpty == true ? a.phone! : '01711-222333', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }
}