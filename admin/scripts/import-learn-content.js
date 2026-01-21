#!/usr/bin/env node

/**
 * Import existing Learn content from the Flutter app into Supabase
 * Run: node scripts/import-learn-content.js
 */

require('dotenv').config({ path: '.env.local' })
const { createClient } = require('@supabase/supabase-js')

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Existing content from the Flutter app
const articles = [
  // Brain Science
  {
    slug: 'brain-science.nine-second-rule',
    title: 'The 9-Second Rule',
    summary: 'Why waiting just 9 seconds before reacting can change everything.',
    category: 'brain_science',
    read_time_minutes: 4,
    sections: [
      {
        content: 'When something triggers an emotional response, your brain\'s amygdala fires first - before your rational thinking brain (prefrontal cortex) has time to process what\'s happening. This is called an "amygdala hijack".'
      },
      {
        heading: 'The Science Behind It',
        content: 'Research shows it takes approximately 6-9 seconds for your prefrontal cortex to catch up with your amygdala. During this window, you\'re essentially running on pure emotion with limited access to logical thinking.'
      },
      {
        heading: 'How to Use This',
        content: 'When you feel a strong emotional reaction rising:\n\n1. Recognise the feeling\n2. Take a breath\n3. Count to 9 slowly\n4. Then respond\n\nThis simple pause allows your thinking brain to come back online.',
        tip: 'Practice this with small frustrations first. The more you do it, the more automatic it becomes.'
      },
      {
        heading: 'Why It Matters',
        content: 'Most regrettable actions - angry words, impulsive decisions, aggressive responses - happen in that first 9 seconds. By simply pausing, you give yourself the choice of how to respond rather than just reacting.'
      }
    ],
    key_takeaways: [
      'Your emotional brain reacts faster than your thinking brain',
      'It takes about 9 seconds for logic to catch up with emotion',
      'A simple pause can prevent most regrettable reactions',
      'This is a skill that improves with practice'
    ]
  },
  {
    slug: 'brain-science.fight-flight-freeze',
    title: 'Understanding Fight, Flight & Freeze',
    summary: 'Your body\'s ancient survival system and why it sometimes misfires.',
    category: 'brain_science',
    read_time_minutes: 5,
    sections: [
      {
        content: 'Your nervous system has a built-in alarm system designed to keep you alive. When it detects danger, it triggers one of three responses: fight, flight, or freeze. This system hasn\'t changed much since our ancestors faced physical threats like predators.'
      },
      {
        heading: 'The Three Responses',
        content: 'Fight: Increased aggression, tension, urge to confront\n\nFlight: Urge to escape, restlessness, anxiety\n\nFreeze: Feeling stuck, unable to think or move, dissociation\n\nAll three are your body\'s attempt to protect you.'
      },
      {
        heading: 'The Modern Problem',
        content: 'Your brain can\'t distinguish between a physical threat (a predator) and a psychological one (an angry email from your boss). Both trigger the same survival response, flooding your body with stress hormones like cortisol and adrenaline.',
        tip: 'Recognising which response you tend toward helps you manage it. Do you get angry? Want to run? Or do you shut down?'
      },
      {
        heading: 'Resetting Your System',
        content: 'Once triggered, your body needs to complete the stress cycle to return to baseline:\n\n• Physical movement (even a short walk)\n• Deep breathing exercises\n• Progressive muscle relaxation\n• Social connection\n\nWithout completing the cycle, stress hormones stay elevated.'
      }
    ],
    key_takeaways: [
      'Fight, flight, and freeze are normal survival responses',
      'Your brain treats modern stress the same as physical danger',
      'Recognising your typical response helps you manage it',
      'Physical movement helps reset your nervous system'
    ]
  },
  {
    slug: 'brain-science.neuroplasticity',
    title: 'Your Brain Can Change',
    summary: 'Understanding neuroplasticity and why it\'s never too late to rewire your thinking.',
    category: 'brain_science',
    read_time_minutes: 4,
    sections: [
      {
        content: 'For decades, scientists believed the adult brain was fixed and unchangeable. We now know this is completely wrong. Your brain is constantly rewiring itself based on your experiences, thoughts, and behaviours. This is called neuroplasticity.'
      },
      {
        heading: 'How It Works',
        content: 'Think of your brain like paths in a forest. The paths you walk most often become clear and easy to travel. Paths you ignore become overgrown. Your thoughts work the same way - repeated thoughts strengthen neural pathways, making them easier to access.'
      },
      {
        heading: 'The Practical Implication',
        content: 'This means:\n\n• Negative thought patterns can be unlearned\n• New, healthier patterns can be built\n• It takes repetition and consistency\n• Change is possible at any age',
        tip: 'Every time you choose a different response to a familiar trigger, you\'re literally rewiring your brain.'
      },
      {
        heading: 'Building New Pathways',
        content: 'To change a pattern:\n\n1. Become aware of the existing pattern\n2. Deliberately choose a different response\n3. Repeat consistently over time\n\nResearch suggests it takes roughly 66 days of consistent practice to form a new automatic behaviour.'
      }
    ],
    key_takeaways: [
      'Your brain physically changes based on what you think and do',
      'Repeated thoughts create stronger neural pathways',
      'It\'s never too late to rewire negative patterns',
      'Consistency and repetition are key to lasting change'
    ]
  },
  {
    slug: 'brain-science.sleep-mental-health',
    title: 'Sleep and Your Mind',
    summary: 'Why sleep is not a luxury but a necessity for mental wellbeing.',
    category: 'brain_science',
    read_time_minutes: 5,
    sections: [
      {
        content: 'Sleep isn\'t just rest for your body - it\'s essential maintenance time for your brain. During sleep, your brain processes emotions, consolidates memories, and clears out toxins that build up during waking hours.'
      },
      {
        heading: 'What Happens When We Sleep',
        content: 'REM sleep (when we dream) is crucial for emotional processing. Your brain essentially "reviews" the day\'s emotional experiences and files them properly. Without enough REM sleep, emotions stay raw and unprocessed.'
      },
      {
        heading: 'The Sleep-Mood Connection',
        content: 'Research shows that just one night of poor sleep:\n\n• Increases emotional reactivity by up to 60%\n• Reduces ability to cope with stress\n• Impairs decision-making\n• Affects impulse control\n\nChronic sleep deprivation is strongly linked to anxiety and depression.',
        tip: 'If you\'re feeling emotionally volatile, ask yourself: "How did I sleep last night?"'
      },
      {
        heading: 'Improving Sleep Quality',
        content: 'Key factors for better sleep:\n\n• Consistent wake time (even weekends)\n• Limited screen time before bed\n• Cool, dark environment\n• No caffeine after early afternoon\n• Wind-down routine\n\nQuality matters as much as quantity.'
      }
    ],
    key_takeaways: [
      'Sleep is when your brain processes emotions',
      'Poor sleep directly impacts emotional regulation',
      'Consistent sleep timing is more important than duration',
      'Sleep problems and mental health issues often go together'
    ]
  },
  
  // Psychology
  {
    slug: 'psychology.validating-emotions',
    title: 'All Feelings Are Valid',
    summary: 'Understanding why your emotions make sense, even when they\'re uncomfortable.',
    category: 'psychology',
    read_time_minutes: 4,
    sections: [
      {
        content: 'Every emotion you experience has a reason. Feelings aren\'t random - they\'re your mind\'s response to your experiences, memories, and perceptions. Even "negative" emotions like anger, fear, or sadness serve important purposes.'
      },
      {
        heading: 'Emotions Are Information',
        content: 'Think of emotions as messengers, not problems:\n\n• Anger tells you a boundary has been crossed\n• Fear alerts you to potential danger\n• Sadness signals loss or unmet needs\n• Anxiety points to uncertainty or threat\n\nThe emotion itself isn\'t the problem - it\'s information.'
      },
      {
        heading: 'The Trap of Judging Feelings',
        content: 'Many of us learned to judge our emotions: "I shouldn\'t feel this way" or "I\'m being stupid." This judgement adds suffering on top of the original feeling. You end up feeling bad about feeling bad.',
        tip: 'Try replacing "I shouldn\'t feel this" with "It makes sense I feel this because..."'
      },
      {
        heading: 'Validation vs Justification',
        content: 'Validating an emotion doesn\'t mean the emotion is "right" or that you should act on it. It simply means acknowledging that the feeling exists and has a reason.\n\nYou can validate your anger while choosing not to act on it aggressively.'
      }
    ],
    key_takeaways: [
      'All emotions have a reason - they\'re information',
      'Judging your feelings adds unnecessary suffering',
      'Validating an emotion doesn\'t mean acting on it',
      'Understanding why you feel something helps you respond better'
    ]
  },
  {
    slug: 'psychology.thoughts-not-facts',
    title: 'Thoughts Are Not Facts',
    summary: 'Learning to observe your thoughts without believing everything they tell you.',
    category: 'psychology',
    read_time_minutes: 4,
    sections: [
      {
        content: 'Your mind produces thousands of thoughts every day. Many of these thoughts are automatic - they pop up without your conscious choice. Just because a thought appears in your mind doesn\'t make it true or important.'
      },
      {
        heading: 'The Thinking Mind',
        content: 'Your brain is a prediction machine, constantly generating thoughts about what might happen, what could go wrong, and what things mean. Many of these predictions are based on past experiences and may not apply to current situations.'
      },
      {
        heading: 'Common Thinking Traps',
        content: 'Watch out for these patterns:\n\n• All-or-nothing thinking: "If it\'s not perfect, it\'s a failure"\n• Mind reading: "They must think I\'m an idiot"\n• Fortune telling: "This will definitely go wrong"\n• Catastrophising: "This is the worst thing ever"\n\nThese are common but often inaccurate.',
        tip: 'When you notice a strong negative thought, ask: "Is this a fact or an interpretation?"'
      },
      {
        heading: 'Creating Distance',
        content: 'Instead of "I\'m a failure," try "I\'m having the thought that I\'m a failure." This small shift creates distance between you and the thought, making it easier to question its accuracy.'
      }
    ],
    key_takeaways: [
      'Thoughts are mental events, not facts',
      'Your brain generates many automatic thoughts that aren\'t accurate',
      'Recognising thinking patterns helps you question them',
      'Creating distance from thoughts reduces their power'
    ]
  },
  {
    slug: 'psychology.stress-vs-stressors',
    title: 'Stress vs Stressors',
    summary: 'Understanding the difference between what causes stress and the stress itself.',
    category: 'psychology',
    read_time_minutes: 3,
    sections: [
      {
        content: 'Many people focus on eliminating stressors - the things that cause stress. But stressors and stress are not the same thing. You can remove a stressor and still carry the stress in your body.'
      },
      {
        heading: 'The Stress Cycle',
        content: 'Stress is a physiological response - it happens in your body. When you encounter a stressor, your body activates. That activation needs to complete its cycle to return to baseline, regardless of whether the stressor is still present.'
      },
      {
        heading: 'Completing the Cycle',
        content: 'Ways to complete the stress cycle:\n\n• Physical activity (most effective)\n• Deep breathing\n• Positive social interaction\n• Laughter\n• Crying\n• Creative expression\n\nThe key is allowing your body to physically process the stress.',
        tip: 'Even a few minutes of physical movement can help complete a stress cycle.'
      }
    ],
    key_takeaways: [
      'Removing a stressor doesn\'t automatically remove the stress',
      'Stress is a physical response that needs to complete its cycle',
      'Physical activity is one of the best ways to process stress',
      'Multiple short stress-relief activities throughout the day help'
    ]
  },
  
  // Life Situations
  {
    slug: 'life.relationship-breakdown',
    title: 'When Relationships End',
    summary: 'Navigating the pain of relationship breakdown and finding your way forward.',
    category: 'life_situation',
    read_time_minutes: 5,
    age_brackets: ['25-34', '35-44', '45-54'],
    sections: [
      {
        content: 'The end of a significant relationship is one of life\'s most painful experiences. Whether it was your choice or not, grief is normal. You\'re mourning not just the person, but the future you imagined together.'
      },
      {
        heading: 'What You Might Feel',
        content: 'It\'s normal to experience:\n\n• Waves of intense emotion\n• Difficulty concentrating\n• Changes in appetite or sleep\n• Questioning yourself\n• Relief mixed with sadness\n• Anger and frustration\n\nAll of these are part of processing loss.'
      },
      {
        heading: 'The Non-Linear Path',
        content: 'Healing isn\'t a straight line. You might feel better for a while, then struggle again. This is completely normal. Progress isn\'t about never feeling bad - it\'s about the overall trend over time.',
        tip: 'Be patient with yourself. Most people underestimate how long relationship grief takes.'
      },
      {
        heading: 'Moving Forward',
        content: 'Helpful approaches:\n\n• Allow yourself to feel without judgement\n• Maintain routines where possible\n• Stay connected to supportive people\n• Avoid major decisions during acute grief\n• Focus on basic self-care\n\nThis is a marathon, not a sprint.'
      }
    ],
    key_takeaways: [
      'Grieving a relationship is normal and necessary',
      'Healing is not linear - expect ups and downs',
      'Your feelings are valid even if the relationship needed to end',
      'Basic self-care becomes especially important during this time'
    ]
  },
  {
    slug: 'life.financial-stress',
    title: 'Dealing with Financial Pressure',
    summary: 'Managing the mental weight of money worries.',
    category: 'life_situation',
    read_time_minutes: 4,
    age_brackets: ['18-24', '25-34', '35-44', '45-54', '55+'],
    sections: [
      {
        content: 'Financial stress is one of the most common sources of anxiety. Money worries affect sleep, relationships, and mental health. If you\'re struggling financially, know that you\'re not alone and it doesn\'t define your worth.'
      },
      {
        heading: 'Breaking the Avoidance Cycle',
        content: 'When finances feel overwhelming, it\'s tempting to avoid looking at them. But avoidance usually makes anxiety worse. Getting a clear picture - however uncomfortable - is the first step to regaining control.',
        tip: 'Set a specific time to look at your finances. Having a designated "worry time" can prevent money stress from taking over every moment.'
      },
      {
        heading: 'One Step at a Time',
        content: 'Focus on what you can control:\n\n• Know your numbers (income vs expenses)\n• Identify one area to address first\n• Seek advice if you need it (free services exist)\n• Separate "essential" from "wanted"\n\nSmall steps add up over time.'
      },
      {
        heading: 'Your Worth Is Not Your Net Worth',
        content: 'Financial difficulties do not make you a failure. Circumstances, systems, and life events affect finances. Many successful people have faced financial hardship. What matters is how you respond.'
      }
    ],
    key_takeaways: [
      'Financial stress is extremely common - you\'re not alone',
      'Avoiding your finances usually makes anxiety worse',
      'Focus on small, actionable steps rather than the whole picture',
      'Your value as a person is not tied to your financial situation'
    ]
  },
  {
    slug: 'life.isolation-deployment',
    title: 'Staying Connected When Isolated',
    summary: 'Maintaining mental wellbeing during extended periods away from loved ones.',
    category: 'life_situation',
    read_time_minutes: 4,
    age_brackets: ['18-24', '25-34', '35-44'],
    sections: [
      {
        content: 'Extended time away from family, friends, and normal life takes a psychological toll. Whether due to work deployment, remote assignments, or other circumstances, isolation challenges our mental health in unique ways.'
      },
      {
        heading: 'The Impact of Isolation',
        content: 'Isolation can lead to:\n\n• Rumination (overthinking)\n• Low mood\n• Sleep disruption\n• Loss of motivation\n• Relationship strain (despite wanting connection)\n\nRecognising these as normal responses helps.'
      },
      {
        heading: 'Building Routine',
        content: 'Structure becomes even more important when you\'re isolated. Create anchors in your day:\n\n• Consistent wake and sleep times\n• Regular physical activity\n• Designated work and rest periods\n• Something to look forward to each day',
        tip: 'Even small rituals - a morning routine, an evening wind-down - provide psychological stability.'
      },
      {
        heading: 'Maintaining Connections',
        content: 'Connection doesn\'t require physical presence:\n\n• Keep a journal of things to share later\n• Look at photos that remind you of home\n• Establish mental "check-in" times when you think of loved ones\n• Focus on quality of limited contact, not quantity'
      }
    ],
    key_takeaways: [
      'Isolation affects mood and thinking - this is normal',
      'Routine and structure provide psychological stability',
      'Connection can be maintained even without regular contact',
      'This period is temporary - focus on one day at a time'
    ]
  },
  {
    slug: 'life.starting-career',
    title: 'Finding Your Way in Early Career',
    summary: 'Navigating uncertainty and pressure when you\'re just starting out.',
    category: 'life_situation',
    read_time_minutes: 4,
    age_brackets: ['18-24', '25-34'],
    sections: [
      {
        content: 'The early years of your career can feel overwhelming. Pressure to succeed, uncertainty about the right path, comparison to others - it\'s a lot to manage while also learning new skills and finding your place.'
      },
      {
        heading: 'The Comparison Trap',
        content: 'Social media makes it easy to compare your beginning to someone else\'s middle. Remember: you\'re seeing highlight reels, not full pictures. Everyone struggles; most just don\'t advertise it.',
        tip: 'When you catch yourself comparing, ask: "Do I actually know their full story?"'
      },
      {
        heading: 'Uncertainty Is Normal',
        content: 'Not knowing exactly what you want to do is completely normal at this stage. Very few people have it all figured out in their twenties. Your path doesn\'t need to be linear or certain.'
      },
      {
        heading: 'Building Foundations',
        content: 'Focus on:\n\n• Learning from every experience (even bad ones)\n• Building relationships and reputation\n• Developing transferable skills\n• Taking care of your mental health now\n\nThese foundations serve you regardless of where your career goes.'
      }
    ],
    key_takeaways: [
      'Uncertainty in early career is normal, not a failure',
      'Comparison to others\' highlight reels is misleading',
      'Your path doesn\'t need to be figured out right away',
      'Investing in relationships and skills pays off long-term'
    ]
  }
]

async function importLearnContent() {
  console.log('📚 Importing Learn articles to Supabase...\n')
  
  let success = 0
  let failed = 0
  
  for (const article of articles) {
    try {
      console.log(`  Processing: "${article.title}"...`)
      
      // Check if already exists
      const { data: existing } = await supabaseAdmin
        .from('learn_articles')
        .select('id')
        .eq('slug', article.slug)
        .single()
      
      if (existing) {
        console.log(`    ⏭️  Already exists, skipping`)
        continue
      }
      
      // Insert article
      const { data: insertedArticle, error: articleError } = await supabaseAdmin
        .from('learn_articles')
        .insert({
          slug: article.slug,
          title: article.title,
          summary: article.summary,
          category: article.category,
          read_time_minutes: article.read_time_minutes,
          age_brackets: article.age_brackets || null,
          audience: 'any',
          is_published: true
        })
        .select()
        .single()
      
      if (articleError) throw articleError
      
      // Insert content
      const { error: contentError } = await supabaseAdmin
        .from('learn_article_content')
        .insert({
          article_id: insertedArticle.id,
          sections: article.sections,
          key_takeaways: article.key_takeaways
        })
      
      if (contentError) throw contentError
      
      success++
      console.log(`    ✅ Imported`)
      
    } catch (error) {
      failed++
      console.error(`    ❌ Failed: ${error.message}`)
    }
  }
  
  console.log(`\n📊 Import complete:`)
  console.log(`   ✅ Success: ${success}`)
  console.log(`   ❌ Failed: ${failed}`)
  console.log(`   ⏭️  Skipped: ${articles.length - success - failed}`)
}

importLearnContent()

