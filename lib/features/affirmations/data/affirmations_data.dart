/// Affirmation data structure
class Affirmation {
  final String text;
  final String category;
  final String? reflection;
  
  const Affirmation({
    required this.text,
    required this.category,
    this.reflection,
  });
}

/// Pre-loaded affirmations for offline use
class AffirmationsData {
  AffirmationsData._();
  
  static const List<Affirmation> affirmations = [
    // Strength & Resilience
    Affirmation(
      text: 'I have overcome challenges before, and I will overcome this too.',
      category: 'Strength',
      reflection: 'Think of a time you faced something difficult and got through it. You have that same strength now.',
    ),
    Affirmation(
      text: 'My challenges do not define me. My response to them does.',
      category: 'Resilience',
    ),
    Affirmation(
      text: 'I am stronger than I give myself credit for.',
      category: 'Strength',
    ),
    Affirmation(
      text: 'Difficult times are temporary. My ability to cope is permanent.',
      category: 'Resilience',
      reflection: 'This moment will pass. Focus on what you can control right now.',
    ),
    Affirmation(
      text: 'I am capable of handling whatever comes my way.',
      category: 'Strength',
    ),
    
    // Self-Worth
    Affirmation(
      text: 'I am worthy of respect, including from myself.',
      category: 'Self-Worth',
    ),
    Affirmation(
      text: 'My worth is not determined by my productivity.',
      category: 'Self-Worth',
      reflection: 'You matter simply because you exist, not because of what you achieve.',
    ),
    Affirmation(
      text: 'I deserve to take up space and have my voice heard.',
      category: 'Self-Worth',
    ),
    Affirmation(
      text: 'I am enough, exactly as I am right now.',
      category: 'Self-Worth',
    ),
    Affirmation(
      text: 'My feelings are valid and deserve acknowledgement.',
      category: 'Self-Worth',
      reflection: 'Whatever you are feeling right now is okay. Feelings are information, not instructions.',
    ),
    
    // Calm & Peace
    Affirmation(
      text: 'I release what I cannot control and focus on what I can.',
      category: 'Calm',
      reflection: 'What is one small thing you can control in this moment?',
    ),
    Affirmation(
      text: 'Peace begins with a single breath. I choose peace now.',
      category: 'Calm',
    ),
    Affirmation(
      text: 'I give myself permission to slow down.',
      category: 'Calm',
    ),
    Affirmation(
      text: 'This moment is all I need to focus on.',
      category: 'Peace',
    ),
    Affirmation(
      text: 'I am safe in this present moment.',
      category: 'Peace',
      reflection: 'Right here, right now, you are okay. Focus on what is real and present.',
    ),
    
    // Growth & Change
    Affirmation(
      text: 'Every day I am growing, even when I cannot see it.',
      category: 'Growth',
    ),
    Affirmation(
      text: 'Mistakes are proof that I am trying.',
      category: 'Growth',
      reflection: 'The only true failure is not trying at all. Every mistake is a lesson.',
    ),
    Affirmation(
      text: 'I am not the same person I was yesterday, and that is okay.',
      category: 'Change',
    ),
    Affirmation(
      text: 'Progress, not perfection, is my goal.',
      category: 'Growth',
    ),
    Affirmation(
      text: 'Change is uncomfortable but necessary for growth.',
      category: 'Change',
    ),
    
    // Connection & Support
    Affirmation(
      text: 'Asking for help is a sign of strength, not weakness.',
      category: 'Support',
      reflection: 'Even the strongest people need support. It takes courage to reach out.',
    ),
    Affirmation(
      text: 'I am not alone in what I am going through.',
      category: 'Connection',
    ),
    Affirmation(
      text: 'Many people have walked this path before me and found their way.',
      category: 'Connection',
    ),
    Affirmation(
      text: 'I matter to the people in my life.',
      category: 'Connection',
    ),
    Affirmation(
      text: 'It is okay to lean on others when I need support.',
      category: 'Support',
    ),
    
    // Courage & Action
    Affirmation(
      text: 'Courage is not the absence of fear but acting despite it.',
      category: 'Courage',
      reflection: 'What would you do today if fear was not holding you back?',
    ),
    Affirmation(
      text: 'I have the power to create positive change in my life.',
      category: 'Action',
    ),
    Affirmation(
      text: 'One step at a time is still moving forward.',
      category: 'Action',
    ),
    Affirmation(
      text: 'I choose to focus on solutions, not problems.',
      category: 'Action',
    ),
    Affirmation(
      text: 'Today I will do what I can with what I have.',
      category: 'Courage',
    ),
    
    // Self-Care & Boundaries
    Affirmation(
      text: 'Taking care of myself is not selfish; it is necessary.',
      category: 'Self-Care',
    ),
    Affirmation(
      text: 'I have the right to set boundaries that protect my wellbeing.',
      category: 'Boundaries',
      reflection: 'Boundaries are not walls. They are gates that let the right things in.',
    ),
    Affirmation(
      text: 'Rest is not a reward for hard work; it is essential.',
      category: 'Self-Care',
    ),
    Affirmation(
      text: 'I honour my needs without guilt.',
      category: 'Self-Care',
    ),
    Affirmation(
      text: 'Saying no to things that drain me creates space for things that fill me.',
      category: 'Boundaries',
    ),
    
    // Hope & Future
    Affirmation(
      text: 'Better days are ahead. This is just one chapter.',
      category: 'Hope',
    ),
    Affirmation(
      text: 'I am building a future I can be proud of.',
      category: 'Future',
    ),
    Affirmation(
      text: 'There is light even in the darkest tunnel.',
      category: 'Hope',
      reflection: 'Even if you cannot see it yet, the light is there. Keep moving towards it.',
    ),
    Affirmation(
      text: 'My story is not over. The best chapters may be yet to come.',
      category: 'Hope',
    ),
    Affirmation(
      text: 'I trust that things will work out, even if not as expected.',
      category: 'Future',
    ),
  ];
}



