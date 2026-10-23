import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/storage_provider.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  String _provider = 'local';
  bool _loaded = false;
  final _accessKey = TextEditingController();
  final _secretKey = TextEditingController();
  final _region = TextEditingController(text: 'us-east-1');
  final _bucket = TextEditingController();
  final _endpoint = TextEditingController();
  final _projectId = TextEditingController();
  final _serviceJson = TextEditingController();
  final _accountName = TextEditingController();
  final _accountKey = TextEditingController();
  final _container = TextEditingController();
  final _publicUrl = TextEditingController();

  static const _names = {
    'local': 'Local storage',
    's3': 'Amazon S3 / S3 compatible',
    'gcs': 'Google Cloud Storage',
    'azure': 'Azure Blob Storage',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<StorageProvider>().fetchStorageInfo());
  }

  @override
  void dispose() {
    for (final c in [_accessKey, _secretKey, _region, _bucket, _endpoint, _projectId, _serviceJson, _accountName, _accountKey, _container, _publicUrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Storage settings', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Consumer<StorageProvider>(
        builder: (context, storage, _) {
          if (!_loaded && storage.info != null) {
            _provider = storage.info!.provider;
            _loaded = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Storage provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _providerPicker(storage),
              const SizedBox(height: 16),
              _formForProvider(),
              if (storage.message != null) ...[
                const SizedBox(height: 12),
                Text(storage.message!, style: TextStyle(color: storage.lastActionSuccessful ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 18),
              CustomButton(text: 'Save storage settings', icon: Icons.save_rounded, isLoading: storage.isLoading, onPressed: storage.isLoading ? null : () => _save(storage)),
              const SizedBox(height: 10),
              CustomButton(text: 'Test connection', icon: Icons.wifi_tethering_rounded, isOutline: true, isLoading: storage.isLoading, onPressed: storage.isLoading ? null : storage.testConnection),
              if (storage.testResult != null) ...[const SizedBox(height: 14), Text(storage.testResult!.message, style: const TextStyle(fontWeight: FontWeight.w600))],
            ],
          );
        },
      ),
    );
  }

  Widget _providerPicker(StorageProvider storage) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: storage.isLoading ? null : () => _showProviderSheet(storage),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 5, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(9)), child: Icon(_icon(_provider), color: AppColors.primary, size: 19)),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Provider', style: TextStyle(color: Colors.black45, fontSize: 11)), Text(_names[_provider]!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))])),
          const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 23),
        ]),
      ),
    );
  }

  Future<void> _showProviderSheet(StorageProvider storage) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Choose storage provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          ..._names.entries.map((entry) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: entry.key == _provider ? AppColors.accentLight : Colors.black.withOpacity(.04), borderRadius: BorderRadius.circular(9)), child: Icon(_icon(entry.key), color: entry.key == _provider ? AppColors.primary : AppColors.textSecondary, size: 19)),
            title: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: entry.key == _provider ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
            onTap: () => Navigator.pop(context, entry.key),
          )),
        ])),
      ),
    );
    if (value != null && mounted) {
      setState(() => _provider = value);
      storage.clearMessage();
    }
  }

  IconData _icon(String provider) => switch (provider) {
    'local' => Icons.folder_rounded,
    's3' => Icons.cloud_rounded,
    'gcs' => Icons.cloud_queue_rounded,
    _ => Icons.storage_rounded,
  };

  Widget _formForProvider() {
    if (_provider == 'local') return _infoCard('Local storage', 'Files will be saved on the server public storage folder. No credentials are required.', Icons.folder_rounded);
    if (_provider == 's3') return _cloudCard('Amazon S3 credentials', [
      _field(_accessKey, 'Access key', Icons.key_rounded), _field(_secretKey, 'Secret key', Icons.lock_rounded, secret: true), _field(_region, 'Region', Icons.public_rounded), _field(_bucket, 'Bucket name', Icons.folder_rounded), _field(_endpoint, 'Endpoint (optional)', Icons.link_rounded), _field(_publicUrl, 'Public URL (optional)', Icons.language_rounded),
    ]);
    if (_provider == 'gcs') return _cloudCard('Google Cloud credentials', [_field(_projectId, 'Project ID', Icons.badge_rounded), _field(_bucket, 'Bucket name', Icons.folder_rounded), _field(_serviceJson, 'Service account JSON', Icons.description_rounded, lines: 4), _field(_publicUrl, 'Public URL (optional)', Icons.language_rounded)]);
    return _cloudCard('Azure Blob credentials', [_field(_accountName, 'Account name', Icons.account_circle_rounded), _field(_accountKey, 'Account key', Icons.key_rounded, secret: true), _field(_container, 'Container name', Icons.folder_rounded), _field(_endpoint, 'Endpoint (optional)', Icons.link_rounded), _field(_publicUrl, 'Public URL (optional)', Icons.language_rounded)]);
  }

  Widget _infoCard(String title, String text, IconData icon) => Card(color: AppColors.accentLight, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, color: AppColors.primary, size: 28), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 5), Text(text, style: const TextStyle(color: Colors.black54))]))])));

  Widget _cloudCard(String title, List<Widget> fields) => Card(margin: EdgeInsets.zero, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 10), ...fields])));

  Widget _field(TextEditingController controller, String label, IconData icon, {bool secret = false, int lines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: controller, obscureText: secret, maxLines: secret ? 1 : lines, style: const TextStyle(fontSize: 14), decoration: InputDecoration(isDense: true, labelText: label, prefixIcon: Icon(icon, size: 18), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AppColors.primary, width: 1.3)))));

  Future<void> _save(StorageProvider storage) async {
    Map<String, dynamic>? credentials;
    if (_provider == 's3') credentials = {'access_key': _accessKey.text.trim(), 'secret_key': _secretKey.text, 'region': _region.text.trim(), 'bucket': _bucket.text.trim(), if (_endpoint.text.trim().isNotEmpty) 'endpoint': _endpoint.text.trim()};
    if (_provider == 'gcs') credentials = {'project_id': _projectId.text.trim(), 'bucket': _bucket.text.trim(), 'service_account_json': _serviceJson.text};
    if (_provider == 'azure') credentials = {'account_name': _accountName.text.trim(), 'account_key': _accountKey.text, 'container': _container.text.trim(), if (_endpoint.text.trim().isNotEmpty) 'endpoint': _endpoint.text.trim()};
    await storage.updateSettings(provider: _provider, credentials: credentials, publicUrl: _publicUrl.text.trim());
  }
}
