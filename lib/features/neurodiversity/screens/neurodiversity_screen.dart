import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/widgets/guidance_widgets.dart';

/// Neurodiversity: autism, ADHD, dyslexia and other specific learning
/// difficulties (SpLDs).
///
/// Content is written in the app's own words and based on NHS pages, with
/// the British Dyslexia Association and GOV.UK for SpLD and workplace
/// support. Every card links to its source.
class NeurodiversityScreen extends StatefulWidget {
  const NeurodiversityScreen({super.key});

  @override
  State<NeurodiversityScreen> createState() => _NeurodiversityScreenState();
}

// ─── Sources ────────────────────────────────────────────────────────────────

const _nhsWhatIsAutism = GuidanceSource('NHS: what is autism',
    'https://www.nhs.uk/conditions/autism/what-is-autism/');
const _nhsAutismAdults = GuidanceSource('NHS: signs of autism in adults',
    'https://www.nhs.uk/conditions/autism/signs-in-adults/');
const _nhsAutismAssessment = GuidanceSource('NHS: autism assessments',
    'https://www.nhs.uk/conditions/autism/assessments/');
const _nhsAdhdAdults =
    GuidanceSource('NHS: ADHD in adults', 'https://www.nhs.uk/conditions/adhd-adults/');
const _nhsDyslexiaAdults = GuidanceSource('NHS: dyslexia in adults',
    'https://www.nhs.uk/conditions/dyslexia-in-adults/');
const _nhsDyslexia =
    GuidanceSource('NHS: dyslexia', 'https://www.nhs.uk/conditions/dyslexia/');
const _nhsDyspraxiaAdults = GuidanceSource('NHS: dyspraxia in adults',
    'https://www.nhs.uk/conditions/developmental-coordination-disorder-dyspraxia-in-adults/');
const _nhsLearningDisability = GuidanceSource('NHS: learning disabilities',
    'https://www.nhs.uk/conditions/learning-disabilities/');
const _bdaNeurodiversity = GuidanceSource('British Dyslexia Association: neurodiversity',
    'https://www.bdadyslexia.org.uk/dyslexia/neurodiversity-and-co-occurring-differences');
const _bdaDyscalculia = GuidanceSource('British Dyslexia Association: dyscalculia',
    'https://www.bdadyslexia.org.uk/dyscalculia');
const _govAccessToWork =
    GuidanceSource('GOV.UK: Access to Work', 'https://www.gov.uk/access-to-work');

// ─── Overview ───────────────────────────────────────────────────────────────

const _overview = <GuidanceSection>[
  GuidanceSection(
    title: 'What does neurodiversity mean?',
    icon: Icons.diversity_2_rounded,
    intro:
        'Neurodiversity is the idea that brains work in different ways, and that these differences should be recognised and respected like any other human difference. Someone whose brain works differently from most people may describe themselves as neurodivergent.',
    points: [
      'Autism and ADHD are often described as types of neurodivergence.',
      'Specific learning difficulties (SpLDs), such as dyslexia, dyspraxia and dyscalculia, are also part of neurodiversity.',
      'These conditions often overlap. For example, ADHD is more common in autistic people, and dyspraxia often occurs alongside ADHD, dyslexia or autism.',
    ],
    sources: [_bdaNeurodiversity, _nhsWhatIsAutism, _nhsDyspraxiaAdults],
  ),
  GuidanceSection(
    title: 'Learning difficulty or learning disability?',
    icon: Icons.compare_arrows_rounded,
    intro: 'These terms sound alike but mean different things.',
    points: [
      'A specific learning difficulty, such as dyslexia, affects particular skills like reading, writing or working with numbers. It does not affect intelligence.',
      'A learning disability affects the way a person learns new things throughout their life, and can affect understanding complicated information or looking after yourself. Many people with a learning disability work, have relationships and live independently.',
      'Some autistic people have a learning disability, and many do not.',
    ],
    sources: [_nhsDyslexia, _nhsLearningDisability, _nhsWhatIsAutism],
  ),
  GuidanceSection(
    title: 'Not an illness',
    icon: Icons.lightbulb_outline_rounded,
    intro:
        'Autism is not an illness. It is something you are born with, and so is dyspraxia. Dyslexia is a difference in how your brain works and does not affect intelligence. There is no cure for these conditions, but there are ways to manage the difficulties and get support.',
    sources: [_nhsWhatIsAutism, _nhsDyspraxiaAdults, _nhsDyslexia],
  ),
  GuidanceSection(
    title: 'Neurodiversity and mental health',
    icon: Icons.favorite_border_rounded,
    intro:
        'People with ADHD, autism or dyspraxia are more likely to have mental health problems such as anxiety and depression. ADHD is also linked to a higher risk of suicide.',
    points: [
      'If you feel like ending your life, tell someone and get help straight away.',
      'See the Suicide Awareness section of this app, or call Samaritans free on 116 123.',
    ],
    sources: [_nhsAdhdAdults, _nhsAutismAdults, _nhsDyspraxiaAdults],
  ),
];

// ─── Autism ─────────────────────────────────────────────────────────────────

const _autism = <GuidanceSection>[
  GuidanceSection(
    title: 'What is autism?',
    icon: Icons.all_inclusive_rounded,
    intro:
        'Autism is a difference in how your brain develops. It can change how you communicate, learn and pay attention, and how you react to things like light, sound, smell, taste and touch. The medical name for a diagnosis is autism spectrum disorder (ASD).',
    sources: [_nhsWhatIsAutism],
  ),
  GuidanceSection(
    title: 'Common signs in adults',
    icon: Icons.person_search_outlined,
    points: [
      'Finding it hard to talk with other people, or preferring to spend time alone.',
      'Finding it hard to read facial expressions, gestures or tone of voice.',
      'Taking things literally, for example not understanding some sayings or figures of speech.',
      'Having fixed routines and getting upset if they change.',
      'Repetitive movements, sometimes called stimming.',
      'A very strong interest in particular subjects.',
      'Being very sensitive, or not sensitive enough, to light, sound, smell, taste or texture.',
    ],
    sources: [_nhsAutismAdults],
  ),
  GuidanceSection(
    title: 'Masking',
    icon: Icons.theater_comedy_outlined,
    intro:
        'Many autistic adults have learned to adapt so that the signs are not always noticeable. This is called masking. It can make autism harder to spot, especially in women, who may copy how others behave, seem to cope well socially, and hide their feelings. Men can mask too.',
    sources: [_nhsAutismAdults],
  ),
  GuidanceSection(
    title: 'Getting assessed as an adult',
    icon: Icons.assignment_ind_outlined,
    points: [
      'Speak to your GP. They can usually refer you to a local autism team.',
      'A mental health professional may also suggest an assessment if they notice signs.',
      'Waits can be months or longer. Ask your GP what support you can get in the meantime.',
      'In England, the Right to Choose scheme may let you pick an NHS service with a shorter wait.',
      'The assessment may include questionnaires and questions about your early life, relationships, home and work. The team may also speak to someone who knows you well.',
      'Afterwards you get a report covering whether you are autistic, your strengths and any support needs.',
    ],
    sources: [_nhsAutismAssessment],
  ),
];

// ─── ADHD ───────────────────────────────────────────────────────────────────

const _adhd = <GuidanceSection>[
  GuidanceSection(
    title: 'What is ADHD?',
    icon: Icons.bolt_rounded,
    intro:
        'Attention deficit hyperactivity disorder (ADHD) affects attention, energy levels and impulse control. Most people have signs of both types below, but some have only one. Signs usually start before age 12. ADHD is often missed in women, because inattentive signs can be harder to spot.',
    sources: [_nhsAdhdAdults],
  ),
  GuidanceSection(
    title: 'Inattention',
    icon: Icons.blur_on_rounded,
    points: [
      'Being easily distracted or forgetful.',
      'Finding it hard to manage your time.',
      'Struggling to follow instructions or finish tasks.',
      'Often losing things.',
    ],
    sources: [_nhsAdhdAdults],
  ),
  GuidanceSection(
    title: 'Hyperactivity and impulsiveness',
    icon: Icons.directions_run_rounded,
    points: [
      'Having lots of energy or feeling restless.',
      'Talking a lot or interrupting people.',
      'Making quick decisions without thinking about the consequences.',
    ],
    sources: [_nhsAdhdAdults],
  ),
  GuidanceSection(
    title: 'Getting diagnosed as an adult',
    icon: Icons.assignment_ind_outlined,
    points: [
      'See your GP if the signs affect your work, studies or relationships. They will consider other possible causes too.',
      'Your GP may refer you to an ADHD specialist, such as a psychiatrist.',
      'The assessment looks at your symptoms, especially in childhood and at school, plus your work, family and health.',
      'Waits can be long. In England, the Right to Choose scheme may let you choose a clinic with a shorter wait.',
    ],
    sources: [_nhsAdhdAdults],
  ),
  GuidanceSection(
    title: 'Treatment and things that help',
    icon: Icons.tips_and_updates_outlined,
    points: [
      'Treatment can include lifestyle changes, changes at work, medicine and talking therapies such as CBT. Not everyone needs or wants medicine.',
      'Medicine must be started and monitored by an ADHD specialist.',
      'Regular exercise can help manage energy and ease anxiety and low mood.',
      'Keep a regular bedtime and cut down on screens, caffeine, sugar and alcohol before bed.',
      'Eat a balanced diet at regular times.',
      'Talk to friends and family about your ADHD.',
    ],
    footer:
        'You must tell the DVLA if your ADHD or your medicine affects your driving.',
    sources: [_nhsAdhdAdults],
  ),
];

// ─── Dyslexia and SpLDs ─────────────────────────────────────────────────────

const _spld = <GuidanceSection>[
  GuidanceSection(
    title: 'Dyslexia',
    icon: Icons.menu_book_rounded,
    intro:
        'Dyslexia is a common learning difficulty where your brain works differently to most people. It mainly affects reading and writing, and can also affect numbers and planning. It does not affect intelligence.',
    points: [
      'Making lots of spelling mistakes, or mixing up words that look similar.',
      'Needing to read things more than once.',
      'Getting tired quickly when reading or writing.',
      'Finding it hard to tell left from right.',
      'Difficulty managing time, or remembering dates and names.',
    ],
    footer:
        'Many people with dyslexia are strong in other areas but find some everyday tasks harder.',
    sources: [_nhsDyslexiaAdults, _nhsDyslexia],
  ),
  GuidanceSection(
    title: 'Getting assessed for dyslexia',
    icon: Icons.assignment_ind_outlined,
    points: [
      'A dyslexia assessment is not done by a medical doctor. It is usually done by an educational psychologist or a dyslexia specialist.',
      'You can arrange one through the British Dyslexia Association or a private service.',
      'Most people have to pay for a diagnostic assessment.',
    ],
    sources: [_nhsDyslexiaAdults],
  ),
  GuidanceSection(
    title: 'Dyspraxia (DCD)',
    icon: Icons.accessibility_new_rounded,
    intro:
        'Dyspraxia, also called developmental co-ordination disorder (DCD), mainly affects movement and co-ordination.',
    points: [
      'Clumsiness, bumping into things or dropping things.',
      'Finding fine tasks like typing or tying shoelaces hard.',
      'Difficulty with driving or sport.',
      'Finding it harder to learn new skills, remember information, or plan and organise your time.',
      'See your GP if it affects your life. They may refer you to a specialist such as an occupational therapist.',
      'Physiotherapy and occupational therapy can help.',
    ],
    sources: [_nhsDyspraxiaAdults],
  ),
  GuidanceSection(
    title: 'Dyscalculia',
    icon: Icons.calculate_outlined,
    intro:
        'Dyscalculia is a difficulty with understanding and working with numbers. It can affect things like ordering and comparing numbers, estimating, and place value. How much it affects someone varies from person to person and over their life.',
    sources: [_bdaDyscalculia],
  ),
];

// ─── Support ────────────────────────────────────────────────────────────────

const _support = <GuidanceSection>[
  GuidanceSection(
    title: 'Reasonable adjustments at work or college',
    icon: Icons.work_outline_rounded,
    intro:
        'Employers, colleges and universities can make changes, called reasonable adjustments, to help you. Telling them about your condition helps them know what support to offer. Examples include:',
    points: [
      'A quieter place to work.',
      'Written instructions as well as spoken ones.',
      'Help with planning and organising.',
      'Extra time for reading and tasks.',
      'Tools such as screen readers, or information in video format.',
    ],
    sources: [_nhsAdhdAdults, _nhsDyspraxiaAdults, _nhsDyslexiaAdults],
  ),
  GuidanceSection(
    title: 'Access to Work',
    icon: Icons.handshake_outlined,
    intro:
        'Access to Work is a government scheme that can pay for practical support at work, such as specialist equipment, help with travel costs, or mental health support.',
    sources: [_govAccessToWork, _nhsDyslexiaAdults, _nhsDyspraxiaAdults],
  ),
  GuidanceSection(
    title: 'Students',
    icon: Icons.school_outlined,
    intro:
        'If you are at college, university or on an apprenticeship, speak to a teacher or learning support officer. After a diagnostic assessment you may be able to apply for Disabled Students\' Allowance.',
    sources: [_nhsDyslexiaAdults, _nhsDyspraxiaAdults],
  ),
  GuidanceSection(
    title: 'Talking therapies',
    icon: Icons.forum_outlined,
    intro:
        'Talking therapies such as cognitive behavioural therapy (CBT) or mindfulness may be recommended for ADHD and dyspraxia, and can help with anxiety or low mood.',
    sources: [_nhsAdhdAdults, _nhsDyspraxiaAdults],
  ),
];

const _contacts = <GuidanceContact>[
  GuidanceContact(
    name: 'British Dyslexia Association',
    description: 'Information, assessments and advice on dyslexia and other SpLDs',
    display: 'bdadyslexia.org.uk',
    target: 'https://www.bdadyslexia.org.uk/',
    availability: 'Website',
    kind: ContactKind.web,
  ),
  GuidanceContact(
    name: 'ADHD UK',
    description: 'Information, a self-screening tool and support groups',
    display: 'adhduk.co.uk',
    target: 'https://adhduk.co.uk/',
    availability: 'Website',
    kind: ContactKind.web,
  ),
  GuidanceContact(
    name: 'ADHD Adult UK',
    description: 'Information and peer support for adults with ADHD',
    display: 'adhdadult.uk',
    target: 'https://www.adhdadult.uk/',
    availability: 'Website',
    kind: ContactKind.web,
  ),
  GuidanceContact(
    name: 'NHS: autism help and support',
    description: 'Where to find support for autistic people and their families',
    display: 'nhs.uk/conditions/autism',
    target: 'https://www.nhs.uk/conditions/autism/help-and-support/',
    availability: 'Website',
    kind: ContactKind.web,
  ),
  GuidanceContact(
    name: 'Access to Work',
    description: 'Government support to help you in work',
    display: 'gov.uk/access-to-work',
    target: 'https://www.gov.uk/access-to-work',
    availability: 'Website',
    kind: ContactKind.web,
  ),
  GuidanceContact(
    name: 'Samaritans',
    description: 'If you are struggling and need to talk to someone',
    display: '116 123',
    target: '116123',
    availability: '24 hours, every day',
  ),
];

// ─── Screen ─────────────────────────────────────────────────────────────────

class _NeurodiversityScreenState extends State<NeurodiversityScreen> {
  int _tab = 0;
  static const _tabs = ['Overview', 'Autism', 'ADHD', 'Dyslexia & SpLDs', 'Support'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GuidanceHeader(
              title: 'Neurodiversity',
              subtitle: 'Autism, ADHD, dyslexia and learning difficulties',
            ),
            GuidanceTabBar(
              tabs: _tabs,
              selected: _tab,
              onSelected: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [
                  _SectionList(sections: _overview),
                  _SectionList(sections: _autism),
                  _SectionList(sections: _adhd),
                  _SectionList(sections: _spld),
                  _SectionList(sections: _support, contacts: _contacts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  final List<GuidanceSection> sections;
  final List<GuidanceContact> contacts;
  const _SectionList({required this.sections, this.contacts = const []});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        ...sections.map((s) => GuidanceSectionCard(section: s)),
        if (contacts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
            child: Text('Useful organisations',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ...contacts.map((c) => GuidanceContactTile(contact: c)),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'This information is based on NHS guidance and other trusted sources, written in our own words. '
            'It is not a diagnosis. If you think you may be neurodivergent, speak to your GP. Tap a source to read the original.',
            style: TextStyle(fontSize: 11, color: colours.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }
}
