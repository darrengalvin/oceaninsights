import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/theme_options.dart';

/// Sound category for organisation
enum SoundCategory {
  nature,
  meditation,
  motivational,
  humor,
}

extension SoundCategoryExtension on SoundCategory {
  String get label {
    switch (this) {
      case SoundCategory.nature:
        return 'Nature';
      case SoundCategory.meditation:
        return 'Meditation';
      case SoundCategory.motivational:
        return 'Motivational';
      case SoundCategory.humor:
        return 'Humor';
    }
  }
  
  IconData get icon {
    switch (this) {
      case SoundCategory.nature:
        return Icons.park_outlined;
      case SoundCategory.meditation:
        return Icons.self_improvement_outlined;
      case SoundCategory.motivational:
        return Icons.emoji_events_outlined;
      case SoundCategory.humor:
        return Icons.sentiment_very_satisfied_outlined;
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
  
  late final AudioPlayer _audioPlayer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    
    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    
    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });
    
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Loop has finished, reset position for smooth replay
        _audioPlayer.seek(Duration.zero);
      }
    });
    
    // Enable looping by default
    _audioPlayer.setLoopMode(LoopMode.one);
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  final List<SoundTrack> _tracks = const [
    // Nature
    SoundTrack(
      id: 'ocean_waves_1',
      name: 'Ocean Waves',
      description: 'Waves crashing on the shoreline',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/ocean-waves-crashing-the-shoreline-423649.mp3',
      duration: Duration(minutes: 3),
    ),
    SoundTrack(
      id: 'ocean_waves_2',
      name: 'Gentle Ocean',
      description: 'Soft rolling ocean waves',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/ocean-waves-250310.mp3',
      duration: Duration(minutes: 4),
    ),
    SoundTrack(
      id: 'rain_forest',
      name: 'Rainforest',
      description: 'Rain sounds with forest ambience',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/rain-sound-and-rainforest-6293.mp3',
      duration: Duration(minutes: 1, seconds: 45),
    ),
    SoundTrack(
      id: 'hawaii_rain',
      name: 'Hawaiian Rain',
      description: 'Birds and soft rain in paradise',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/hawaii-birds-and-soft-rain-field-recording-18097.mp3',
      duration: Duration(minutes: 3),
    ),
    SoundTrack(
      id: 'summer_night',
      name: 'Summer Night',
      description: 'Crickets and gentle night sounds',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/summer-night-237724.mp3',
      duration: Duration(minutes: 4),
    ),
    SoundTrack(
      id: 'mountain_stream',
      name: 'Mountain Stream',
      description: 'Flowing water over rocks',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/mountain-stream-31273.mp3',
      duration: Duration(minutes: 1),
    ),
    SoundTrack(
      id: 'flowing_water',
      name: 'Flowing Water',
      description: 'Gentle water stream',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/flowing-water-246403.mp3',
      duration: Duration(minutes: 4),
    ),
    SoundTrack(
      id: 'forest_campfire',
      name: 'Forest Campfire',
      description: 'Crackling campfire in the forest',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/ambient-forest-campfire-meditation-452486.mp3',
      duration: Duration(minutes: 7),
    ),
    SoundTrack(
      id: 'underwater',
      name: 'Underwater',
      description: 'Beneath the surface sounds',
      category: SoundCategory.nature,
      assetPath: 'assets/audio/soundssection/underwater-sounds-376891.mp3',
      duration: Duration(minutes: 6),
    ),
    
    // Meditation
    SoundTrack(
      id: 'theta_waves',
      name: 'Theta Waves',
      description: '6Hz binaural beats with ocean',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/soundssection/6-hz-theta-binaural-beats-with-ocean-waves-for-meditation-and-insight-465179.mp3',
      duration: Duration(minutes: 7),
    ),
    SoundTrack(
      id: 'deep_space',
      name: 'Deep Space',
      description: 'Ethereal space ambience',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/soundssection/deep-space-26725.mp3',
      duration: Duration(seconds: 27),
    ),
    SoundTrack(
      id: 'ancient_chant',
      name: 'Ancient Chant',
      description: 'Mystic female voice chant',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/soundssection/beauty-woman-voice-ancient-chant-mystic-205225.mp3',
      duration: Duration(minutes: 3),
    ),
    SoundTrack(
      id: 'meditation_1',
      name: 'Meditation Guide',
      description: 'Guided meditation session',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/soundssection/april-8-2025-meditation-1-324586.mp3',
      duration: Duration(minutes: 5),
    ),
    SoundTrack(
      id: 'cat_meditation',
      name: 'Nature Cat',
      description: 'Sounds of nature meditation',
      category: SoundCategory.meditation,
      assetPath: 'assets/audio/soundssection/sounds-of-nature-cat-meditation-273943.mp3',
      duration: Duration(minutes: 5),
    ),
    
    // Motivational
    SoundTrack(
      id: 'push_yourself',
      name: 'Push Yourself',
      description: 'Motivational voice',
      category: SoundCategory.motivational,
      assetPath: 'assets/audio/soundssection/push-yourself-spoken-201868.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'excuses',
      name: 'No Excuses',
      description: 'Excuses don\'t burn calories',
      category: SoundCategory.motivational,
      assetPath: 'assets/audio/soundssection/excuses-donx27t-burn-calories-201869.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'strive',
      name: 'Strive for Progress',
      description: 'Progress over perfection',
      category: SoundCategory.motivational,
      assetPath: 'assets/audio/soundssection/strive-for-progress-201867.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'youve_got_this',
      name: 'You\'ve Got This',
      description: 'Encouraging words',
      category: SoundCategory.motivational,
      assetPath: 'assets/audio/soundssection/youx27ve-got-this-male-spoken-264674.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'cannot_be_done',
      name: 'Prove Them Wrong',
      description: 'Those who say it cannot be done',
      category: SoundCategory.motivational,
      assetPath: 'assets/audio/soundssection/those-who-say-it-cannot-be-done-spoken-204934.mp3',
      duration: Duration(seconds: 3),
    ),
    
    // Humor
    SoundTrack(
      id: 'joke_drums',
      name: 'Ba Dum Tss',
      description: 'Classic joke drums',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/joke-drums-242242.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'woman_laugh',
      name: 'Laughter',
      description: 'Contagious laugh',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/woman-laugh-6421.mp3',
      duration: Duration(seconds: 1),
    ),
    SoundTrack(
      id: 'hold_my_beer',
      name: 'Hold My Beer',
      description: 'Watch this...',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/hold-my-beerwatch-this-424261.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'duh_duh_duh',
      name: 'Suspense',
      description: 'Dramatic suspense sound',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/duh-duh-duh-458701.mp3',
      duration: Duration(seconds: 5),
    ),
    SoundTrack(
      id: 'i_love_you',
      name: 'I Love You',
      description: 'Cartoon voice',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/i-love-you-cartoon-voice-136531.mp3',
      duration: Duration(seconds: 1),
    ),
    SoundTrack(
      id: 'take_day_off',
      name: 'Take a Day Off',
      description: 'Maybe take a break?',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/take-a-day-off-184783.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'indecisive',
      name: 'Indecisive',
      description: 'Can\'t decide sound',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/indecisive-184782.mp3',
      duration: Duration(seconds: 2),
    ),
    SoundTrack(
      id: 'taratata',
      name: 'Fanfare',
      description: 'Victory fanfare',
      category: SoundCategory.humor,
      assetPath: 'assets/audio/soundssection/taratata-6264.mp3',
      duration: Duration(seconds: 1),
    ),
  ];
  
  List<SoundTrack> get _filteredTracks => 
      _tracks.where((t) => t.category == _selectedCategory).toList();
  
  Future<void> _togglePlay(String trackId) async {
    try {
      if (_playingTrackId == trackId) {
        // Stop current track
        await _audioPlayer.stop();
        setState(() {
          _playingTrackId = null;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      } else {
        // Play new track
        final track = _tracks.firstWhere((t) => t.id == trackId);
        setState(() => _isLoading = true);
        
        await _audioPlayer.setAsset(track.assetPath);
        await _audioPlayer.play();
        
        setState(() {
          _playingTrackId = trackId;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      setState(() {
        _isLoading = false;
        _playingTrackId = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio: $e')),
        );
      }
    }
  }
  
  Future<void> _pauseResume() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    final colours = context.colours;
    
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
                        ? colours.accent.withOpacity(0.1)
                        : colours.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? colours.accent 
                          : colours.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected ? colours.accent : colours.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? colours.accent : colours.textLight,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final colours = context.colours;
    final track = _tracks.firstWhere((t) => t.id == _playingTrackId);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colours.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: colours.border),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colours.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    track.category.icon,
                    color: colours.accent,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          color: colours.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _pauseResume,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colours.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _audioPlayer.playing 
                              ? Icons.pause_rounded 
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _togglePlay(track.id),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colours.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colours.border),
                        ),
                        child: Icon(
                          Icons.stop_rounded,
                          color: colours.textMuted,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _duration.inMilliseconds > 0 
                    ? _position.inMilliseconds / _duration.inMilliseconds 
                    : 0.0,
                backgroundColor: colours.border,
                valueColor: AlwaysStoppedAnimation<Color>(colours.accent),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colours.textMuted,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colours.textMuted,
                  ),
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
    final colours = context.colours;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaying 
              ? colours.accent.withOpacity(0.1) 
              : colours.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying 
                ? colours.accent 
                : colours.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPlaying 
                    ? colours.accent.withOpacity(0.1) 
                    : colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                track.category.icon,
                color: isPlaying ? colours.accent : colours.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPlaying ? colours.accent : colours.textBright,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colours.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPlaying 
                    ? colours.accent 
                    : colours.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPlaying 
                    ? Icons.pause_rounded 
                    : Icons.play_arrow_rounded,
                color: isPlaying ? Colors.white : colours.textMuted,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
