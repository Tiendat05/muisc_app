import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/audio_provider.dart';
import 'provider/playlist_provider.dart';
import 'provider/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/now_playing_screen.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';
import 'widgets/mini_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AudioPlayerService>(create: (_) => AudioPlayerService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider(
          create: (context) => AudioProvider(
            context.read<AudioPlayerService>(),
            context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PlaylistProvider(context.read<StorageService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.background,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const HomeScreen(),
          // Mini player at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MiniPlayer(
              onTap: () {
                // Navigate to now playing screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
