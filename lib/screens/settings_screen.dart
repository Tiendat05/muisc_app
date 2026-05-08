import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/audio_provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Audio settings section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audio Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Volume control
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Master Volume',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<AudioProvider>(
                          builder: (context, audioProvider, _) {
                            return Column(
                              children: [
                                Slider(
                                  value: audioProvider.volume,
                                  onChanged: (value) {
                                    audioProvider.setVolume(value);
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                  activeColor: AppColors.primary,
                                  inactiveColor: AppColors.grey,
                                ),
                                Text(
                                  '${(audioProvider.volume * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Theme settings section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.dark_mode,
                                color: AppColors.primary,
                              ),
                              title: const Text(
                                'Dark Theme',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Switch(
                                value: !themeProvider.isDarkMode,
                                onChanged: (value) {
                                  // Toggle theme
                                },
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.info,
                            color: AppColors.primary,
                          ),
                          title: const Text(
                            'App Version',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: const Text(
                            '1.0.0',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                        Divider(color: AppColors.grey.withOpacity(0.3)),
                        ListTile(
                          leading: const Icon(
                            Icons.description,
                            color: AppColors.primary,
                          ),
                          title: const Text(
                            'About App',
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'A simple offline music player for Flutter',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: const Text(
                                  AppStrings.appName,
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  'A simple offline music player for Flutter that allows you to play songs from your device storage.',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
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
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
