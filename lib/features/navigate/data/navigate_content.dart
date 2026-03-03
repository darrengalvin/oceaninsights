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
          content: 'Research shows men often want the same things as everyone else: to feel respected and not belittled. Appreciation — to know their actions and feelings are seen. Emotional safety — a space with no judgement. Desire — to feel wanted. To matter — to know their presence makes a difference. Acceptance — being loved for exactly who they are, not what they provide.',
          affirmation: 'Your needs are valid.',
        ),
        GuidanceCard(
          id: 'men_4',
          title: 'The Needs Nobody Talks About',
          content: 'Autonomy — the space to make choices and feel trusted. Permission to feel — even if you don\'t always know how to express emotions, having the space to try without judgement. And peace — less chaos, less criticism, calm environments. These aren\'t luxuries. They\'re what allows a man to be present, open, and connected.',
          affirmation: 'Needing peace is not the same as avoiding life.',
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
          content: 'During your period, oestrogen and progesterone are at their lowest. Your body is shedding the uterine lining and energy naturally dips. You might feel tired, sensitive, inward-focused, experience lower mood, and have cramps. This is a time when emotions may feel closer to the surface and tolerance for stress can be lower.',
          actionSteps: [
            'Rest, comfort, patience, and reduced demands',
            'A warm water bottle or gentle stretching can help with cramps',
            'Be patient with yourself — this phase is about recovery, not performance',
          ],
          affirmation: 'This is a time for rest, not achievement.',
        ),
        GuidanceCard(
          id: 'cycle_2',
          title: 'Follicular Phase (Days 6-14)',
          content: 'After your period, oestrogen starts rising. Many women feel clearer thinking, optimism returning, motivation, and productive energy. Oestrogen supports mood, focus, and confidence. You may feel more emotionally balanced and energised here than at any other point in your cycle.',
          actionSteps: [
            'This is a great time for challenging tasks and big decisions',
            'Strength training and higher-intensity exercise feel more natural now',
            'Use this energy window for things that need focus and drive',
          ],
          affirmation: 'This is often a high point for mood and energy.',
        ),
        GuidanceCard(
          id: 'cycle_3',
          title: 'Ovulation (Mid-cycle)',
          content: 'When oestrogen peaks, you may feel more social, confident, expressive, emotionally open, and sexually inclined. Your body is biologically primed for connection and communication. This is often a high point for mood and energy.',
          actionSteps: [
            'Social activities and communication tasks suit this phase well',
            'Be aware that ligament laxity increases around ovulation — slightly higher injury risk during intense physical activity',
            'Trust what your body is telling you',
          ],
          affirmation: 'Trust your natural rhythms.',
        ),
        GuidanceCard(
          id: 'cycle_4',
          title: 'Luteal Phase (Days 15-28)',
          content: 'After ovulation, progesterone rises then drops if pregnancy doesn\'t occur. Hormonal shifts affect serotonin — a mood-regulating chemical. You might feel more irritable, anxious, overwhelmed, or tearful. This is when premenstrual syndrome (PMS) symptoms may appear. For some women, this phase feels emotionally heavy or overstimulating. This is hormonal fluctuations — not a character flaw.',
          actionSteps: [
            'Recognise that hormones are affecting your mood — this isn\'t "you"',
            'Plan demanding tasks for earlier in your cycle if possible',
            'Complex carbohydrates and magnesium-rich foods can help stabilise mood',
          ],
          affirmation: 'Your feelings are real, and they will shift.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'what_women_want',
      title: 'What Women Often Need',
      subtitle: 'Understanding emotional needs in relationships',
      area: LifeArea.relationships,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'ww_1',
          title: 'Emotional Safety',
          content: 'Feeling secure enough to express emotions without them being dismissed, minimised, or used against you. A relationship where you can be vulnerable without fear. This is the foundation everything else is built on.',
          affirmation: 'You deserve to feel safe being yourself.',
        ),
        GuidanceCard(
          id: 'ww_2',
          title: 'Consistency',
          content: 'Words and actions that align. Knowing someone will show up — not just on the good days. Consistency isn\'t about grand gestures; it\'s about the small, reliable things that build trust over time.',
          affirmation: 'You deserve someone whose actions match their words.',
        ),
        GuidanceCard(
          id: 'ww_3',
          title: 'Communication',
          content: 'The effort to listen, to try to understand, and to talk through issues calmly rather than shutting down or exploding. Communication isn\'t about agreeing on everything — it\'s about being willing to try.',
          affirmation: 'Being heard matters.',
        ),
        GuidanceCard(
          id: 'ww_4',
          title: 'Affection',
          content: 'Emotional and physical closeness — not just in the good times. A hand held during a hard day. A hug that says "I\'m here." Affection isn\'t a luxury; it\'s how many women feel connected and valued.',
          affirmation: 'Wanting closeness is not neediness.',
        ),
        GuidanceCard(
          id: 'ww_5',
          title: 'To Feel Seen',
          content: 'Not just looked at — truly seen. Noticed when something is wrong. Appreciated for the invisible work you do. Acknowledged as a whole person, not just a role you fill.',
          affirmation: 'You are more than what you do for others.',
        ),
        GuidanceCard(
          id: 'ww_6',
          title: 'Support Without Avoidance',
          content: 'Being supportive means being present — not avoidant or detached when things get difficult. It means leaning in, not pulling away. Being willing to sit in discomfort together.',
          affirmation: 'You deserve someone who stays in the room.',
        ),
        GuidanceCard(
          id: 'ww_7',
          title: 'Growth',
          content: 'Encouragement to evolve and pursue purpose. A partner who celebrates your ambition rather than feeling threatened by it. Growth isn\'t about changing who you are — it\'s about becoming more of who you are.',
          affirmation: 'Your growth is not a threat to the right person.',
        ),
        GuidanceCard(
          id: 'ww_8',
          title: 'Valued as a Woman',
          content: 'Loving what you have and not lusting over what you don\'t have. Feeling chosen — not settled for. Knowing your partner sees you, appreciates you, and isn\'t constantly looking elsewhere.',
          affirmation: 'You are enough. Right now. As you are.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'cycle_training',
      title: 'Your Cycle & Training',
      subtitle: 'How to train smarter with your body',
      area: LifeArea.physicalHealth,
      type: ContentType.grow,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'ct_1',
          title: 'Menstrual Phase — Gentle & Recovery',
          content: 'Energy is lowest here. Your body is doing internal work. Light movement helps — walks, yoga, gentle stretching — but this is not the time to push for personal bests. Listen to your body. Rest is productive.',
          actionSteps: [
            'Walking, swimming, or gentle yoga',
            'Prioritise mobility and flexibility',
            'Reduce training volume — not the time for heavy sessions',
          ],
          affirmation: 'Rest is part of training.',
        ),
        GuidanceCard(
          id: 'ct_2',
          title: 'Follicular Phase — Strength & Power',
          content: 'Rising oestrogen supports muscle recovery and energy. This is your window for strength training, skill acquisition, and higher-intensity work. Your body responds well to challenge right now.',
          actionSteps: [
            'Strength training and resistance work',
            'Try new skills or increase training load',
            'Your body recovers faster in this phase',
          ],
          affirmation: 'Your body is built for this.',
        ),
        GuidanceCard(
          id: 'ct_3',
          title: 'Ovulation — Peak Performance',
          content: 'Oestrogen peaks and testosterone briefly rises. Many women feel strongest here. Great for high-intensity work and fitness tests. However, be aware that ligament laxity also increases — warm up thoroughly and be mindful of joint-loading exercises.',
          actionSteps: [
            'High-intensity intervals, sprints, circuits',
            'Warm up thoroughly — ACL injury risk is slightly elevated',
            'Schedule fitness assessments here if you can',
          ],
          affirmation: 'This is your power window.',
        ),
        GuidanceCard(
          id: 'ct_4',
          title: 'Luteal Phase — Steady & Moderate',
          content: 'As progesterone rises, your body temperature increases and perceived effort goes up — the same workout can feel harder. Endurance may dip. Favour moderate, steady-state exercise. Reduce intensity and focus on consistency rather than pushing limits.',
          actionSteps: [
            'Steady-state cardio, moderate resistance training',
            'Stay hydrated — you may sweat more in this phase',
            'Don\'t judge your fitness by how this phase feels',
          ],
          affirmation: 'Showing up is enough.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'perimenopause',
      title: 'Perimenopause',
      subtitle: 'The transition nobody warns you about',
      area: LifeArea.physicalHealth,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'peri_1',
          title: 'What Is Perimenopause?',
          content: 'Perimenopause is the transition period before menopause, often starting in your mid-to-late 40s but sometimes earlier. Hormone levels become unpredictable — oestrogen can spike and crash rather than gradually declining. Many women are blindsided because nobody told them this was coming.',
          affirmation: 'Knowledge is power.',
        ),
        GuidanceCard(
          id: 'peri_2',
          title: 'The Symptoms',
          content: 'Irregular periods, hot flushes, night sweats, brain fog, anxiety (often sudden and unexplained), joint pain, fatigue, sleep disruption, mood swings, rage, low libido, weight changes, and heart palpitations. These are frequently misdiagnosed as stress, anxiety disorders, or depression — especially in high-pressure military environments.',
          actionSteps: [
            'Track your symptoms — patterns help your doctor diagnose',
            'Ask your GP or MO specifically about perimenopause',
            'Don\'t accept "it\'s just stress" if symptoms don\'t add up',
          ],
          affirmation: 'You are not losing your mind. Your hormones are shifting.',
        ),
        GuidanceCard(
          id: 'peri_3',
          title: 'Getting Help',
          content: 'HRT (Hormone Replacement Therapy) is safe for most women and can be life-changing. Cognitive behavioural therapy (CBT) can help with mood symptoms. Exercise, sleep hygiene, and reducing alcohol also make a significant difference. You should not have to suffer in silence — this is a medical condition, not a weakness.',
          actionSteps: [
            'Speak to your GP or MO — ask directly about HRT options',
            'Keep a symptom diary for at least 3 months',
            'Connect with other women going through it — you are not alone',
          ],
          affirmation: 'Asking for help is strength.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'pmdd',
      title: 'PMDD — Beyond PMS',
      subtitle: 'When your luteal phase becomes unbearable',
      area: LifeArea.selfUnderstanding,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'pmdd_1',
          title: 'What Is PMDD?',
          content: 'Premenstrual Dysphoric Disorder affects 5-8% of women. It\'s not "bad PMS" — it\'s a severe sensitivity to normal hormonal changes that causes extreme mood shifts in the luteal phase. Symptoms include severe depression, rage, hopelessness, anxiety, and in some cases suicidal thoughts — that lift almost immediately once your period starts.',
          affirmation: 'If this sounds familiar, you are not broken.',
        ),
        GuidanceCard(
          id: 'pmdd_2',
          title: 'How to Know',
          content: 'The hallmark of PMDD is the pattern: severe symptoms in the 1-2 weeks before your period that disappear within a few days of bleeding starting. If you track your mood against your cycle and see this pattern repeating, speak to your doctor. Many women are misdiagnosed with depression or bipolar disorder before PMDD is identified.',
          actionSteps: [
            'Track mood daily alongside your cycle for 2-3 months',
            'Note when symptoms start and when they lift',
            'Show your doctor the pattern — it\'s the key to diagnosis',
          ],
          affirmation: 'Naming it is the first step to managing it.',
        ),
        GuidanceCard(
          id: 'pmdd_3',
          title: 'Treatment Options',
          content: 'PMDD is treatable. Options include SSRIs (which can be taken only during the luteal phase), hormonal treatments to suppress ovulation, CBT, and lifestyle adjustments. Many women find dramatic improvement once they get the right support. You do not have to white-knuckle through every month.',
          affirmation: 'There is help. You deserve it.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'iron_deficiency',
      title: 'Iron & Energy',
      subtitle: 'Why you might be running on empty',
      area: LifeArea.physicalHealth,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'iron_1',
          title: 'The Hidden Drain',
          content: 'Heavy periods are the most common cause of iron deficiency in women. Low iron means less oxygen reaches your muscles and brain. The result: persistent fatigue, dizziness, breathlessness on exertion, brain fog, and reduced physical performance. Many active women attribute this to overtraining or stress when the real issue is their iron levels.',
          affirmation: 'Tiredness isn\'t always about effort.',
        ),
        GuidanceCard(
          id: 'iron_2',
          title: 'Signs to Watch For',
          content: 'Unusual tiredness that rest doesn\'t fix. Feeling breathless during exercise that used to be manageable. Pale skin, brittle nails, feeling cold. Difficulty concentrating. Craving ice or non-food items (pica). If you\'re experiencing these alongside heavy periods, ask your doctor for a ferritin blood test — not just haemoglobin.',
          actionSteps: [
            'Ask specifically for a ferritin test — it catches depletion earlier',
            'Iron-rich foods: red meat, spinach, lentils, fortified cereals',
            'Vitamin C helps iron absorption — pair with meals',
          ],
          affirmation: 'Your body is trying to tell you something.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'endometriosis',
      title: 'Endometriosis',
      subtitle: 'Pain that deserves to be taken seriously',
      area: LifeArea.physicalHealth,
      type: ContentType.understand,
      audienceFilter: ['woman'],
      cards: [
        GuidanceCard(
          id: 'endo_1',
          title: 'What Is It?',
          content: 'Endometriosis is a condition where tissue similar to the uterine lining grows outside the womb — on the ovaries, bowel, or elsewhere in the pelvis. It affects roughly 1 in 10 women. Symptoms include severe period pain, chronic pelvic pain, pain during or after sex, fatigue, and difficulty getting pregnant. The average time to diagnosis is 7.5 years — often because women are told their pain is "normal".',
          affirmation: 'Pain that stops you functioning is never "just a period".',
        ),
        GuidanceCard(
          id: 'endo_2',
          title: 'In the Military',
          content: 'Service women with endometriosis often push through pain to avoid being seen as weak or unreliable. But untreated endometriosis gets worse, not better. If period pain regularly affects your ability to train, work, or sleep — that is not normal and you deserve investigation. Treatments include hormonal management, pain relief, and in some cases surgery.',
          actionSteps: [
            'Keep a pain diary — note severity, timing, and impact on duties',
            'Ask your MO for a referral to gynaecology if pain is severe',
            'Hormonal contraception can sometimes help manage symptoms',
          ],
          affirmation: 'Advocating for your health is not weakness.',
        ),
      ],
    ),
    NavigateTopic(
      id: 'period_ops',
      title: 'Periods on Operations',
      subtitle: 'Practical management in the field',
      area: LifeArea.militaryLife,
      type: ContentType.grow,
      audienceFilter: ['woman', 'serving'],
      cards: [
        GuidanceCard(
          id: 'ops_1',
          title: 'Suppressing Periods for Deployment',
          content: 'Many service women choose to suppress periods before and during deployment using hormonal contraception. This is medically safe and widely used. The combined pill taken back-to-back, the hormonal IUD, the implant, or the injection can all reduce or eliminate periods. Speak to your MO well before deployment to find what works for your body — don\'t leave it to the last minute.',
          actionSteps: [
            'Discuss options with your MO at least 3 months before deployment',
            'Trial the method at home first to check for side effects',
            'Carry backup supplies (panty liners, painkillers) regardless',
          ],
          affirmation: 'Planning ahead is professionalism, not weakness.',
        ),
        GuidanceCard(
          id: 'ops_2',
          title: 'Managing in the Field',
          content: 'When periods happen on exercise or operations: menstrual cups are popular because they\'re reusable and last up to 12 hours. Period pants work well as backup. Carry disposal bags (opaque, sealable) for used products. Baby wipes for hygiene when showers aren\'t available. Anti-diarrhoea medication (Imodium) can help if bowel changes accompany your period.',
          actionSteps: [
            'Practice using a menstrual cup before you need it in the field',
            'Pack supplies in your grab bag — not in a bergen that might get separated',
            'Dark-coloured underwear gives peace of mind',
          ],
          affirmation: 'Every woman who has served has figured this out. You will too.',
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

    switch (area) {
      case LifeArea.relationships:
        all.addAll(relationshipsUnderstand);
        all.addAll(relationshipsReflect);
        all.addAll(relationshipsGrow);
        all.addAll(mensContent.where((t) => t.area == area));
        all.addAll(womensContent.where((t) => t.area == area));
        break;
      case LifeArea.selfUnderstanding:
        all.addAll(selfUnderstand);
        all.addAll(mensContent.where((t) => t.area == area));
        all.addAll(womensContent.where((t) => t.area == area));
        break;
      case LifeArea.physicalHealth:
        all.addAll(womensContent.where((t) => t.area == area));
        break;
      case LifeArea.militaryLife:
        all.addAll(militaryContent);
        all.addAll(womensContent.where((t) => t.area == area));
        break;
      case LifeArea.mentalHealth:
        all.addAll(urgentSupport);
        break;
      default:
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



