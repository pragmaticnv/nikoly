import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoplay = true;
  bool _normalization = true;
  bool _private = false;
  double _crossfade = 3.0;
  String _quality = 'High (320kbps)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F16),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: Color(0xFF0F0F16),
            floating: true,
            title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfile(),
                  const SizedBox(height: 24),
                  _buildSection('Appearance', [
                    _buildThemeGrid(),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Audio', [
                    _buildDropdownRow('Streaming Quality', _quality, ['Auto', 'Low', 'Normal', 'High (320kbps)', 'Lossless'], (v) => setState(() => _quality = v!)),
                    _buildDivider(),
                    _buildToggleRow('Volume Normalization', 'Keep all tracks at similar volume', _normalization, (v) => setState(() => _normalization = v)),
                    _buildDivider(),
                    _buildSliderRow('Crossfade', '${_crossfade.toInt()}s transition', _crossfade, (v) => setState(() => _crossfade = v)),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Playback', [
                    _buildToggleRow('Autoplay', 'Continue playing similar tracks', _autoplay, (v) => setState(() => _autoplay = v)),
                    _buildDivider(),
                    _buildToggleRow('Notifications', 'Show now-playing notifications', _notifications, (v) => setState(() => _notifications = v)),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Privacy', [
                    _buildToggleRow('Private Session', 'Listen without affecting history', _private, (v) => setState(() => _private = v)),
                  ]),
                  const SizedBox(height: 32),
                  _buildSignOutButton(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF1DB954),
            child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nikhil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('nikhil@example.com', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Free Plan', style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Upgrade', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeGrid() {
    final themes = [
      {'id': 'dark', 'label': 'Dark', 'color': const Color(0xFF0F0F16)},
      {'id': 'purple', 'label': 'Purple', 'color': const Color(0xFF2D1B69)},
      {'id': 'ocean', 'label': 'Ocean', 'color': const Color(0xFF0A2647)},
      {'id': 'forest', 'label': 'Forest', 'color': const Color(0xFF064439)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Theme', style: TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: themes.map((t) => Column(
            children: [
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: t['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 6),
              Text(t['label'] as String, style: const TextStyle(fontSize: 10)),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1DB954),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String title, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1A1A2E),
          underline: const SizedBox(),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderRow(String title, String sub, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF1DB954))),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 12,
          divisions: 12,
          activeColor: const Color(0xFF1DB954),
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDivider() => const Divider(color: Colors.white10, height: 24);

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
        label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}