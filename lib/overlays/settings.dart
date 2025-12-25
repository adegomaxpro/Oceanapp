import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/aqua_path_game.dart';

class Settings extends StatefulWidget {
  final AquaPathGame game;

  const Settings({super.key, required this.game});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final soundEnabled = await widget.game.localStorage.getVolume();
    setState(() {
      _soundEnabled = soundEnabled;
    });
  }

  Future<void> _toggleSound(bool value) async {
    setState(() {
      _soundEnabled = value;
    });
    await widget.game.localStorage.saveVolume(value);

    // Apply the setting
    if (value) {
      FlameAudio.bgm.resume();
    } else {
      FlameAudio.bgm.pause();
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.tealAccent),
            SizedBox(width: 10),
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your privacy is important to us!\n\n'
          'Ocean does not collect, store, or share any personal data. '
          'All game progress is saved locally on your device.\n\n'
          'We do not use analytics, tracking, or any third-party services '
          'that would access your information.\n\n'
          'Play with peace of mind!',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 14,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOceanGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Ocean Guide',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideSection(
                'How to Play',
                'Swipe or drag up and down to move your fish through the ocean. '
                'Navigate carefully to avoid obstacles!',
                Icons.sports_esports,
              ),
              const SizedBox(height: 16),
              _buildGuideSection(
                'Eating & Growing',
                'Collect food bubbles to grow your fish. As you eat more, '
                'your fish will evolve into larger, stronger species!',
                Icons.restaurant,
              ),
              const SizedBox(height: 16),
              _buildGuideSection(
                'Avoid Hazards',
                'Watch out for obstacles like bottles and debris. '
                'Larger fish can survive smaller hazards, but be careful!',
                Icons.warning_amber,
              ),
              const SizedBox(height: 16),
              _buildGuideSection(
                'Collect Shells',
                'Earn shells during gameplay to spend in the store '
                'on power-ups and special items.',
                Icons.stars,
              ),
              const SizedBox(height: 16),
              _buildGuideSection(
                'Fish Collection',
                'Save fish to build your sanctuary! The more you play, '
                'the more fish you can rescue.',
                Icons.waves,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Ready to Swim!',
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.tealAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey.shade800,
                Colors.blueGrey.shade900,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.game.playButtonSound();
                      widget.game.closeSettings();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Sound Toggle
              _buildSettingRow(
                icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                label: 'Sound',
                child: Switch(
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeThumbColor: Colors.tealAccent,
                  activeTrackColor: Colors.teal,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: Colors.white24,
              ),

              const SizedBox(height: 16),

              // Ocean Guide
              _buildClickableRow(
                icon: Icons.menu_book,
                iconColor: Colors.amber,
                label: 'Ocean Guide',
                onTap: _showOceanGuide,
              ),

              const SizedBox(height: 16),

              // Privacy Policy
              _buildClickableRow(
                icon: Icons.privacy_tip,
                iconColor: Colors.tealAccent,
                label: 'Privacy Policy',
                onTap: _showPrivacyPolicy,
              ),

              const SizedBox(height: 16),

              // Divider
              Container(
                height: 1,
                color: Colors.white24,
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSettingRow(
                icon: Icons.info_outline,
                label: 'Version',
                child: const Text(
                  '1.0.0',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Back Button
              GestureDetector(
                onTap: () {
                  widget.game.playButtonSound();
                  widget.game.closeSettings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.teal.shade800],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.tealAccent, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildClickableRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        widget.game.playButtonSound();
        onTap();
      },
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white54, size: 24),
        ],
      ),
    );
  }
}

