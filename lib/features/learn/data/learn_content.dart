/// Article categories
enum ArticleCategory {
  brainScience,
  psychology,
  lifeSituation,
}

/// Section within an article
class ArticleSection {
  final String? heading;
  final String content;
  final String? tip;
  
  const ArticleSection({
    this.heading,
    required this.content,
    this.tip,
  });
}

/// A trusted source an article is based on (NHS, Mind, etc.)
class ArticleSource {
  final String name;
  final String url;

  const ArticleSource({
    required this.name,
    required this.url,
  });
}

/// Full article data structure
class Article {
  final String id;
  final String title;
  final String summary;
  final ArticleCategory category;
  final int readTimeMinutes;
  final List<ArticleSection> sections;
  final List<String> keyTakeaways;
  final List<String>? ageBrackets; // For life situations - filter by age
  final List<ArticleSource>? sources; // Trusted sources the article is based on
  
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.readTimeMinutes,
    required this.sections,
    required this.keyTakeaways,
    this.ageBrackets,
    this.sources,
  });
}

/// Pre-loaded educational content
class LearnContent {
  LearnContent._();
  
  // ============================================
  // BRAIN SCIENCE ARTICLES
  // ============================================
  
  static const List<Article> brainScienceArticles = [
    Article(
      id: 'nine_second_rule',
      title: 'Pause Before You React',
      summary: 'A short pause gives you time to think before strong feelings take over.',
      category: ArticleCategory.brainScience,
      readTimeMinutes: 3,
      sections: [
        ArticleSection(
          content: 'When something sets off a strong feeling, like anger or panic, it can be hard to think clearly. Your body reacts first: your heart may race and your muscles tense. Giving yourself a moment before you respond can help you choose what to do next.',
        ),
        ArticleSection(
          heading: 'What the NHS Suggests',
          content: 'The NHS suggests giving yourself time to think before reacting. Try counting to 10 and doing a calming breathing exercise. Noticing the early signs that you are getting angry also helps you calm down sooner.',
        ),
        ArticleSection(
          heading: 'How to Use This',
          content: 'When you feel a strong reaction rising:\n\n1. Notice the feeling\n2. Breathe in gently for 5, and out for 5\n3. Count slowly to 10\n4. Then decide how to respond',
          tip: 'Practise with small frustrations first. The more you do it, the more natural it becomes.',
        ),
        ArticleSection(
          heading: 'If It Feels Out of Control',
          content: 'If anger or other strong feelings are affecting your life or relationships, talk to someone you trust or your GP. You can also refer yourself to NHS Talking Therapies.',
        ),
      ],
      keyTakeaways: [
        'Strong feelings can make it hard to think clearly',
        'Counting to 10 and calm breathing give you time to think',
        'Spotting the early signs helps you calm down sooner',
        'Your GP can help if it feels out of control',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Get help with anger',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/anger/',
        ),
        ArticleSource(
          name: 'NHS: Breathing exercises for stress',
          url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/breathing-exercises-for-stress/',
        ),
      ],
    ),
    
    Article(
      id: 'fight_flight_freeze',
      title: 'Understanding Fight, Flight & Freeze',
      summary: 'Your body\'s ancient survival system and why it sometimes misfires.',
      category: ArticleCategory.brainScience,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: 'Your nervous system has a built-in alarm system designed to keep you alive. When it detects danger, it triggers one of three responses: fight, flight, or freeze. This system hasn\'t changed much since our ancestors faced physical threats like predators.',
        ),
        ArticleSection(
          heading: 'The Three Responses',
          content: 'Fight: Increased aggression, tension, urge to confront\n\nFlight: Urge to escape, restlessness, anxiety\n\nFreeze: Feeling stuck, unable to think or move, dissociation\n\nAll three are your body\'s attempt to protect you.',
        ),
        ArticleSection(
          heading: 'The Modern Problem',
          content: 'Your brain can\'t distinguish between a physical threat (a predator) and a psychological one (an angry email from your boss). Both trigger the same survival response, flooding your body with stress hormones like cortisol and adrenaline.',
          tip: 'Recognising which response you tend toward helps you manage it. Do you get angry? Want to run? Or do you shut down?',
        ),
        ArticleSection(
          heading: 'Resetting Your System',
          content: 'Things that can help you feel calmer after a stress response:\n\n• Physical activity, even a short walk\n• Calming breathing exercises\n• Talking to someone you trust\n\nThese are all on the NHS list of things that can help with stress.',
        ),
      ],
      keyTakeaways: [
        'Fight, flight, and freeze are normal survival responses',
        'Your brain treats modern stress the same as physical danger',
        'Recognising your typical response helps you manage it',
        'Activity, calm breathing and talking can all help',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Stress',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/stress/',
        ),
      ],
    ),
    
    Article(
      id: 'neuroplasticity',
      title: 'Your Brain Can Change',
      summary: 'Understanding neuroplasticity and why it\'s never too late to rewire your thinking.',
      category: ArticleCategory.brainScience,
      readTimeMinutes: 4,
      sections: [
        ArticleSection(
          content: 'For decades, scientists believed the adult brain was fixed and unchangeable. We now know this is completely wrong. Your brain is constantly rewiring itself based on your experiences, thoughts, and behaviours. This is called neuroplasticity.',
        ),
        ArticleSection(
          heading: 'How It Works',
          content: 'Think of your brain like paths in a forest. The paths you walk most often become clear and easy to travel. Paths you ignore become overgrown. Your thoughts work the same way - repeated thoughts strengthen neural pathways, making them easier to access.',
        ),
        ArticleSection(
          heading: 'The Practical Implication',
          content: 'This means:\n\n• Negative thought patterns can be unlearned\n• New, healthier patterns can be built\n• It takes repetition and consistency\n• Change is possible at any age',
          tip: 'Every time you choose a different response to a familiar trigger, you\'re literally rewiring your brain.',
        ),
        ArticleSection(
          heading: 'Building New Pathways',
          content: 'To change a pattern:\n\n1. Become aware of the existing pattern\n2. Deliberately choose a different response\n3. Repeat consistently over time\n\nNew habits take time to become automatic, often a couple of months or more. Keep going even when it feels slow.',
        ),
      ],
      keyTakeaways: [
        'Your brain physically changes based on what you think and do',
        'Repeated thoughts create stronger neural pathways',
        'It\'s never too late to rewire negative patterns',
        'Consistency and repetition are key to lasting change',
      ],
    ),
    
    Article(
      id: 'sleep_mental_health',
      title: 'Sleep and Your Mind',
      summary: 'Why sleep is not a luxury but a necessity for mental wellbeing.',
      category: ArticleCategory.brainScience,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: 'Sleep isn\'t just rest for your body - it\'s essential maintenance time for your brain. During sleep, your brain processes emotions, consolidates memories, and clears out toxins that build up during waking hours.',
        ),
        ArticleSection(
          heading: 'What Happens When We Sleep',
          content: 'REM sleep (when we dream) is crucial for emotional processing. Your brain essentially "reviews" the day\'s emotional experiences and files them properly. Without enough REM sleep, emotions stay raw and unprocessed.',
        ),
        ArticleSection(
          heading: 'The Sleep-Mood Connection',
          content: 'Sleep and mood are closely linked. The NHS notes that low mood can cause problems sleeping, and that getting more sleep is one of the small changes that can help low mood. When you are short of sleep, it is often harder to cope with stress.',
          tip: 'If you\'re feeling emotionally volatile, ask yourself: "How did I sleep last night?"',
        ),
        ArticleSection(
          heading: 'Improving Sleep Quality',
          content: 'Key factors for better sleep:\n\n• Consistent wake time (even weekends)\n• Limited screen time before bed\n• Cool, dark environment\n• No caffeine after early afternoon\n• Wind-down routine\n\nQuality matters as much as quantity.',
        ),
      ],
      keyTakeaways: [
        'Sleep is when your brain processes emotions',
        'Poor sleep directly impacts emotional regulation',
        'Regular exercise may improve your mood and help you sleep better',
        'Sleep problems and mental health issues often go together',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Low mood, sadness and depression',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/low-mood-sadness-depression/',
        ),
      ],
    ),
  ];
  
  // ============================================
  // PSYCHOLOGY ARTICLES
  // ============================================
  
  static const List<Article> psychologyArticles = [
    Article(
      id: 'validating_emotions',
      title: 'All Feelings Are Valid',
      summary: 'Understanding why your emotions make sense, even when they\'re uncomfortable.',
      category: ArticleCategory.psychology,
      readTimeMinutes: 4,
      sections: [
        ArticleSection(
          content: 'Every emotion you experience has a reason. Feelings aren\'t random - they\'re your mind\'s response to your experiences, memories, and perceptions. Even "negative" emotions like anger, fear, or sadness serve important purposes.',
        ),
        ArticleSection(
          heading: 'Emotions Are Information',
          content: 'Think of emotions as messengers, not problems:\n\n• Anger tells you a boundary has been crossed\n• Fear alerts you to potential danger\n• Sadness signals loss or unmet needs\n• Anxiety points to uncertainty or threat\n\nThe emotion itself isn\'t the problem - it\'s information.',
        ),
        ArticleSection(
          heading: 'The Trap of Judging Feelings',
          content: 'Many of us learned to judge our emotions: "I shouldn\'t feel this way" or "I\'m being stupid." This judgement adds suffering on top of the original feeling. You end up feeling bad about feeling bad.',
          tip: 'Try replacing "I shouldn\'t feel this" with "It makes sense I feel this because..."',
        ),
        ArticleSection(
          heading: 'Validation vs Justification',
          content: 'Validating an emotion doesn\'t mean the emotion is "right" or that you should act on it. It simply means acknowledging that the feeling exists and has a reason.\n\nYou can validate your anger while choosing not to act on it aggressively.',
        ),
      ],
      keyTakeaways: [
        'All emotions have a reason - they\'re information',
        'Judging your feelings adds unnecessary suffering',
        'Validating an emotion doesn\'t mean acting on it',
        'Understanding why you feel something helps you respond better',
      ],
    ),
    
    Article(
      id: 'thoughts_not_facts',
      title: 'Thoughts Are Not Facts',
      summary: 'Learning to observe your thoughts without believing everything they tell you.',
      category: ArticleCategory.psychology,
      readTimeMinutes: 4,
      sections: [
        ArticleSection(
          content: 'Your mind produces thousands of thoughts every day. Many of these thoughts are automatic - they pop up without your conscious choice. Just because a thought appears in your mind doesn\'t make it true or important.',
        ),
        ArticleSection(
          heading: 'The Thinking Mind',
          content: 'Your brain is a prediction machine, constantly generating thoughts about what might happen, what could go wrong, and what things mean. Many of these predictions are based on past experiences and may not apply to current situations.',
        ),
        ArticleSection(
          heading: 'Common Thinking Traps',
          content: 'Watch out for these patterns:\n\n• All-or-nothing thinking: "If it\'s not perfect, it\'s a failure"\n• Mind reading: "They must think I\'m an idiot"\n• Fortune telling: "This will definitely go wrong"\n• Catastrophising: "This is the worst thing ever"\n\nThese are common but often inaccurate.',
          tip: 'When you notice a strong negative thought, ask: "Is this a fact or an interpretation?"',
        ),
        ArticleSection(
          heading: 'Creating Distance',
          content: 'Instead of "I\'m a failure," try "I\'m having the thought that I\'m a failure." This small shift creates distance between you and the thought, making it easier to question its accuracy.',
        ),
      ],
      keyTakeaways: [
        'Thoughts are mental events, not facts',
        'Your brain generates many automatic thoughts that aren\'t accurate',
        'Recognising thinking patterns helps you question them',
        'Creating distance from thoughts reduces their power',
      ],
    ),
    
    Article(
      id: 'stress_vs_stressors',
      title: 'Stress vs Stressors',
      summary: 'Understanding the difference between what causes stress and the stress itself.',
      category: ArticleCategory.psychology,
      readTimeMinutes: 3,
      sections: [
        ArticleSection(
          content: 'Many people focus on eliminating stressors - the things that cause stress. But stressors and stress are not the same thing. You can remove a stressor and still carry the stress in your body.',
        ),
        ArticleSection(
          heading: 'Stress Is Felt in the Body',
          content: 'Stress is your body\'s reaction to feeling threatened or under pressure. It can affect how you feel physically, mentally and how you behave, even after the cause has gone.',
        ),
        ArticleSection(
          heading: 'Things That Can Help',
          content: 'The NHS suggests:\n\n• Talking to a friend, family member or health professional\n• Breathing exercises for stress\n• Setting small targets rather than doing everything at once\n• Planning ahead for stressful days\n• Not relying on alcohol, cigarettes, gambling or drugs to cope',
          tip: 'Being physically active is also one of the NHS\'s five steps to mental wellbeing.',
        ),
      ],
      keyTakeaways: [
        'Removing a stressor doesn\'t automatically remove the stress',
        'Stress affects your body, mind and behaviour',
        'Talking, breathing exercises and small targets can help',
        'Speak to a GP if stress is affecting your daily life',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Stress',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/stress/',
        ),
        ArticleSource(
          name: 'NHS: Five steps to mental wellbeing',
          url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/five-steps-to-mental-wellbeing/',
        ),
      ],
    ),

    Article(
      id: 'understanding_anger',
      title: 'Understanding Anger',
      summary: "Anger is a normal emotion. Here's how to spot it early and stop it running the show.",
      category: ArticleCategory.psychology,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Everyone gets angry sometimes. It's a normal human emotion, and on its own it isn't a problem. It becomes a problem when it starts to damage your relationships, your work or how you feel about yourself.",
        ),
        ArticleSection(
          heading: 'How Anger Shows Up',
          content: "Anger affects your body, your mind and what you do. You might notice:\n\n• Body: heart beating faster, tight muscles, clenched fists, a tight chest, feeling hot\n• Mind: feeling tense or on edge, unable to relax, irritable, humiliated or resentful\n• Behaviour: shouting, sulking or ignoring people, starting fights, breaking things\n\nSome people turn anger inwards instead, which can show up as self-harm. It isn't always obvious that anger is behind a change in how you're acting.",
        ),
        ArticleSection(
          heading: 'Common Triggers',
          content: "What sets anger off is different for everyone, but common triggers include:\n\n• Being treated unfairly and feeling powerless to change it\n• Feeling threatened or attacked\n• People not respecting your feelings or your things\n• Being stopped from getting something done\n\nYou're more likely to react strongly when you're already stressed, when you've been through trauma, or when alcohol or drugs are involved. How the adults around you handled anger when you were growing up can play a part too.",
        ),
        ArticleSection(
          heading: 'Things That Help',
          content: "• Pause before you react. Count to 10 or take a few slow breaths\n• Practise noticing your body's early warning signs so you can step away sooner\n• Talk it through with someone who isn't involved\n• Get moving. Walking, running, swimming or yoga all help burn off tension\n• Set small, realistic goals rather than trying to fix everything at once\n• Put your energy into what you can change, not what you can't",
          tip: "Avoid using alcohol, drugs, gambling or cigarettes to cope. They tend to make anger and mental health worse, not better.",
        ),
        ArticleSection(
          heading: 'When to Get Help',
          content: "Speak to a GP if you're struggling to control your anger, self-help isn't working, or your anger is affecting the people around you. They can refer you to anger management or counselling. In England you can also refer yourself to NHS Talking Therapies without seeing a GP.\n\nIf your anger has led to violence or threats towards a partner or family member, the Respect Phoneline (0808 802 4040) offers confidential help for people worried about their own behaviour.",
        ),
      ],
      keyTakeaways: [
        'Anger is normal. What matters is how it comes out',
        'Learn your early warning signs in your body and mind',
        'Pausing, breathing and moving all help bring anger down',
        'A GP or NHS Talking Therapies can help if it feels out of control',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Get help with anger',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/anger/',
        ),
        ArticleSource(
          name: 'NHS: Getting help for domestic violence and abuse',
          url: 'https://www.nhs.uk/live-well/getting-help-for-domestic-violence/',
        ),
      ],
    ),

    Article(
      id: 'anxiety_fear_panic',
      title: 'Anxiety, Fear and Panic',
      summary: 'What anxiety does to your body and mind, and practical ways to ease it.',
      category: ArticleCategory.psychology,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Most people feel anxious or afraid at some point. Anxiety is your body getting ready for a threat, even when the threat is something you're worried might happen rather than something happening right now.",
        ),
        ArticleSection(
          heading: 'What It Can Feel Like',
          content: "• Body: a fast or irregular heartbeat, dizziness, headaches, chest pain, an upset stomach, sweating, shaking, feeling short of breath\n• Mind: feeling tense, unable to relax, worrying about the past or future, poor sleep, struggling to concentrate, fearing the worst\n• Behaviour: avoiding situations that make you anxious, finding it hard to enjoy time off, repeatedly checking things",
        ),
        ArticleSection(
          heading: 'Panic Attacks',
          content: "A panic attack is a sudden rush of intense fear. Your heart races, you may feel dizzy, short of breath, sick or out of control, and your fingers or lips might tingle.\n\nPanic attacks usually last between 5 and 20 minutes. They are frightening, but they are not dangerous and should not harm you.",
          tip: "During a panic attack, try breathing in slowly through your nose and out slowly through your mouth. Remind yourself that it will pass.",
        ),
        ArticleSection(
          heading: 'Things That Help',
          content: "• Talk to someone you trust about how you're feeling\n• Exercise regularly. Walking, swimming, running and yoga all help\n• Eat regular meals to keep your energy steady\n• Try breathing exercises or meditation\n• Build up time in situations that make you anxious bit by bit, rather than avoiding them completely\n• Focus on the things you can influence",
        ),
        ArticleSection(
          heading: 'What to Avoid',
          content: "• Using alcohol, cigarettes, gambling or drugs to take the edge off. They make anxiety worse over time\n• Avoiding everything that makes you anxious. Avoidance tends to keep anxiety going\n• Diagnosing yourself. If you're worried, talk to a GP",
        ),
        ArticleSection(
          heading: 'When to Get Help',
          content: "See a GP if you're struggling to cope or self-help isn't working. If you're 18 or over (16 in some areas) in England, you can refer yourself to NHS Talking Therapies for free.\n\nYou can call Samaritans any time, day or night, on 116 123.",
        ),
      ],
      keyTakeaways: [
        'Anxiety is your body preparing for a threat',
        'Panic attacks feel frightening but are not dangerous',
        'Gradually facing fears works better than avoiding them',
        'Free NHS talking therapies are available without a GP referral',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Anxiety, fear and panic',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/anxiety-fear-panic/',
        ),
      ],
    ),

    Article(
      id: 'low_mood',
      title: 'Low Mood and Sadness',
      summary: 'Feeling low is common. Know what helps, and when it might be something more.',
      category: ArticleCategory.psychology,
      readTimeMinutes: 4,
      sections: [
        ArticleSection(
          content: "Everyone feels low from time to time. Low mood can bring sadness, worry, frustration, tiredness, poor sleep and a dip in confidence. It often lifts after a few days or weeks, especially once a problem is sorted or you get more rest.",
        ),
        ArticleSection(
          heading: 'Common Causes',
          content: "• Pressure at work, losing a job, or retiring\n• Relationship problems, separation or caring for someone\n• Money worries or debt\n• Illness or injury\n• Bereavement\n• Big life changes, even happy ones like a new baby or moving house\n\nSometimes there's no obvious reason at all, and that's okay too.",
        ),
        ArticleSection(
          heading: 'When It Might Be Depression',
          content: "If your mood has stayed low for two weeks or more, it could be depression. Other signs include losing interest in things you used to enjoy, feeling hopeless, finding it hard to concentrate on everyday tasks, or having thoughts of harming yourself.",
          tip: "If you have thoughts of harming yourself or ending your life, call 999, go to A&E, or call NHS 111 and choose the mental health option. You can also call Samaritans on 116 123.",
        ),
        ArticleSection(
          heading: 'Things That Help',
          content: "• Talk to a friend, family member or professional\n• Connect with people who've been through something similar\n• Exercise regularly. It can lift your mood and help you sleep\n• Eat regular, healthy meals\n• Try mindfulness: paying attention to the present moment\n• Set small, achievable goals\n• Don't tell yourself you're the only one. Most people feel like this at some point",
        ),
        ArticleSection(
          heading: 'When to Get Help',
          content: "See a GP if your low mood has lasted more than two weeks, you're struggling to cope, or what you're doing isn't helping. In England, adults can also refer themselves directly to NHS Talking Therapies.",
        ),
      ],
      keyTakeaways: [
        'Low mood is common and usually passes',
        'Two weeks or more of low mood is a sign to talk to a GP',
        'Exercise, routine and talking to people all help',
        'If you have thoughts of harming yourself, get help straight away',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Low mood, sadness and depression',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/low-mood-sadness-depression/',
        ),
        ArticleSource(
          name: 'NHS: Where to get urgent help for mental health',
          url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/',
        ),
      ],
    ),

    Article(
      id: 'feeling_lonely',
      title: 'Feeling Lonely',
      summary: "You can feel lonely in a crowd, in a relationship or miles from home. Here's what helps.",
      category: ArticleCategory.psychology,
      readTimeMinutes: 4,
      sections: [
        ArticleSection(
          content: "Loneliness can affect anyone, at any age. It isn't just about being alone. You can feel lonely when you're surrounded by people, in a relationship, or with family.",
        ),
        ArticleSection(
          heading: 'Why It Happens',
          content: "Loneliness is often linked to:\n\n• Living or working on your own\n• Moving to a new area, job or unit\n• Leaving work or retiring\n• Illness or disability\n• Losing someone close to you\n• Social anxiety\n\nBig life events, even exciting ones, can leave you feeling disconnected too.",
        ),
        ArticleSection(
          heading: 'Things That Help',
          content: "• Tell someone how you're feeling: a friend, relative or professional\n• Join a group or class built around something you enjoy. It's fine to just watch at first\n• Spend time where other people are, like a park, café or gym\n• Volunteer for a local charity\n• Do things you enjoy: a walk, exercise, a podcast\n• Ask your GP about social prescribing. They can connect you with local groups and activities",
          tip: "Be careful comparing yourself to others on social media. Most people only post their best moments.",
        ),
        ArticleSection(
          heading: 'What to Avoid',
          content: "• Trying to change everything at once. Small steps count\n• Telling yourself you're the only one. Many people feel lonely\n• Using alcohol, drugs, gambling or cigarettes to cope",
        ),
        ArticleSection(
          heading: 'When to Get Help',
          content: "If loneliness is leaving you feeling low for more than two weeks, or you're finding it hard to cope, talk to a GP. You can also refer yourself to NHS Talking Therapies in England.",
        ),
      ],
      keyTakeaways: [
        'Loneliness is about feeling disconnected, not just being alone',
        'Small, regular contact with people makes a difference',
        'Groups, volunteering and social prescribing can help you connect',
        'Talk to a GP if loneliness is affecting your mood',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Get help with loneliness',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/feeling-lonely/',
        ),
      ],
    ),
  ];
  
  // ============================================
  // LIFE SITUATIONS ARTICLES
  // ============================================
  
  static const List<Article> lifeSituationArticles = [
    Article(
      id: 'relationship_breakdown',
      title: 'When Relationships End',
      summary: 'Navigating the pain of relationship breakdown and finding your way forward.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      ageBrackets: ['25-34', '35-44', '45-54'],
      sections: [
        ArticleSection(
          content: 'The end of a significant relationship is one of life\'s most painful experiences. Whether it was your choice or not, grief is normal. You\'re mourning not just the person, but the future you imagined together.',
        ),
        ArticleSection(
          heading: 'What You Might Feel',
          content: 'It\'s normal to experience:\n\n• Waves of intense emotion\n• Difficulty concentrating\n• Changes in appetite or sleep\n• Questioning yourself\n• Relief mixed with sadness\n• Anger and frustration\n\nAll of these are part of processing loss.',
        ),
        ArticleSection(
          heading: 'The Non-Linear Path',
          content: 'Healing isn\'t a straight line. You might feel better for a while, then struggle again. This is completely normal. Progress isn\'t about never feeling bad - it\'s about the overall trend over time.',
          tip: 'Be patient with yourself. Most people underestimate how long relationship grief takes.',
        ),
        ArticleSection(
          heading: 'Moving Forward',
          content: 'Helpful approaches:\n\n• Allow yourself to feel without judgement\n• Maintain routines where possible\n• Stay connected to supportive people\n• Avoid major decisions during acute grief\n• Focus on basic self-care\n\nThis is a marathon, not a sprint.',
        ),
      ],
      keyTakeaways: [
        'Grieving a relationship is normal and necessary',
        'Healing is not linear - expect ups and downs',
        'Your feelings are valid even if the relationship needed to end',
        'Basic self-care becomes especially important during this time',
      ],
    ),
    
    Article(
      id: 'financial_stress',
      title: 'Dealing with Financial Pressure',
      summary: 'Managing the mental weight of money worries.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 4,
      ageBrackets: ['18-24', '25-34', '35-44', '45-54', '55+'],
      sections: [
        ArticleSection(
          content: 'Financial stress is one of the most common sources of anxiety. Money worries affect sleep, relationships, and mental health. If you\'re struggling financially, know that you\'re not alone and it doesn\'t define your worth.',
        ),
        ArticleSection(
          heading: 'Breaking the Avoidance Cycle',
          content: 'When finances feel overwhelming, it\'s tempting to avoid looking at them. But avoidance usually makes anxiety worse. Getting a clear picture - however uncomfortable - is the first step to regaining control.',
          tip: 'Set a specific time to look at your finances. Having a designated "worry time" can prevent money stress from taking over every moment.',
        ),
        ArticleSection(
          heading: 'One Step at a Time',
          content: 'Focus on what you can control:\n\n• Know your numbers (income vs expenses)\n• Identify one area to address first\n• Seek advice if you need it (free services exist)\n• Separate "essential" from "wanted"\n\nSmall steps add up over time.',
        ),
        ArticleSection(
          heading: 'Your Worth Is Not Your Net Worth',
          content: 'Financial difficulties do not make you a failure. Circumstances, systems, and life events affect finances. Many successful people have faced financial hardship. What matters is how you respond.',
        ),
      ],
      keyTakeaways: [
        'Financial stress is extremely common - you\'re not alone',
        'Avoiding your finances usually makes anxiety worse',
        'Focus on small, actionable steps rather than the whole picture',
        'Your value as a person is not tied to your financial situation',
      ],
    ),
    
    Article(
      id: 'isolation_deployment',
      title: 'Staying Connected When Isolated',
      summary: 'Maintaining mental wellbeing during extended periods away from loved ones.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 4,
      ageBrackets: ['18-24', '25-34', '35-44'],
      sections: [
        ArticleSection(
          content: 'Extended time away from family, friends, and normal life takes a psychological toll. Whether due to work deployment, remote assignments, or other circumstances, isolation challenges our mental health in unique ways.',
        ),
        ArticleSection(
          heading: 'The Impact of Isolation',
          content: 'Isolation can lead to:\n\n• Rumination (overthinking)\n• Low mood\n• Sleep disruption\n• Loss of motivation\n• Relationship strain (despite wanting connection)\n\nRecognising these as normal responses helps.',
        ),
        ArticleSection(
          heading: 'Building Routine',
          content: 'Structure becomes even more important when you\'re isolated. Create anchors in your day:\n\n• Consistent wake and sleep times\n• Regular physical activity\n• Designated work and rest periods\n• Something to look forward to each day',
          tip: 'Even small rituals - a morning routine, an evening wind-down - provide psychological stability.',
        ),
        ArticleSection(
          heading: 'Maintaining Connections',
          content: 'Connection doesn\'t require physical presence:\n\n• Keep a journal of things to share later\n• Look at photos that remind you of home\n• Establish mental "check-in" times when you think of loved ones\n• Focus on quality of limited contact, not quantity',
        ),
      ],
      keyTakeaways: [
        'Isolation affects mood and thinking - this is normal',
        'Routine and structure provide psychological stability',
        'Connection can be maintained even without regular contact',
        'This period is temporary - focus on one day at a time',
      ],
    ),
    
    Article(
      id: 'starting_career',
      title: 'Finding Your Way in Early Career',
      summary: 'Navigating uncertainty and pressure when you\'re just starting out.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 4,
      ageBrackets: ['18-24', '25-34'],
      sections: [
        ArticleSection(
          content: 'The early years of your career can feel overwhelming. Pressure to succeed, uncertainty about the right path, comparison to others - it\'s a lot to manage while also learning new skills and finding your place.',
        ),
        ArticleSection(
          heading: 'The Comparison Trap',
          content: 'Social media makes it easy to compare your beginning to someone else\'s middle. Remember: you\'re seeing highlight reels, not full pictures. Everyone struggles; most just don\'t advertise it.',
          tip: 'When you catch yourself comparing, ask: "Do I actually know their full story?"',
        ),
        ArticleSection(
          heading: 'Uncertainty Is Normal',
          content: 'Not knowing exactly what you want to do is completely normal at this stage. Very few people have it all figured out in their twenties. Your path doesn\'t need to be linear or certain.',
        ),
        ArticleSection(
          heading: 'Building Foundations',
          content: 'Focus on:\n\n• Learning from every experience (even bad ones)\n• Building relationships and reputation\n• Developing transferable skills\n• Taking care of your mental health now\n\nThese foundations serve you regardless of where your career goes.',
        ),
      ],
      keyTakeaways: [
        'Uncertainty in early career is normal, not a failure',
        'Comparison to others\' highlight reels is misleading',
        'Your path doesn\'t need to be figured out right away',
        'Investing in relationships and skills pays off long-term',
      ],
    ),

    Article(
      id: 'healthy_relationships',
      title: 'Building Healthy Relationships',
      summary: 'What healthy relationships look like, and simple ways to strengthen yours.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Good relationships with partners, friends and family are one of the most important things for your mental health. Healthy relationships don't just happen. They take effort from everyone involved.",
        ),
        ArticleSection(
          heading: 'Signs of a Healthy Relationship',
          content: "You can often tell a relationship is healthy by how it makes you feel:\n\n• You feel safe, and your boundaries are respected\n• Differences are expected and can be talked about openly\n• You can be yourself without hiding parts of who you are\n• You can say how you feel without the other person having to guess\n\nRespect, honesty, trust and good communication are the foundations.",
        ),
        ArticleSection(
          heading: 'Know Yourself First',
          content: "Understanding your own feelings makes it easier to explain them to someone else. If you struggle to name or manage your emotions, that can spill over into your relationships.\n\nAnger, for example, often sits on top of hurt or upset. Recognising that, and saying it, can bring you closer rather than pushing people away.",
        ),
        ArticleSection(
          heading: 'Set and Respect Boundaries',
          content: "Boundaries aren't only about what you don't want. They're also about telling people what you value. Let others know your limits, like needing time to yourself after a long shift. Clear boundaries take the pressure off trying to meet expectations nobody can live up to.",
        ),
        ArticleSection(
          heading: 'Talk and Listen',
          content: "Disagreements happen in every relationship. What matters is how you talk to each other.\n\n• Raise small issues early, before they build up\n• Use \"I\" statements: \"When X happens, I feel Y\"\n• Pick a good time to talk, not in the middle of something else\n• Listen to understand, not to plan your reply\n• Repeat back what you heard so they know you've got it",
          tip: "Talking while walking or driving side by side can make difficult conversations feel less intense.",
        ),
        ArticleSection(
          heading: 'Let Go of Control',
          content: "You can only control your own actions, not anyone else's. Accepting that saves a lot of energy and stress. Think about which of your relationships work best, what makes them work, and how you could bring more of that into others.",
        ),
      ],
      keyTakeaways: [
        'Healthy relationships are built on respect, honesty and trust',
        'Boundaries tell people what you need and what you value',
        'Listening to understand matters more than winning the point',
        'Good communication is a skill that improves with practice',
      ],
      sources: [
        ArticleSource(
          name: 'Mental Health Foundation: Top tips on building and maintaining healthy relationships',
          url: 'https://www.mentalhealth.org.uk/our-work/public-engagement/healthy-relationships/top-tips-building-and-maintaining-healthy-relationships',
        ),
        ArticleSource(
          name: 'Relate: Five communication hacks for a happy relationship',
          url: 'https://www.relate.org.uk/get-help/five-communication-hacks-happy-relationship',
        ),
      ],
    ),

    Article(
      id: 'arguments_with_partner',
      title: 'When Arguments Keep Happening',
      summary: 'How to stop arguments with a partner escalating, and what to do afterwards.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Every couple disagrees. Arguing isn't a sign your relationship is failing, but if the same arguments keep happening or keep getting heated, it's worth looking at how you handle them.",
        ),
        ArticleSection(
          heading: 'Stop It Heating Up',
          content: "Some ways of talking almost guarantee a row:\n\n• Accusations like \"You don't care\" put people on the defensive\n• Words like \"always\" and \"never\" exaggerate the problem\n• Bringing up old arguments drags you off topic\n\nTry describing your own experience instead: \"I feel left out when plans change last minute.\" Stick to one issue at a time.",
        ),
        ArticleSection(
          heading: 'Know When to Step Back',
          content: "If things are escalating, take a break. Walking away can feel like losing, but it puts the relationship ahead of being right. Say briefly why you're stopping and when you'd like to pick it up again.\n\nWatch for signs in your body, like a racing heart or clenched jaw. They're a cue to pause.",
          tip: "Slow, deep breaths help calm your body down before you go back to the conversation.",
        ),
        ArticleSection(
          heading: "What's It Really About?",
          content: "The thing you're arguing about is often not the real issue. A row about someone always being late might really be about feeling disrespected or unheard. If you're far angrier than the situation seems to deserve, there's probably something bigger underneath. Talking about that can help you both.",
        ),
        ArticleSection(
          heading: 'Agree Some Ground Rules',
          content: "When you're both calm, agree how you'll handle disagreements:\n\n• Listen to each other and look for compromise\n• No shouting or name-calling\n• Don't argue in front of the children\n• Agree a signal for taking a break\n• Once it's resolved, let it go and start fresh",
        ),
        ArticleSection(
          heading: 'When It Is More Than Arguing',
          content: "If one partner regularly starts conflict and then blames the other for it, or you feel afraid, controlled or put down, that is not a normal disagreement. It may be abuse. See \"Recognising an Unhealthy Relationship\" for signs and where to get help.\n\nIf you'd like help as a couple, Relate offers relationship counselling in person, by phone and online.",
        ),
      ],
      keyTakeaways: [
        'Disagreeing is normal. How you argue is what matters',
        'Swap blame for "I feel" statements and avoid "always" and "never"',
        'Taking a break is not giving up',
        'Look for what the argument is really about',
      ],
      sources: [
        ArticleSource(
          name: 'Relate: How to de-escalate an argument',
          url: 'https://www.relate.org.uk/get-help/how-de-escalate-argument',
        ),
        ArticleSource(
          name: 'Action for Children: How to manage arguments with your partner',
          url: 'https://parents.actionforchildren.org.uk/home-family-life/family-relationships/arguing-partner/',
        ),
      ],
    ),

    Article(
      id: 'family_relationships',
      title: 'Difficult Family Relationships',
      summary: 'Handling tension with parents, siblings and wider family, including when you drift apart.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 6,
      sections: [
        ArticleSection(
          content: "Family relationships can be some of the most rewarding and the most difficult we have. Tension can come from old childhood experiences, different values, caring responsibilities, or simply different generations seeing the world differently.\n\nYou can't control how your family behaves. You can choose how you respond.",
        ),
        ArticleSection(
          heading: 'Before a Difficult Conversation',
          content: "• Decide what you want from it. To feel heard? To set a boundary? To rebuild trust?\n• Calm yourself first with a walk, some slow breathing or writing things down\n• Choose a quiet moment when nobody is rushed\n• Doing something together, like cooking or walking, can make talking easier\n• If speaking feels too much, write a letter or message instead",
        ),
        ArticleSection(
          heading: 'During the Conversation',
          content: "• Use \"I\" statements to explain how something affects you\n• Ask questions and repeat back what you've heard\n• Acknowledge their point of view, even if you disagree\n• Look for middle ground without giving up your values\n• It doesn't have to be fixed in one go. It's fine to pause and come back to it",
          tip: "Older relatives may not be used to talking about feelings or mental health. A brisk response is often unfamiliarity rather than not caring.",
        ),
        ArticleSection(
          heading: 'Setting Boundaries',
          content: "It's okay to protect your own wellbeing. That might mean agreeing time to yourself, not going to every family event, or deciding how much you talk about a situation. Building a support network outside the family, like friends or colleagues you trust, helps too.",
        ),
        ArticleSection(
          heading: 'When Family Drifts Apart',
          content: "Estrangement from family can feel a lot like grief. It helps to:\n\n• Name the feelings, whether that's sadness, anger or relief\n• Lean on friends, support groups or a counsellor\n• Create your own traditions for birthdays and holidays\n• Take reconciliation slowly, if you want it. Think about what has changed and whether it would be good for you",
        ),
        ArticleSection(
          heading: 'When It Is Not Safe',
          content: "Constant conflict, bullying, guilt-tripping or any physical, emotional or sexual abuse is never okay, and it is unlikely to stop on its own. Abuse can come from any family member, not just a partner. If you're in immediate danger, call 999. See \"Recognising an Unhealthy Relationship\" for helplines.",
        ),
      ],
      keyTakeaways: [
        'You can only control your own response, not your family',
        'Know what you want from a conversation before you start',
        'Boundaries protect your wellbeing and are okay to set',
        'Abuse from any family member is never acceptable',
      ],
      sources: [
        ArticleSource(
          name: 'Family Action: Navigating difficult family relationships',
          url: 'https://family-action.org.uk/self-help/navigating-difficult-family-relationships/',
        ),
        ArticleSource(
          name: 'YoungMinds: Family problems',
          url: 'https://www.youngminds.org.uk/young-person/coping-with-life/family/',
        ),
        ArticleSource(
          name: 'NHS: Getting help for domestic violence and abuse',
          url: 'https://www.nhs.uk/live-well/getting-help-for-domestic-violence/',
        ),
      ],
    ),

    Article(
      id: 'unhealthy_relationships',
      title: 'Recognising an Unhealthy Relationship',
      summary: 'The signs of domestic abuse, and where anyone can get confidential help.',
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Domestic abuse can happen between partners, ex-partners or family members. It can happen to anyone, of any gender or sexuality, and anyone can be an abuser. Abuse is always about power and control. It is never your fault.",
        ),
        ArticleSection(
          heading: 'Signs to Look For',
          content: "Ask yourself whether someone close to you:\n\n• Puts you down, blames you or cuts you off from friends and family\n• Controls your money, or stops you working or studying\n• Checks your phone, tracks where you are or monitors you online\n• Threatens to hurt you, the children, or themselves\n• Damages your belongings\n• Hits, pushes, chokes or throws things\n• Pressures you into sex or sexual acts\n\nIf you've ever felt afraid of them, or changed how you behave to avoid upsetting them, that's a warning sign too. Something not on this list can still be abuse.",
        ),
        ArticleSection(
          heading: 'Getting Help',
          content: "If you're in immediate danger, call 999. You don't have to wait for an emergency to tell someone. Your GP can help, and these services are free and confidential:\n\n• National Domestic Abuse Helpline: 0808 2000 247 (24 hours)\n• Men's Advice Line: 0808 8010 327\n• Galop (LGBT+): 0800 999 5428\n• Respect Phoneline, if you're worried about your own behaviour: 0808 802 4040",
          tip: "Be careful who you tell if you're planning to leave. Get advice from a helpline first so you can leave safely.",
        ),
        ArticleSection(
          heading: "If You're Worried About Someone",
          content: "• Find a quiet, safe time and let them know you've noticed something\n• Listen without judging, and let them go at their own pace\n• Tell them nobody deserves to be hurt or threatened\n• Respect their choices. Don't push them to leave before they're ready\n• Offer to go with them to a GP or hospital if they've been hurt\n• Share the helpline details above",
        ),
      ],
      keyTakeaways: [
        'Abuse can be emotional, financial, physical or sexual',
        'It can happen to anyone, and it is never the victim\'s fault',
        'Free, confidential helplines exist for women, men and LGBT+ people',
        'If you are in immediate danger, call 999',
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Getting help for domestic violence and abuse',
          url: 'https://www.nhs.uk/live-well/getting-help-for-domestic-violence/',
        ),
      ],
    ),

    Article(
      id: 'grief_and_loss',
      title: 'Grief and Loss',
      summary: "Grief isn't only about death. Understanding what's normal and when to reach out.",
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Grief is what we feel when we lose something or someone important. That could be a death, but it can also be the end of a relationship, losing a job, leaving a career or moving away from home.",
        ),
        ArticleSection(
          heading: 'What Grief Can Feel Like',
          content: "• Shock or numbness, like being in a daze\n• Overwhelming sadness and lots of crying\n• Exhaustion\n• Anger, at the person, the situation or yourself\n• Guilt about things said or not said, or that you couldn't stop it\n\nThese feelings can come and go, and hit you when you least expect it.",
        ),
        ArticleSection(
          heading: 'It Rarely Goes in Order',
          content: "People often talk about stages of grief: denial, anger, bargaining (\"if only...\"), depression and acceptance. In reality you may not feel all of them, and they rarely come in a neat order. Acceptance doesn't mean you're okay with what happened. It means you're ready to move forward.\n\nGrief can feel chaotic, but for most people it becomes less intense over time.",
        ),
        ArticleSection(
          heading: 'Things That Help',
          content: "• Talk about how you feel with someone you trust\n• Connect with others who have been through a similar loss\n• Keep moving. Regular exercise helps mood and sleep\n• Eat regular meals to keep your energy up\n• Set small goals rather than trying to do everything\n• Avoid using alcohol or drugs to numb the pain",
          tip: "Cruse Bereavement Support (cruse.org.uk) offers free information and support for anyone who is grieving.",
        ),
        ArticleSection(
          heading: 'When to Get Help',
          content: "Sadness after a loss should slowly ease. See a GP if you feel more and more low or anxious, your mood has been low for more than two weeks, or you can't get back to everyday life.\n\nFor some people, especially after a sudden or traumatic death, grief doesn't ease for months or years. This is called prolonged grief, and support is available.",
        ),
      ],
      keyTakeaways: [
        'Grief can follow any big loss, not only a death',
        "There's no right order or timetable for grieving",
        'Talking, routine and looking after your body all help',
        "If grief isn't easing over time, speak to a GP",
      ],
      sources: [
        ArticleSource(
          name: 'NHS: Grief after bereavement or loss',
          url: 'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/feelings-and-symptoms/grief-bereavement-loss/',
        ),
      ],
    ),

    Article(
      id: 'supporting_someone',
      title: 'Supporting Someone Who Is Struggling',
      summary: "How to help a partner, family member or mate who isn't okay, and look after yourself too.",
      category: ArticleCategory.lifeSituation,
      readTimeMinutes: 5,
      sections: [
        ArticleSection(
          content: "Often the people closest to us are the first to notice when something has changed. You don't need to be an expert or know what's wrong to help. Responding with care is what matters most.",
        ),
        ArticleSection(
          heading: 'Starting the Conversation',
          content: "• Find a time and place without distractions\n• Let them lead and share as much or as little as they want\n• Ask open questions like \"How are you really doing?\"\n• Don't ask too many questions at once\n• Listen carefully and repeat back what you heard\n• Don't try to diagnose them or tell them how they feel",
          tip: "If they don't want to talk, try not to take it personally. Let them know you care and that you're there when they're ready.",
        ),
        ArticleSection(
          heading: 'Practical Help',
          content: "• Ask what helps them. Sleep, exercise and eating well all make a difference\n• Offer to help them find support, like going with them to the GP\n• Let them make their own decisions\n• Help them build a wider support network so it isn't all on you",
        ),
        ArticleSection(
          heading: 'If They Are in Crisis',
          content: "Stay calm and listen without judging. Ask what would help right now and whether there's someone they'd like you to call.\n\nIf they talk about wanting to end their life, encourage them to contact a GP, NHS 111 or Samaritans (116 123). If they have a plan or are in immediate danger, call 999 or help them get to A&E. If they have hurt themselves, make sure they get first aid.",
        ),
        ArticleSection(
          heading: 'Look After Yourself',
          content: "Supporting someone can be draining. Know your limits, and get support for yourself too. Mind's Infoline (0300 123 3393) can help with information for friends and family.",
        ),
      ],
      keyTakeaways: [
        "You don't need to be an expert to help",
        'Listen more than you talk, and let them lead',
        'Help them find professional support, but let them decide',
        'If someone is in immediate danger, call 999',
      ],
      sources: [
        ArticleSource(
          name: 'Mental Health Foundation: How to support someone with a mental health problem',
          url: 'https://www.mentalhealth.org.uk/explore-mental-health/articles/how-support-someone-mental-health-problem',
        ),
        ArticleSource(
          name: 'NHS: Where to get urgent help for mental health',
          url: 'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/',
        ),
      ],
    ),
  ];
}



