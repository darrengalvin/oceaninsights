import 'package:flutter/material.dart';

import '../../../core/theme/theme_options.dart';
import '../../../core/widgets/guidance_widgets.dart';

/// Suicide Awareness.
///
/// Content is written in the app's own words and based on guidance from
/// Mind (mind.org.uk) and the NHS (nhs.uk). Every card links to its source.
/// This screen is safety information and must never be behind a paywall.
class SuicideAwarenessScreen extends StatefulWidget {
  const SuicideAwarenessScreen({super.key});

  @override
  State<SuicideAwarenessScreen> createState() => _SuicideAwarenessScreenState();
}

// ─── Sources ────────────────────────────────────────────────────────────────

const _mindCoping = GuidanceSource('Mind: coping with suicidal thoughts',
    'https://www.mind.org.uk/information-support/suicidal-thoughts-and-suicide-prevention/coping-and-self-care/');
const _mindTreatment = GuidanceSource('Mind: treatment and support',
    'https://www.mind.org.uk/information-support/suicidal-thoughts-and-suicide-prevention/treatment-and-support/');
const _mindAE = GuidanceSource('Mind: going to A&E',
    'https://www.mind.org.uk/information-support/guides-to-support-and-services/crisis-services/accident-emergency-ae/');
const _mindTalking = GuidanceSource('Mind: talking about suicidal feelings',
    'https://www.mind.org.uk/information-support/helping-someone-else/supporting-someone-who-feels-suicidal/talking-about-suicidal-feelings');
const _mindHowToHelp = GuidanceSource('Mind: how to help',
    'https://www.mind.org.uk/information-support/helping-someone-else/supporting-someone-who-feels-suicidal/how-to-help/');
const _nhsSuicidal = GuidanceSource('NHS: help for suicidal thoughts',
    'https://www.nhs.uk/mental-health/feelings-symptoms-behaviours/behaviours/help-for-suicidal-thoughts/');
const _nhsUrgent = GuidanceSource('NHS: urgent help for mental health',
    'https://www.nhs.uk/nhs-services/mental-health-services/where-to-get-urgent-help-for-mental-health/');
const _nhs111Mh = GuidanceSource('NHS: 111 mental health option',
    'https://www.nelft.nhs.uk/services-mental-health-direct/');

// ─── Content: if you are struggling ─────────────────────────────────────────

const _struggling = <GuidanceSection>[
  GuidanceSection(
    title: 'If you have harmed yourself or might act now',
    icon: Icons.emergency_rounded,
    intro:
        'If you have seriously hurt yourself, taken an overdose, or feel you cannot keep yourself safe, this is an emergency.',
    points: [
      'Call 999, or go to A&E. You can ask someone else to call or take you.',
      'Do not drive yourself.',
      'If you can, take any medicines you are on with you.',
    ],
    footer:
        'A mental health emergency is taken as seriously as a physical one.',
    sources: [_nhsUrgent, _mindTreatment],
  ),
  GuidanceSection(
    title: 'Get through the next five minutes',
    icon: Icons.timer_outlined,
    intro:
        'When everything feels too much, try not to think about the future. Focus on getting through right now, then the next few minutes, then today.',
    points: [
      'Try to make a promise to yourself that you will not act on these thoughts today.',
      'Remind yourself that you can get through this, and that you deserve support.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Make yourself safer',
    icon: Icons.shield_outlined,
    points: [
      'Move away from anything you could use to hurt yourself, or ask someone to take it away.',
      'If where you are does not feel safe, go somewhere safer, such as a friend\'s home or a public place.',
      'Try to be around other people.',
      'If you have a safety plan or crisis plan, follow it now.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Tell someone how you feel',
    icon: Icons.record_voice_over_outlined,
    intro:
        'You do not have to explain everything. Telling one person you trust that you are struggling can help you stay safe.',
    points: [
      'Talk to a friend, family member or someone you trust.',
      'Call Samaritans free on 116 123, any time of day or night.',
      'If talking is hard, text SHOUT to 85258.',
      'Call NHS 111 and choose the mental health option.',
      'Ask your GP for an emergency appointment, or contact your crisis team if you already have one.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Calm your body and mind',
    icon: Icons.air_rounded,
    points: [
      'Take slow, deep breaths.',
      'Focus on your senses: what can you see, hear and feel around you?',
      'Open a window or step outside.',
      'Have a drink of water and something to eat if you are hungry.',
      'Avoid alcohol and drugs. They can make you feel worse.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Distract yourself',
    icon: Icons.music_note_outlined,
    points: [
      'Do something you normally enjoy, even something small.',
      'Watch something, listen to music, read, draw, cook or play a game.',
      'Go for a walk and notice what is around you.',
      'Spend time with a pet.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Make a safety plan',
    icon: Icons.checklist_rounded,
    intro:
        'A safety plan is something you write when you are feeling calmer, so it is ready if you feel worse. You might make it with someone you trust.',
    points: [
      'Your warning signs: what tells you things are getting worse.',
      'Things that help you cope.',
      'People you can contact, and helpline numbers.',
      'A place where you feel safe.',
      'How other people can help you.',
    ],
    sources: [_mindCoping, _nhsSuicidal],
  ),
];

// ─── Content: what happens when you ask for help ────────────────────────────

const _gettingHelp = <GuidanceSection>[
  GuidanceSection(
    title: 'Calling NHS 111 (mental health option)',
    icon: Icons.phone_in_talk_rounded,
    intro:
        'In England you can call 111 and choose the mental health option (option 2 in most areas) if you need urgent help but are not in immediate danger. You can call for yourself or for someone else.',
    points: [
      'A trained mental health professional will listen and talk things through with you.',
      'With your permission, they can see your health records so you do not have to repeat everything.',
      'They can give advice over the phone, connect you to a crisis team, or refer you to local services.',
      'You can also get help online at 111.nhs.uk.',
    ],
    sources: [_nhs111Mh, _nhsUrgent],
  ),
  GuidanceSection(
    title: 'Calling 999 or going to A&E',
    icon: Icons.local_hospital_outlined,
    intro:
        'If your life is at risk, call 999 or go to A&E. Tell them honestly that you are feeling suicidal and what has happened. Arriving by ambulance does not mean you are seen faster: people are seen in order of how urgent their needs are.',
    points: [
      'At A&E you register at reception and give basic details, including why you have come.',
      'A doctor or nurse checks how urgently you need care. This is called triage.',
      'Any physical injuries, such as from self-harm or an overdose, are treated.',
    ],
    sources: [_mindAE, _nhsUrgent],
  ),
  GuidanceSection(
    title: 'The mental health assessment',
    icon: Icons.psychology_alt_outlined,
    intro:
        'You will usually be seen by a mental health team. In many hospitals this is the liaison psychiatry team. They will talk with you to understand what is going on and what help you need.',
    points: [
      'They will ask how you are feeling, and may ask about your physical health.',
      'They may ask what support you have in your life and whether you feel safe at home.',
      'It helps to be honest about your thoughts and any risk to yourself.',
      'Tell them about any medicines, other health conditions, therapy and any crisis plan you have.',
      'You can ask questions, and ask for information in a format or language you understand.',
    ],
    sources: [_mindAE],
  ),
  GuidanceSection(
    title: 'What can happen next',
    icon: Icons.alt_route_rounded,
    intro:
        'Going to A&E does not automatically mean you will be kept in hospital. Most people get support at home. Depending on the assessment, you might:',
    points: [
      'Be referred to a crisis team (crisis resolution and home treatment team), who support you at home.',
      'Be asked to see your GP, who will be told about your visit.',
      'Be given self-care advice, and sometimes medication, to take home.',
      'Be sent to another service in the hospital, such as a mental health crisis centre.',
      'Be admitted to hospital if you are seriously unwell.',
    ],
    footer:
        'You might get more than one of these. For example, after a suicide attempt you could be treated on a ward for your injuries and then referred to a crisis team.',
    sources: [_mindAE, _nhsUrgent],
  ),
  GuidanceSection(
    title: 'If you need to stay in hospital',
    icon: Icons.bed_outlined,
    points: [
      'Most people who stay agree to it. This is called informal or voluntary admission, and you can ask to leave.',
      'Sometimes a person can be kept in hospital under the Mental Health Act ("sectioned") if it is needed to keep them or others safe. There are strict rules for this, and staff should explain why.',
    ],
    sources: [_mindAE],
  ),
  GuidanceSection(
    title: 'Your rights at A&E',
    icon: Icons.gavel_rounded,
    points: [
      'You cannot be turned away before a medical professional has assessed you.',
      'You should not be sent home without follow-up support.',
      'Staff should ask your permission before sharing your information, unless they are worried about your safety.',
      'You should be treated with kindness and dignity.',
      'If things get worse after you leave, you can go back.',
      'If you have a bad experience, you have the right to complain.',
    ],
    sources: [_mindAE],
  ),
];

// ─── Content: helping someone else ──────────────────────────────────────────

const _helpingSomeone = <GuidanceSection>[
  GuidanceSection(
    title: 'If they are in immediate danger',
    icon: Icons.emergency_rounded,
    points: [
      'If someone has attempted suicide, call 999 and stay with them until help arrives.',
      'If they are at immediate risk and you feel able to, remove anything they could use to harm themselves.',
      'Stay with them, in person or on the phone, and get emergency help.',
      'If they have told you online, you can call 999 for them, but you will need their name and address.',
    ],
    sources: [_mindTalking],
  ),
  GuidanceSection(
    title: 'Starting the conversation',
    icon: Icons.forum_outlined,
    points: [
      'Stay calm. It helps them feel calmer too.',
      'Do not avoid the subject. It is OK to ask directly: "Are you having suicidal thoughts?"',
      'Asking about suicide does not usually make someone more likely to act. Talking openly often helps people feel less alone and more able to get help.',
      'Give them time to answer.',
      'Take what they say seriously.',
    ],
    sources: [_mindTalking],
  ),
  GuidanceSection(
    title: 'Things that can help to say',
    icon: Icons.chat_bubble_outline_rounded,
    points: [
      'Let them know you care, and that other people care about them too.',
      '"Do you have any ideas about what might help?"',
      '"Have you thought about speaking to your GP?"',
      'Offer practical help based on what they say they need.',
    ],
    sources: [_mindTalking, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'Things to avoid',
    icon: Icons.do_not_disturb_alt_rounded,
    points: [
      'Do not judge or blame them. Telling you is a big step.',
      'Do not tell them their feelings are selfish, or how upset people would be if they died. This can add to their guilt.',
      'Do not rush to fix things or try to make the feelings go away. Listening matters most.',
      'Do not play down how they feel.',
      'Do not make promises you cannot keep.',
    ],
    sources: [_mindTalking, _mindHowToHelp],
  ),
  GuidanceSection(
    title: 'Listening well',
    icon: Icons.hearing_rounded,
    intro:
        'You do not need to have the answers. Listening and taking someone seriously can help a lot.',
    points: [
      'Do not assume you know why they feel this way. Let them explain.',
      'Ask open questions, such as "How do you feel about…?"',
      'Accept what they are feeling without arguing with it.',
    ],
    sources: [_mindTalking, _nhsSuicidal, _mindHowToHelp],
  ),
  GuidanceSection(
    title: 'Helping them get support',
    icon: Icons.volunteer_activism_outlined,
    points: [
      'Encourage them to talk to someone they trust, their GP, or a helpline such as Samaritans (116 123) or Shout (text SHOUT to 85258).',
      'Ask if they have a safety plan, and offer to help them make one.',
      'Stay with them if you can, or agree regular check-ins by phone or text.',
      'Keep doing normal things together.',
      'You can call the same helplines yourself for advice on how to support someone.',
    ],
    sources: [_mindTalking, _nhsSuicidal],
  ),
  GuidanceSection(
    title: 'If they say they are fine but you are still worried',
    icon: Icons.favorite_border_rounded,
    points: [
      'Tell them you are there for them whenever they want to talk.',
      'Keep checking in.',
      'Remind them of the support that is available.',
    ],
    sources: [_mindTalking],
  ),
];

// ─── Contacts ───────────────────────────────────────────────────────────────

const _contacts = <GuidanceContact>[
  GuidanceContact(
    name: 'Emergency services',
    description: 'If a life is at risk, or you cannot keep yourself safe',
    display: '999',
    target: '999',
    availability: '24 hours',
  ),
  GuidanceContact(
    name: 'NHS 111: mental health option',
    description:
        'Urgent mental health help in England. Call 111 and choose the mental health option (option 2 in most areas)',
    display: '111, then option 2',
    target: '111',
    availability: '24 hours',
  ),
  GuidanceContact(
    name: 'Samaritans',
    description: 'Free, confidential support for anyone, about anything',
    display: '116 123',
    target: '116123',
    availability: '24 hours, every day',
  ),
  GuidanceContact(
    name: 'Shout',
    description: 'Free, confidential crisis text service',
    display: 'Text SHOUT to 85258',
    target: '85258',
    smsBody: 'SHOUT',
    availability: '24 hours',
    kind: ContactKind.text,
  ),
  GuidanceContact(
    name: 'CALM (Campaign Against Living Miserably)',
    description: 'Helpline and webchat for anyone struggling',
    display: '0800 58 58 58',
    target: '0800585858',
    availability: '5pm to midnight, every day',
  ),
  GuidanceContact(
    name: 'Samaritans Welsh language line',
    description: 'Support in Welsh',
    display: '0808 164 0123',
    target: '08081640123',
    availability: '7pm to 11pm, every day',
  ),
  GuidanceContact(
    name: 'Childline',
    description: 'For anyone under 19. The number will not show on your phone bill',
    display: '0800 1111',
    target: '08001111',
    availability: '24 hours',
  ),
];

// ─── Screen ─────────────────────────────────────────────────────────────────

class _SuicideAwarenessScreenState extends State<SuicideAwarenessScreen> {
  int _tab = 0;
  static const _tabs = [
    'If you\'re struggling',
    'What happens next',
    'Helping someone',
    'Contacts',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GuidanceHeader(
              title: 'Suicide Awareness',
              subtitle: 'Help for you, and for someone you\'re worried about',
            ),
            const SizedBox(height: 12),
            const _CrisisBanner(),
            GuidanceTabBar(
              tabs: _tabs,
              selected: _tab,
              onSelected: (i) => setState(() => _tab = i),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _SectionList(
                    intro:
                        'If you are having thoughts of ending your life, you are not alone, and help is available right now.',
                    sections: _struggling,
                  ),
                  _SectionList(
                    intro:
                        'Many people worry about what will happen if they tell someone they feel suicidal. This is what you can usually expect.',
                    sections: _gettingHelp,
                  ),
                  _SectionList(
                    intro:
                        'If you are worried someone is thinking about suicide, you do not need to be an expert to help. Being there and listening can make a real difference.',
                    sections: _helpingSomeone,
                  ),
                  const _ContactsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Always-visible emergency contacts at the top of the screen.
class _CrisisBanner extends StatelessWidget {
  const _CrisisBanner();

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colours.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colours.error.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need help now?',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colours.error,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'If your life is at risk, call 999. For urgent mental health help, call 111 and choose option 2. To talk to someone, call Samaritans on 116 123.',
            style: TextStyle(fontSize: 12, color: colours.textLight, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _CrisisButton(
              label: '999',
              onTap: () => openGuidanceLink(context,
                  kind: ContactKind.phone, target: '999'),
              filled: true,
            ),
            const SizedBox(width: 8),
            _CrisisButton(
              label: 'NHS 111',
              onTap: () => openGuidanceLink(context,
                  kind: ContactKind.phone, target: '111'),
            ),
            const SizedBox(width: 8),
            _CrisisButton(
              label: 'Samaritans',
              onTap: () => openGuidanceLink(context,
                  kind: ContactKind.phone, target: '116123'),
            ),
          ]),
        ],
      ),
    );
  }
}

class _CrisisButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _CrisisButton(
      {required this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Expanded(
      child: Material(
        color: filled ? colours.error : colours.card,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colours.error.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_rounded,
                    size: 16, color: filled ? Colors.white : colours.error),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: filled ? Colors.white : colours.error)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  final String intro;
  final List<GuidanceSection> sections;
  const _SectionList({required this.intro, required this.sections});

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(intro,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colours.textBright, height: 1.5)),
        ),
        ...sections.map((s) => GuidanceSectionCard(
              section: s,
              tint: s.icon == Icons.emergency_rounded ? colours.error : null,
            )),
        const _Attribution(),
      ],
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList();

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Tap a service to call or text. These services are free and confidential.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colours.textBright, height: 1.5),
          ),
        ),
        ..._contacts.map((c) => GuidanceContactTile(contact: c)),
        const SizedBox(height: 4),
        const GuidanceSourceLinks(
            sources: [_nhsSuicidal, _nhsUrgent, _mindTreatment]),
        const _Attribution(),
      ],
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    final colours = context.colours;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        'This information is based on guidance from Mind and the NHS, written in our own words. '
        'It does not replace advice from a doctor or other health professional. Tap a source to read the original.',
        style: TextStyle(fontSize: 11, color: colours.textMuted, height: 1.4),
      ),
    );
  }
}
