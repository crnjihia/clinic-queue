// path: apps/mobile/lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../app.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enablePushNotifications = true;
  bool _enableSmsFallback = true;
  String _selectedLanguage = 'en'; // 'en' or 'sw'
  String _currentRole = AppRouter.currentUserRole;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '0712 345 678');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String role) {
    setState(() {
      _currentRole = role;
      AppRouter.currentUserRole = role;
    });
    AppRouter.authStateListenable.value = !AppRouter.authStateListenable.value;
    AppRouter.authStateListenable.value = !AppRouter.authStateListenable.value;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched view to $role portal.'),
        backgroundColor: AppColors.primaryTeal,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSwahili = _selectedLanguage == 'sw';
    final isDarkMode = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSwahili ? 'Mipangilio' : 'App Settings'),
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // 1. Compact User Account Header
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(
                              _currentRole == 'staff' ? Icons.medical_services : Icons.person,
                              color: AppColors.primaryTeal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentRole == 'staff' ? 'Nurse Wangari (Staff)' : 'Patient Account',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  _phoneController.text,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              _currentRole.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            backgroundColor: AppColors.secondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Preferences & Appearance Card
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        // Dark Mode Toggle
                        SwitchListTile(
                          dense: true,
                          secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryTeal, size: 20),
                          title: Text(
                            isSwahili ? 'Njia ya Gizani (Dark Mode)' : 'Dark Theme Mode',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isSwahili ? 'Washa mandhari ya giza' : 'Switch dark/light theme',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: isDarkMode,
                          onChanged: (val) {
                            setState(() {
                              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        // Language Segmented Toggle
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.language, color: AppColors.primaryTeal, size: 20),
                          title: Text(
                            isSwahili ? 'Lugha ya Programu' : 'Language',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _selectedLanguage == 'sw' ? 'Kiswahili' : 'English',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'en', label: Text('EN', style: TextStyle(fontSize: 11))),
                              ButtonSegment(value: 'sw', label: Text('SW', style: TextStyle(fontSize: 11))),
                            ],
                            selected: {_selectedLanguage},
                            onSelectionChanged: (val) => setState(() => _selectedLanguage = val.first),
                          ),
                        ),
                        const Divider(height: 1),
                        // Role Switcher
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.swap_horiz, color: AppColors.primaryTeal, size: 20),
                          title: Text(
                            isSwahili ? 'Badilisha Role' : 'Portal Role',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _currentRole == 'staff' ? 'Staff Console' : 'Patient Portal',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: DropdownButton<String>(
                            isDense: true,
                            value: _currentRole,
                            items: const [
                              DropdownMenuItem(value: 'patient', child: Text('Patient', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'staff', child: Text('Staff', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) _onRoleChanged(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Notifications & M-Pesa Settings Card
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          dense: true,
                          secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryTeal, size: 20),
                          title: Text(
                            isSwahili ? 'Arifa za Push (FCM)' : 'FCM Push Alerts',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isSwahili ? 'Arifa ya "Wewe ndiye unayefuata!"' : 'Real-time queue position alerts',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: _enablePushNotifications,
                          onChanged: (val) => setState(() => _enablePushNotifications = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          dense: true,
                          secondary: const Icon(Icons.sms_outlined, color: AppColors.primaryTeal, size: 20),
                          title: Text(
                            isSwahili ? 'Arifa za SMS' : 'SMS Fallback Alerts',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isSwahili ? 'Tuma SMS kupitia Africa\'s Talking' : 'Africa\'s Talking SMS alerts',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: _enableSmsFallback,
                          onChanged: (val) => setState(() => _enableSmsFallback = val),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_android, color: Colors.green, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isSwahili ? 'Simu ya M-Pesa:' : 'M-Pesa Number:',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                height: 36,
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 4. Footer Branding
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    Text(
                      'Clinic Queue v1.0.0+1 • Kenya 🇰🇪',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
