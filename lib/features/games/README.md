# Mindful Games Module

This module contains relaxing, meditative games designed to help submariners pass time in a calming, stress-relieving way during deployment.

## Games Included

### 1. Zen Garden 🏯

A meditative sand drawing experience inspired by Japanese zen gardens.

**Features:**
- Touch-based drawing with smooth particle effects
- Adjustable brush sizes (Small, Medium, Large)
- Beautiful wave animation to clear the canvas
- Ocean-themed colour palette
- Fully offline
- No score, no pressure - just pure relaxation

**How to Play:**
1. Draw patterns in the sand with your finger
2. Adjust brush size using the brush button or settings
3. Clear your drawing with the wave animation button
4. Create mindful patterns, mandalas, or freeform art

**Therapeutic Benefits:**
- Promotes mindfulness and present-moment awareness
- Reduces stress and anxiety
- Provides creative outlet without pressure
- Calming visual feedback
- No right or wrong way to play

**Technical Details:**
- Uses `CustomPainter` for smooth rendering
- Particle-based drawing system (8 particles per touch)
- Animated wave clearing with easing curves
- Integrated with app theme system
- OPSEC-safe (no data collection or storage)

## File Structure

```
lib/features/games/
├── zen_garden/
│   ├── screens/
│   │   └── zen_garden_screen.dart    # Main game screen
│   ├── widgets/
│   │   └── sand_painter.dart         # Custom painter for sand particles
│   └── models/
│       └── sand_particle.dart        # Particle data model
└── README.md
```

## Design Philosophy

All games in this module follow these principles:

1. **No Stress** - No scores, timers, or failure states
2. **Offline First** - Work completely offline (critical for deployment)
3. **OPSEC Safe** - No data collection, no tracking, no storage
4. **Therapeutic** - Designed for stress relief and mindfulness
5. **Theme Integration** - Uses app's ocean theme colours
6. **Accessibility** - Large touch targets, clear feedback

## Future Games (Planned)

- **Block Stacking** - Physics-based zen building
- **Flow Puzzles** - Water connection puzzles (submarine themed)
- **Memory Sonar** - Pattern matching with submarine sonar theme
- **Breathing Game** - Gamified version of existing breathing exercises

## Adding New Games

When adding a new game:

1. Create a new directory under `lib/features/games/[game_name]/`
2. Follow the existing structure (screens, widgets, models)
3. Ensure it's fully offline
4. Integrate with theme system (use `context.colours`)
5. Add haptic feedback and sound effects
6. Add to home screen under "Mindful Games" section
7. Update this README

## Integration

Games are integrated into the home screen under a "Mindful Games" section:

```dart
_FeatureRow(
  icon: Icons.landscape_rounded,
  title: 'Zen Garden',
  subtitle: 'Draw patterns in the sand',
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ZenGardenScreen()),
  ),
),
```

## Testing

Test games on:
- Various screen sizes (phones, tablets)
- Different performance levels
- Offline mode
- Dark theme
- With haptics enabled/disabled
- With sounds enabled/disabled



