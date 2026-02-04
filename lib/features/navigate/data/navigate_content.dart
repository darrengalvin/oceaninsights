/// Life areas for navigation
enum LifeArea {
  relationships,
  selfUnderstanding,
  mentalHealth,
  physicalHealth,
  career,
  finance,
  purpose,
  militaryLife,
  family,
}

extension LifeAreaExtension on LifeArea {
  String get title {
    switch (this) {
      case LifeArea.relationships:
        return 'Relationships';
      case LifeArea.selfUnderstanding:
        return 'Understanding Yourself';
      case LifeArea.mentalHealth:
        return 'Emotional Wellbeing';
      case LifeArea.physicalHealth:
        return 'Physical Health';
      case LifeArea.career:
        return 'Work & Career';
      case LifeArea.finance:
        return 'Finance';
      case LifeArea.purpose:
        return 'Purpose & Meaning';
      case LifeArea.militaryLife:
        return 'Military Life';
      case LifeArea.family:
        return 'Family';
    }
  }

  String get description {
    switch (this) {
      case LifeArea.relationships:
        return 'Partners, friendships, and connections';
      case LifeArea.selfUnderstanding:
        return 'Know yourself better';
      case LifeArea.mentalHealth:
        return 'Your mind and emotions';
      case LifeArea.physicalHealth:
        return 'Body and wellness';
      case LifeArea.career:
        return 'Work, growth, and direction';
      case LifeArea.finance:
        return 'Money and security';
      case LifeArea.purpose:
        return 'Finding meaning and direction';
      case LifeArea.militaryLife:
        return 'Service, transition, and beyond';
      case LifeArea.family:
        return 'Parents, children, and home';
    }
  }

  String get icon {
    switch (this) {
      case LifeArea.relationships:
        return 'favorite_outline';
      case LifeArea.selfUnderstanding:
        return 'psychology_outlined';
      case LifeArea.mentalHealth:
        return 'spa_outlined';
      case LifeArea.physicalHealth:
        return 'fitness_center_outlined';
      case LifeArea.career:
        return 'work_outline';
      case LifeArea.finance:
        return 'account_balance_outlined';
      case LifeArea.purpose:
        return 'explore_outlined';
      case LifeArea.militaryLife:
        return 'shield_outlined';
      case LifeArea.family:
        return 'home_outlined';
    }
  }
}

/// Content section types - Understand, Reflect, Grow
enum ContentType {
  understand,
  reflect,
  grow,
}

extension ContentTypeExtension on ContentType {
  String get title {
    switch (this) {
      case ContentType.understand:
        return 'Understand';
      case ContentType.reflect:
        return 'Reflect';
      case ContentType.grow:
        return 'Grow';
    }
  }

  String get subtitle {
    switch (this) {
      case ContentType.understand:
        return 'Learn how things work';
      case ContentType.reflect:
        return 'Questions to consider';
      case ContentType.grow:
        return 'Practical steps forward';
    }
  }
}

/// A single piece of guidance content
class GuidanceCard {
  final String id;
  final String title;
  final String content;
  final String? reflection; // Optional question to ponder
  final List<String>? actionSteps; // Optional practical steps
  final String? affirmation; // Positive closing message

  const GuidanceCard({
    required this.id,
    required this.title,
    required this.content,
    this.reflection,
    this.actionSteps,
    this.affirmation,
  });
}

/// A topic within a life area
class NavigateTopic {
  final String id;
  final String title;
  final String subtitle;
  final LifeArea area;
  final ContentType type;
  final List<GuidanceCard> cards;
  final List<String>? audienceFilter; // e.g., ['veteran', 'serving', 'man', 'woman']

  const NavigateTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.area,
    required this.type,
    required this.cards,
    this.audienceFilter,
  });
}

/// Main content database
class NavigateContent {
  NavigateContent._();

  // ============================================
  // RELATIONSHIPS - UNDERSTAND
  // ============================================

  static const List<NavigateTopic> relationshipsUnderstand = [
    NavigateTopic(
      id: 'healthy_relationships',
      title: 'What Makes Relationships Healthy',
      subtitle: 'The foundations of connection',
      area: LifeArea.relationships,
      type: ContentType.understand,
      cards: [
        GuidanceCard(
          id: 'healthy_1',
          title: 'Trust and Safety',
          content: 'Healthy relationships are built on a foundation of trust. This means feeling safe to be yourself, knowing your partner will be honest, and believing they have your best interests at heart. Trust takes time to build and requires consistent actions, not just words.',
          affirmation: 'You deserve relationships where you feel safe.',
        ),
        GuidanceCard(
          id: 'healthy_2',
          title: 'Communication',
          content: 'Good communication isn\'t about never disagreeing - it\'s about how you handle differences. Healthy couples can express needs, listen actively, and work through conflict without contempt or stonewalling. It\'s a skill that can be learned.',
          affirmation: 'Every conversation is a chance to connect.',
        ),
        GuidanceCard(
          id: 'healthy_3',
          title: 'Respect and Boundaries',
          content: 'Respect means valuing your partner\'s feelings, opinions, and boundaries - even when you disagree. It means not trying to control or change them. Healthy boundaries protect both people and actually bring you closer.',
          affirmation: 'Boundaries are an act of love, not rejection.',
        ),
        GuidanceCard(
          id: 'healthy_4',
          title: 'Independence Within Togetherness',
          content: 'The healthiest relationships balance closeness with individuality. You can be deeply connected while still having your own friends, interests, and identity. Needing space doesn\'t mean you love each other less.',
          affirmation: 'You can be fully yourself and fully loved.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'communication_styles',
      title: 'How People Communicate',
      subtitle: 'Understanding different approaches',
      area: LifeArea.relationships,
      type: ContentType.understand,
      cards: [
        GuidanceCard(
          id: 'comm_1',
          title: 'Passive Communication',
          content: 'Passive communicators often avoid expressing their needs or opinions to keep the peace. They may say "it\'s fine" when it isn\'t, then feel resentful. This style often comes from learning that your needs weren\'t important or would cause conflict.',
          affirmation: 'Your needs matter.',
        ),
        GuidanceCard(
          id: 'comm_2',
          title: 'Aggressive Communication',
          content: 'Aggressive communication prioritises your needs over others, often through criticism, blame, or intimidation. It usually comes from a place of fear or hurt, not strength. It damages trust and pushes people away.',
          affirmation: 'Strength doesn\'t require force.',
        ),
        GuidanceCard(
          id: 'comm_3',
          title: 'Passive-Aggressive Communication',
          content: 'This indirect style expresses negative feelings through actions rather than words - the silent treatment, sarcasm, or "forgetting" to do things. It often develops when direct expression didn\'t feel safe.',
          affirmation: 'It\'s okay to say what you need directly.',
        ),
        GuidanceCard(
          id: 'comm_4',
          title: 'Assertive Communication',
          content: 'Assertive communication expresses your needs clearly and respectfully while considering others. It sounds like "I feel..." rather than "You always...". This is the healthiest style and can be learned with practice.',
          affirmation: 'You can be honest and kind at the same time.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'love_languages',
      title: 'How People Show Love',
      subtitle: 'Different ways of expressing care',
      area: LifeArea.relationships,
      type: ContentType.understand,
      cards: [
        GuidanceCard(
          id: 'love_1',
          title: 'Words of Affirmation',
          content: 'Some people feel most loved when they hear it expressed in words - compliments, encouragement, "I love you", or acknowledgment of what they do. If this is your language, silence can feel like rejection even when it\'s not meant that way.',
          affirmation: 'Your need to hear love spoken is valid.',
        ),
        GuidanceCard(
          id: 'love_2',
          title: 'Acts of Service',
          content: 'For some, actions speak louder than words. Helping with tasks, taking care of things, or easing someone\'s burden shows love. If this is your language, a partner who doesn\'t help may feel uncaring, even if they express love in other ways.',
          affirmation: 'Noticing what someone does is love in itself.',
        ),
        GuidanceCard(
          id: 'love_3',
          title: 'Quality Time',
          content: 'Undivided attention, being fully present, doing things together - this is how some people feel most connected. Distractions or cancelled plans can feel deeply personal. It\'s not about quantity, but about presence.',
          affirmation: 'Your time together matters.',
        ),
        GuidanceCard(
          id: 'love_4',
          title: 'Physical Touch',
          content: 'Hugs, holding hands, physical closeness - for some, this is how love feels real. If this is your language, physical distance (even if unintentional) can make you feel unloved or disconnected.',
          affirmation: 'Needing physical connection is natural.',
        ),
        GuidanceCard(
          id: 'love_5',
          title: 'Receiving Gifts',
          content: 'Thoughtful gifts, big or small, represent love and consideration to some people. It\'s not about materialism - it\'s about someone thinking of you. A forgotten birthday might hurt more deeply than others understand.',
          affirmation: 'It\'s the thought behind the gift that matters.',
        ),
      ],
    ),
  ];

  // ============================================
  // RELATIONSHIPS - REFLECT
  // ============================================

  static const List<NavigateTopic> relationshipsReflect = [
    NavigateTopic(
      id: 'relationship_values',
      title: 'What Matters to You',
      subtitle: 'Discovering your relationship values',
      area: LifeArea.relationships,
      type: ContentType.reflect,
      cards: [
        GuidanceCard(
          id: 'values_1',
          title: 'Safety and Trust',
          content: 'Think about what makes you feel safe in a relationship. Is it consistency? Honesty? Knowing they\'ll be there?',
          reflection: 'When do you feel most secure with someone? What creates that feeling?',
        ),
        GuidanceCard(
          id: 'values_2',
          title: 'Communication',
          content: 'Consider how you like to communicate in relationships. Do you need to talk things through immediately, or do you prefer time to process?',
          reflection: 'How do you prefer to handle disagreements? Have past partners matched this?',
        ),
        GuidanceCard(
          id: 'values_3',
          title: 'Independence',
          content: 'Think about the balance between togetherness and personal space that works for you.',
          reflection: 'How much time alone do you need to feel like yourself? Is this respected in your relationships?',
        ),
        GuidanceCard(
          id: 'values_4',
          title: 'Future Vision',
          content: 'Consider what you want your life to look like - where you live, family, career, lifestyle.',
          reflection: 'Are your core life goals compatible with your partner\'s? Have you discussed them?',
        ),
      ],
    ),
    NavigateTopic(
      id: 'patterns_in_relationships',
      title: 'Patterns You Notice',
      subtitle: 'Understanding your relationship history',
      area: LifeArea.relationships,
      type: ContentType.reflect,
      cards: [
        GuidanceCard(
          id: 'patterns_1',
          title: 'Repeated Dynamics',
          content: 'Sometimes we find ourselves in similar relationships or situations repeatedly. This isn\'t bad luck - it\'s often a pattern worth understanding.',
          reflection: 'Is there a type of person you\'re drawn to? A dynamic that keeps appearing? What might this be about?',
        ),
        GuidanceCard(
          id: 'patterns_2',
          title: 'Your Role',
          content: 'We often take on certain roles in relationships - the caretaker, the fixer, the one who gives in. These roles may have developed for good reasons, but they can limit us.',
          reflection: 'What role do you tend to play in relationships? Is this the role you want?',
        ),
        GuidanceCard(
          id: 'patterns_3',
          title: 'When Things End',
          content: 'How relationships end can reveal patterns too. Do you tend to leave first, stay too long, or push people away?',
          reflection: 'Looking back at relationships that ended, do you notice any patterns in how or why they ended?',
        ),
      ],
    ),
  ];

  // ============================================
  // RELATIONSHIPS - GROW
  // ============================================

  static const List<NavigateTopic> relationshipsGrow = [
    NavigateTopic(
      id: 'better_communication',
      title: 'Communicating Better',
      subtitle: 'Practical skills for connection',
      area: LifeArea.relationships,
      type: ContentType.grow,
      cards: [
        GuidanceCard(
          id: 'comm_grow_1',
          title: 'Use "I" Statements',
          content: 'Instead of "You never listen to me," try "I feel unheard when I\'m interrupted." This expresses your experience without triggering defensiveness.',
          actionSteps: [
            'Notice when you\'re about to say "You always" or "You never"',
            'Pause and rephrase as "I feel... when..."',
            'Focus on the specific situation, not character attacks',
          ],
          affirmation: 'Speaking your truth can be gentle.',
        ),
        GuidanceCard(
          id: 'comm_grow_2',
          title: 'Listen to Understand',
          content: 'Active listening means trying to understand, not just waiting for your turn to speak. Put down distractions, make eye contact, and reflect back what you hear.',
          actionSteps: [
            'When your partner speaks, focus fully on them',
            'Don\'t plan your response while they\'re talking',
            'Say "What I\'m hearing is..." to check understanding',
            'Ask clarifying questions before responding',
          ],
          affirmation: 'Being truly heard is a gift you can give.',
        ),
        GuidanceCard(
          id: 'comm_grow_3',
          title: 'Take Breaks When Flooded',
          content: 'When emotions run high, your brain loses access to its reasoning centres. Taking a 20-minute break (with agreement to return) can prevent saying things you\'ll regret.',
          actionSteps: [
            'Learn to recognise when you\'re "flooded" (racing heart, can\'t think clearly)',
            'Agree on a signal with your partner (e.g., "I need 20 minutes")',
            'Use the break to calm down, not to rehearse arguments',
            'Always return to the conversation when ready',
          ],
          affirmation: 'Pausing is strength, not avoidance.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'setting_boundaries',
      title: 'Setting Healthy Boundaries',
      subtitle: 'Protecting yourself while staying connected',
      area: LifeArea.relationships,
      type: ContentType.grow,
      cards: [
        GuidanceCard(
          id: 'bound_1',
          title: 'Know Your Limits',
          content: 'Boundaries start with knowing what you can and can\'t accept. This requires tuning into your own feelings and taking them seriously.',
          actionSteps: [
            'Notice what makes you feel uncomfortable or resentful',
            'These feelings are signals about your boundaries',
            'Write down your non-negotiables in relationships',
          ],
          affirmation: 'Your comfort matters.',
        ),
        GuidanceCard(
          id: 'bound_2',
          title: 'Communicate Clearly',
          content: 'State boundaries clearly and calmly: "I\'m not comfortable with..." or "I need...". You don\'t need to justify or over-explain.',
          actionSteps: [
            'Keep it simple and direct',
            'Avoid apologising for having boundaries',
            'Stay calm - boundaries aren\'t punishments',
          ],
          affirmation: 'You can be firm and loving.',
        ),
        GuidanceCard(
          id: 'bound_3',
          title: 'Maintain Boundaries',
          content: 'Setting a boundary once isn\'t enough. You may need to remind, reinforce, or follow through with consequences if boundaries are repeatedly crossed.',
          actionSteps: [
            'Expect some pushback - it doesn\'t mean you\'re wrong',
            'Restate boundaries calmly when needed',
            'Have clear consequences and follow through',
          ],
          affirmation: 'Consistency builds respect.',
        ),
      ],
    ),
  ];

  // ============================================
  // SELF UNDERSTANDING - UNDERSTAND
  // ============================================

  static const List<NavigateTopic> selfUnderstand = [
    NavigateTopic(
      id: 'emotional_awareness',
      title: 'Understanding Your Emotions',
      subtitle: 'What feelings are trying to tell you',
      area: LifeArea.selfUnderstanding,
      type: ContentType.understand,
      cards: [
        GuidanceCard(
          id: 'emotion_1',
          title: 'Emotions Are Information',
          content: 'Every emotion you feel has a purpose. Anger signals a boundary has been crossed. Fear alerts you to potential danger. Sadness tells you something is lost. Rather than fighting your feelings, try understanding what they\'re telling you.',
          affirmation: 'Your feelings make sense.',
        ),
        GuidanceCard(
          id: 'emotion_2',
          title: 'Primary vs Secondary Emotions',
          content: 'Often what we show on the surface (anger, irritation) is covering a deeper feeling (hurt, fear, rejection). Many people, especially men, were taught to express anger but not vulnerability. Understanding your primary emotion helps you address the real issue.',
          affirmation: 'It\'s okay to feel what\'s underneath.',
        ),
        GuidanceCard(
          id: 'emotion_3',
          title: 'Emotional Patterns',
          content: 'We all have emotional patterns shaped by our past. Maybe you shut down when criticised, or get anxious when plans change. These patterns made sense once - they were your way of coping. Understanding them gives you choice.',
          affirmation: 'You can learn new patterns.',
        ),
      ],
    ),
  ];

  // ============================================
  // MEN'S CONTENT
  // ============================================

  static const List<NavigateTopic> mensContent = [
    NavigateTopic(
      id: 'men_emotions',
      title: 'Men and Emotions',
      subtitle: 'Understanding the pressure to "be strong"',
      area: LifeArea.selfUnderstanding,
      type: ContentType.understand,
      audienceFilter: ['man'],
      cards: [
        GuidanceCard(
          id: 'men_1',
          title: 'The Messages You Learned',
          content: 'Many men were taught to hold it together, push through, and not show pain. That strength helped you survive - but survival isn\'t the same as living well. What we don\'t express doesn\'t disappear; it settles into stress, tension, and distance from those we care about.',
          affirmation: 'You matter. What you feel matters.',
        ),
        GuidanceCard(
          id: 'men_2',
          title: 'Opening Up Isn\'t Weakness',
          content: 'Opening up doesn\'t mean losing control or falling apart. It means being human. Talking is not weakness - it\'s maintenance. You don\'t need perfect words or a full story. Start small. One honest moment. One trusted person.',
          affirmation: 'Real strength isn\'t pretending nothing hurts.',
        ),
        GuidanceCard(
          id: 'men_3',
          title: 'What Men Often Need',
          content: 'Research shows men often want the same things as everyone else: to feel respected, valued, appreciated. To feel wanted and that their presence makes a difference. To have emotional safety - a space with no judgement. To be loved for who they are, not what they provide.',
          affirmation: 'Your needs are valid.',
        ),
      ],
    ),
  ];

  // ============================================
  // WOMEN'S CONTENT - PERIODS/CYCLE
  // ============================================

  static const List<NavigateTopic> womensContent = [
    NavigateTopic(
      id: 'menstrual_cycle',
      title: 'Your Menstrual Cycle',
      subtitle: 'Understanding your monthly patterns',
      area: LifeArea.selfUnderstanding,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'cycle_1',
          title: 'Menstrual Phase (Days 1-5)',
          content: 'During your period, oestrogen and progesterone are at their lowest. You might feel tired, sensitive, inward-focused, or experience lower mood. This is a time when emotions may feel closer to the surface and tolerance for stress can be lower.',
          actionSteps: [
            'Rest and reduce demands where possible',
            'Be patient with yourself',
            'Comfort and self-care are especially important now',
          ],
          affirmation: 'This is a time for rest, not achievement.',
        ),
        GuidanceCard(
          id: 'cycle_2',
          title: 'Follicular Phase (Days 6-14)',
          content: 'After your period, oestrogen starts rising. Many women feel clearer thinking, optimism returning, motivation, and productive energy. Oestrogen supports mood, focus, and confidence.',
          affirmation: 'This is often a high point for mood and energy.',
        ),
        GuidanceCard(
          id: 'cycle_3',
          title: 'Ovulation (Mid-cycle)',
          content: 'When oestrogen peaks, you may feel more social, confident, expressive, and emotionally open. Your body is biologically primed for connection and communication. This is often a high point for mood and energy.',
          affirmation: 'Trust your natural rhythms.',
        ),
        GuidanceCard(
          id: 'cycle_4',
          title: 'Luteal Phase (Days 15-28)',
          content: 'After ovulation, progesterone rises then drops if pregnancy doesn\'t occur. Hormonal shifts affect serotonin (your mood-regulating chemical). You might feel more irritable, anxious, overwhelmed, or tearful. This is when PMS symptoms may appear.',
          actionSteps: [
            'Recognise that hormones are affecting your mood',
            'This isn\'t "you" - it\'s hormonal fluctuations',
            'Plan demanding tasks for earlier in your cycle if possible',
          ],
          affirmation: 'Your feelings are real, and they will shift.',
        ),
      ],
    ),
  ];

  // ============================================
  // MILITARY LIFE
  // ============================================

  static const List<NavigateTopic> militaryContent = [
    NavigateTopic(
      id: 'deployment',
      title: 'During Deployment',
      subtitle: 'Managing time away',
      area: LifeArea.militaryLife,
      type: ContentType.understand,
      audienceFilter: ['serving', 'deployed'],
      cards: [
        GuidanceCard(
          id: 'deploy_1',
          title: 'The Mental Load of Separation',
          content: 'Extended time away from loved ones takes a psychological toll. Isolation can lead to overthinking, low mood, sleep disruption, and relationship strain. Recognising these as normal responses helps you manage them.',
          affirmation: 'This is temporary. One day at a time.',
        ),
        GuidanceCard(
          id: 'deploy_2',
          title: 'Maintaining Routine',
          content: 'When you\'re isolated, structure becomes your anchor. Consistent wake times, regular exercise, and small rituals provide psychological stability. Even small routines - a morning coffee, an evening wind-down - help.',
          actionSteps: [
            'Set consistent wake and sleep times',
            'Build in regular physical activity',
            'Create something to look forward to each day',
          ],
          affirmation: 'Small routines build stability.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'transition',
      title: 'Leaving the Military',
      subtitle: 'Navigating civilian life',
      area: LifeArea.militaryLife,
      type: ContentType.understand,
      audienceFilter: ['veteran'],
      cards: [
        GuidanceCard(
          id: 'trans_1',
          title: 'Identity Shift',
          content: 'Leaving the military isn\'t just changing jobs - it\'s leaving behind an identity, a community, a way of life. Feeling lost, uncertain, or grieving what you\'ve left is completely normal. Give yourself time to find who you are outside the uniform.',
          affirmation: 'Who you are is bigger than any role.',
        ),
        GuidanceCard(
          id: 'trans_2',
          title: 'The Civilian World Feels Different',
          content: 'Civilian life can feel slower, less purposeful, or frustrating. The clear hierarchy and mission focus of military life is replaced by ambiguity. This adjustment takes time - often more than people expect.',
          affirmation: 'It takes time to find your new rhythm.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'alongside',
      title: 'Supporting Someone Who Serves',
      subtitle: 'For family and friends',
      area: LifeArea.militaryLife,
      type: ContentType.understand,
      audienceFilter: ['alongside'],
      cards: [
        GuidanceCard(
          id: 'along_1',
          title: 'Your Experience Matters Too',
          content: 'Being alongside someone in the military is its own challenge. The worry, the separations, the uncertainty, managing life alone during deployments - your experience is valid. You don\'t need to minimise what you go through.',
          affirmation: 'You\'re not "just" supporting - you\'re carrying too.',
        ),
        GuidanceCard(
          id: 'along_2',
          title: 'When They Come Home',
          content: 'Reunions aren\'t always smooth. They\'ve changed, you\'ve changed, and it takes time to reconnect. Give each other grace. The person who left isn\'t exactly the person who returns, and that\'s okay.',
          affirmation: 'Reconnection takes patience from both sides.',
        ),
      ],
    ),
  ];

  // ============================================
  // URGENT SUPPORT
  // ============================================

  static const List<NavigateTopic> urgentSupport = [
    NavigateTopic(
      id: 'crisis_resources',
      title: 'Need Immediate Help',
      subtitle: 'Crisis resources available now',
      area: LifeArea.mentalHealth,
      type: ContentType.understand,
      cards: [
        GuidanceCard(
          id: 'crisis_1',
          title: 'If You\'re in Crisis',
          content: 'If you\'re having thoughts of ending your life, please reach out now. You don\'t have to face this alone. These feelings are temporary, even though they don\'t feel that way right now.',
          actionSteps: [
            'UK: Samaritans 116 123 (free, 24/7)',
            'Veterans UK: 0808 1914 218',
            'Combat Stress 24-hour helpline: 0800 138 1619',
            'Text SHOUT to 85258 for text support',
          ],
          affirmation: 'You matter. Please reach out.',
        ),
        GuidanceCard(
          id: 'crisis_2',
          title: 'Feeling Unsafe at Home',
          content: 'If you\'re experiencing domestic abuse or feel unsafe, help is available. You deserve to be safe.',
          actionSteps: [
            'National Domestic Abuse Helpline: 0808 2000 247',
            'Men\'s Advice Line: 0808 801 0327',
            'In immediate danger: Call 999',
          ],
          affirmation: 'You deserve to be safe.',
        ),
      ],
    ),
  ];

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get all topics for a life area
  static List<NavigateTopic> getTopicsForArea(LifeArea area) {
    final all = <NavigateTopic>[];

    // Add topics based on area
    switch (area) {
      case LifeArea.relationships:
        all.addAll(relationshipsUnderstand);
        all.addAll(relationshipsReflect);
        all.addAll(relationshipsGrow);
        break;
      case LifeArea.selfUnderstanding:
        all.addAll(selfUnderstand);
        all.addAll(mensContent);
        all.addAll(womensContent);
        break;
      case LifeArea.militaryLife:
        all.addAll(militaryContent);
        break;
      case LifeArea.mentalHealth:
        all.addAll(urgentSupport);
        break;
      default:
        // Other areas to be added
        break;
    }

    return all;
  }

  /// Get topics filtered by audience
  static List<NavigateTopic> getFilteredTopics(
    LifeArea area, {
    String? audience,
    String? gender,
  }) {
    final topics = getTopicsForArea(area);

    return topics.where((topic) {
      if (topic.audienceFilter == null) return true;

      // Check if any filter matches
      final filters = topic.audienceFilter!;
      if (audience != null && filters.contains(audience)) return true;
      if (gender != null && filters.contains(gender)) return true;

      // If topic has filters but none match, exclude it
      return filters.isEmpty;
    }).toList();
  }

  /// Get all life areas
  static List<LifeArea> get allAreas => LifeArea.values;
}



