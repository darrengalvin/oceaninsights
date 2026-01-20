import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';

/// Sound category for organisation
enum SoundCategory {
  nature,
  ambient,
  meditation,
}

extension SoundCategoryExtension on SoundCategory {
  String get label {
    switch (this) {
      case SoundCategory.nature:
        return 'Nature';
      case SoundCategory.ambient:
        return 'Ambient';
      case SoundCategory.meditation:
        return 'Meditation';
    }
  }
  
  IconData get icon {
    switch (this) {
      case SoundCategory.nature:
        return Icons.park_rounded;
      case SoundCategory.ambient:
        return Icons.auto_awesome_rounded;
      case SoundCategory.meditation:
        return Icons.self_improvement_rounded;
    }
  }
}

/// Sound track data
class SoundTrack {
  final String id;
  final String name;
  final String description;
  final SoundCategory category;
  final String assetPath;
  final Duration duration;
  
  const SoundTrack({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.assetPath,
    required this.duration,
  });
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  SoundCategory _selectedCategory = SoundCategory.nature;
  String? _playingTrackId;
  
  final List<SoundTrack> _tracks = const [
    // Nature
    SoundTrack(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      description: 'Gentle waves lapping on a peaceful shore',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/ocean_waves.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'rain_forest',
      name: 'Rainforest',
      description: 'Soft rain with distant thunder',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/rain_forest.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'night_crickets',
      name: 'Summer Night',
      description: 'Crickets and gentle night sounds',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/night_crickets.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'stream',
      name: 'Mountain Stream',
      description: 'Flowing water over rocks',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/stream.mp3',
      duration: Duration(minutes: 30),
    ),
    
    // Ambient
    SoundTrack(
      id: 'deep_space',
      name: 'Deep Space',
      description: 'Ethereal space ambience',
      category: SoundCategory.ambient,
      assetPath: 'assets/audio/deep_space.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'submarine',
      name: 'Below the Surface',
      description: 'Underwater ambient sounds',
      category: SoundCategory.ambient,
      assetPath: 'assets/audio/submarine.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'soft_hum',
      name: 'Soft Drone',
      description: 'Gentle, calming drone tone',
      category: SoundCategory.ambient,
      assetPath: 'assets/audio/soft_hum.mp3',
      duration: Duration(minutes: 30),
    ),
    
    // Meditation
    SoundTrack(
      id: 'singing_bowl',
      name: 'Singing Bowls',
      description: 'Tibetan singing bowl meditation',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/singing_bowl.mp3',
      duration: Duration(minutes: 20),
    ),
    SoundTrack(
      id: 'binaural',
      name: 'Focus Tones',
      description: 'Binaural beats for concentration',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/binaural.mp3',
      duration: Duration(minutes: 30),
    ),
    SoundTrack(
      id: 'wind_chimes',
      name: 'Wind Chimes',
      description: 'Gentle wind chimes in a breeze',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/wind_chimes.mp3',
      duration: Duration(minutes: 30),
    ),
  ];
  
  List<SoundTrack> get _filteredTracks => 
      _tracks.where((t) => t.category == _selectedCategory).toList();
  
  void _togglePlay(String trackId) {
    setState(() {
      if (_playingTrackId == trackId) {
        _playingTrackId = null;
      } else {
        _playingTrackId = trackId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calm Sounds'),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(
            child: _buildTrackList(),
          ),
          if (_playingTrackId != null)
            _buildNowPlaying(),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: SoundCategory.values.map((category) {
          final isSelected = category == _selectedCategory;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: category != SoundCategory.meditation ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.seaGreen 
                        : AppTheme.midnightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.seaGreen 
                          : AppTheme.cardBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected ? AppTheme.abyssBlack : AppTheme.textLight,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppTheme.abyssBlack : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTrackList() {
    return ListView.separated(
      padding: AppSpacing.pageHorizontal,
      itemCount: _filteredTracks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final track = _filteredTracks[index];
        final isPlaying = _playingTrackId == track.id;
        
        return _TrackCard(
          track: track,
          isPlaying: isPlaying,
          onTap: () => _togglePlay(track.id),
        );
      },
    );
  }
  
  Widget _buildNowPlaying() {
    final track = _tracks.firstWhere((t) => t.id == _playingTrackId);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.midnightBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppTheme.seaGreen.withOpacity(0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.seaGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.seaGreen.withOpacity(0.3)),
                  ),
                  child: Icon(
                    track.category.icon,
                    color: AppTheme.seaGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          color: AppTheme.seaGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _togglePlay(track.id),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.seaGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.stop_rounded,
                      color: AppTheme.abyssBlack,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.3,
                backgroundColor: AppTheme.steelBlue,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.seaGreen),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:00',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${track.duration.inMinutes}:00',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final SoundTrack track;
  final bool isPlaying;
  final VoidCallback onTap;
  
  const _TrackCard({
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isPlaying 
              ? AppTheme.seaGreen.withOpacity(0.1) 
              : AppTheme.midnightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying 
                ? AppTheme.seaGreen 
                : AppTheme.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPlaying 
                    ? AppTheme.seaGreen.withOpacity(0.2) 
                    : AppTheme.slateDepth,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                track.category.icon,
                color: isPlaying ? AppTheme.seaGreen : AppTheme.textLight,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isPlaying ? AppTheme.seaGreen : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPlaying 
                    ? AppTheme.seaGreen 
                    : AppTheme.slateDepth,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPlaying 
                    ? Icons.pause_rounded 
                    : Icons.play_arrow_rounded,
                color: isPlaying ? AppTheme.abyssBlack : AppTheme.textMuted,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
