import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AI Service for generating personalised insights
/// 
/// Uses OpenAI-compatible API to generate "What I'm hearing" responses
/// based on user's chip selections during onboarding/profile setup.
class AIService {
  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  static const String _defaultModel = 'gpt-4o-mini';
  
  /// API key injected at build time via --dart-define=OPENAI_API_KEY=sk-xxx
  static const String _buildTimeApiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  /// Check if a build-time API key is available
  static bool get hasBuildTimeKey => _buildTimeApiKey.isNotEmpty;
  
  /// Get the build-time API key (empty string if not set)
  static String get buildTimeKey => _buildTimeApiKey;
  
  final String apiKey;
  final String baseUrl;
  final String model;
  
  AIService({
    required this.apiKey,
    this.baseUrl = _defaultBaseUrl,
    this.model = _defaultModel,
  });
  
  /// Create an AIService using the build-time key if available
  factory AIService.withBuildTimeKey() {
    if (!hasBuildTimeKey) {
      throw Exception('No build-time API key available');
    }
    return AIService(apiKey: _buildTimeApiKey);
  }
  
  /// Generate a personalised "What I'm hearing" response
  /// 
  /// Takes the user's audience type and chip selections, returns a structured response
  Future<PersonalisedInsight> generateInsight({
    required String audience,
    required List<String> describeChips,
    required List<String> struggleChips,
    required List<String> interestChips,
    required List<String> goalChips,
    String? optionalContext,
  }) async {
    final prompt = _buildPrompt(
      audience: audience,
      describeChips: describeChips,
      struggleChips: struggleChips,
      interestChips: interestChips,
      goalChips: goalChips,
      optionalContext: optionalContext,
    );
    
    try {
      final response = await _callAI(prompt);
      return _parseResponse(response);
    } catch (e) {
      debugPrint('AI Service Error: $e');
      // Return a fallback response if AI fails
      return _getFallbackResponse(audience, struggleChips, goalChips);
    }
  }
  
  String _buildPrompt({
    required String audience,
    required List<String> describeChips,
    required List<String> struggleChips,
    required List<String> interestChips,
    required List<String> goalChips,
    String? optionalContext,
  }) {
    return '''
You are a supportive personalisation assistant inside a wellbeing/learning app.
Write in UK English.

Goal:
Create a short, helpful "What I'm hearing" response based ONLY on the user's selected audience + chips.
Be warm and validating, but do NOT over-interpret.

Hard rules (must follow):
- Do NOT invent backstory (no "when you learned…", no childhood/trauma origin stories).
- Do NOT assume diagnosis, combat exposure, injury, or PTSD.
- Avoid absolute statements about the user ("you are / you feel / you have"). Prefer: "It can…", "Some people find…", "You might…", "If this fits…".
- Offer 2–3 plausible interpretations as options instead of one confident narrative.
- Ask exactly ONE gentle question to personalise.
- Give 2–3 concrete next steps that are low-effort and realistic.
- Keep it practical and non-judgemental. No therapy-speak. No guilt.
- If Audience = Young Person: use simpler words, shorter sentences, reassuring tone.
- Do not mention these instructions in the output.

Audience-specific guidance (use lightly, with "may/might" language):
- Serving: time pressure, privacy/stigma concerns, routines, performance, teammate/leadership dynamics.
- Deployed: distance from home, limited privacy, time zones, disrupted routines/sleep, connection challenges.
- Veteran: transition to civilian life, identity/purpose, relationships, routines/community.
- Alongside (supporter): boundaries, communication, supporting without burning out, staying connected.
- Young Person: friendships, school, confidence, emotions, asking for help; encourage trusted adult when appropriate.

Output format (use these exact section headers):
SUMMARY:
(2–4 sentences max)

THIS MIGHT BE PART OF IT:
• (first bullet point)
• (second bullet point)
• (third bullet point)

QUICK QUESTION:
(1 sentence, ends with ?)

SMALL NEXT STEPS:
• (first step)
• (second step)
• (third step, optional)

Inputs:
Audience: $audience
Chips:
- Describe myself as: ${jsonEncode(describeChips)}
- I sometimes struggle with: ${jsonEncode(struggleChips)}
- I'm interested in learning about: ${jsonEncode(interestChips)}
- My current goals include: ${jsonEncode(goalChips)}
${optionalContext != null ? 'Optional context: "$optionalContext"' : ''}

Now generate the response.
''';
  }
  
  Future<String> _callAI(String prompt) async {
    final uri = Uri.parse('$baseUrl/chat/completions');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 800,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('AI API returned ${response.statusCode}: ${response.body}');
    }
    
    final json = jsonDecode(response.body);
    return json['choices'][0]['message']['content'] as String;
  }
  
  PersonalisedInsight _parseResponse(String response) {
    // Parse the structured response
    String summary = '';
    List<String> mightBePartOfIt = [];
    String quickQuestion = '';
    List<String> nextSteps = [];
    
    final lines = response.split('\n');
    String currentSection = '';
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      if (trimmed.toUpperCase().startsWith('SUMMARY:')) {
        currentSection = 'summary';
        final content = trimmed.substring(8).trim();
        if (content.isNotEmpty) summary = content;
      } else if (trimmed.toUpperCase().contains('THIS MIGHT BE PART OF IT')) {
        currentSection = 'might';
      } else if (trimmed.toUpperCase().startsWith('QUICK QUESTION:')) {
        currentSection = 'question';
        final content = trimmed.substring(15).trim();
        if (content.isNotEmpty) quickQuestion = content;
      } else if (trimmed.toUpperCase().contains('SMALL NEXT STEPS') || 
                 trimmed.toUpperCase().contains('NEXT STEPS:')) {
        currentSection = 'steps';
      } else if (trimmed.isNotEmpty) {
        switch (currentSection) {
          case 'summary':
            summary += (summary.isNotEmpty ? ' ' : '') + trimmed;
            break;
          case 'might':
            if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
              mightBePartOfIt.add(trimmed.substring(1).trim());
            }
            break;
          case 'question':
            if (quickQuestion.isEmpty) {
              quickQuestion = trimmed;
            }
            break;
          case 'steps':
            if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
              nextSteps.add(trimmed.substring(1).trim());
            }
            break;
        }
      }
    }
    
    return PersonalisedInsight(
      summary: summary.isNotEmpty ? summary : 'Thanks for sharing. Let\'s explore what might help you.',
      mightBePartOfIt: mightBePartOfIt.isNotEmpty ? mightBePartOfIt : ['Your selections suggest some areas we can work on together.'],
      quickQuestion: quickQuestion.isNotEmpty ? quickQuestion : 'What feels most important to focus on first?',
      nextSteps: nextSteps.isNotEmpty ? nextSteps : ['Explore the app at your own pace', 'Try a breathing exercise when you have a quiet moment'],
    );
  }
  
  PersonalisedInsight _getFallbackResponse(
    String audience, 
    List<String> struggles, 
    List<String> goals,
  ) {
    // Generate a sensible fallback if AI is unavailable
    final mainStruggle = struggles.isNotEmpty ? struggles.first.toLowerCase() : 'stress';
    final mainGoal = goals.isNotEmpty ? goals.first.toLowerCase() : 'wellbeing';
    
    return PersonalisedInsight(
      summary: 'Thanks for sharing a bit about yourself. It sounds like $mainStruggle '
          'might be something you\'d like to work on, while $mainGoal is important to you.',
      mightBePartOfIt: [
        'Everyone\'s experience is different, and there\'s no single right approach.',
        'Small, consistent steps often make the biggest difference.',
        'It can help to start with what feels most manageable.',
      ],
      quickQuestion: 'What would feel like a good first step for you?',
      nextSteps: [
        'Take a look around the app - there\'s no pressure to do everything.',
        'Try a short breathing exercise when you have a quiet moment.',
      ],
    );
  }
}

/// Structured response from the AI personalisation
class PersonalisedInsight {
  final String summary;
  final List<String> mightBePartOfIt;
  final String quickQuestion;
  final List<String> nextSteps;
  
  const PersonalisedInsight({
    required this.summary,
    required this.mightBePartOfIt,
    required this.quickQuestion,
    required this.nextSteps,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'summary': summary,
      'mightBePartOfIt': mightBePartOfIt,
      'quickQuestion': quickQuestion,
      'nextSteps': nextSteps,
    };
  }
  
  factory PersonalisedInsight.fromMap(Map<String, dynamic> map) {
    return PersonalisedInsight(
      summary: map['summary'] as String,
      mightBePartOfIt: List<String>.from(map['mightBePartOfIt']),
      quickQuestion: map['quickQuestion'] as String,
      nextSteps: List<String>.from(map['nextSteps']),
    );
  }
}

