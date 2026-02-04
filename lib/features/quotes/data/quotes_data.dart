/// Quote data structure
class Quote {
  final String text;
  final String author;
  final String? context;
  
  const Quote({
    required this.text,
    required this.author,
    this.context,
  });
}

/// Pre-loaded quotes for offline use
class QuotesData {
  QuotesData._();
  
  static const List<Quote> quotes = [
    // Resilience & Strength
    Quote(
      text: 'The oak fought the wind and was broken, the willow bent when it must and survived.',
      author: 'Robert Jordan',
      context: 'Flexibility is a form of strength.',
    ),
    Quote(
      text: 'In the middle of difficulty lies opportunity.',
      author: 'Albert Einstein',
    ),
    Quote(
      text: 'A smooth sea never made a skilled sailor.',
      author: 'Franklin D. Roosevelt',
    ),
    Quote(
      text: 'Fall seven times, stand up eight.',
      author: 'Japanese Proverb',
    ),
    Quote(
      text: 'He who has a why to live can bear almost any how.',
      author: 'Friedrich Nietzsche',
    ),
    Quote(
      text: 'The wound is the place where the Light enters you.',
      author: 'Rumi',
    ),
    
    // Courage & Action
    Quote(
      text: 'Courage is not the absence of fear, but rather the judgement that something else is more important than fear.',
      author: 'Ambrose Redmoon',
    ),
    Quote(
      text: 'You gain strength, courage, and confidence by every experience in which you really stop to look fear in the face.',
      author: 'Eleanor Roosevelt',
    ),
    Quote(
      text: 'It is not the mountain we conquer but ourselves.',
      author: 'Edmund Hillary',
    ),
    Quote(
      text: 'The only way out is through.',
      author: 'Robert Frost',
    ),
    Quote(
      text: 'Do what you can, with what you have, where you are.',
      author: 'Theodore Roosevelt',
    ),
    
    // Mental Health & Self-Care
    Quote(
      text: 'You don\'t have to control your thoughts. You just have to stop letting them control you.',
      author: 'Dan Millman',
    ),
    Quote(
      text: 'Almost everything will work again if you unplug it for a few minutes, including you.',
      author: 'Anne Lamott',
    ),
    Quote(
      text: 'Self-care is not selfish. You cannot serve from an empty vessel.',
      author: 'Eleanor Brown',
    ),
    Quote(
      text: 'What lies behind us and what lies before us are tiny matters compared to what lies within us.',
      author: 'Ralph Waldo Emerson',
    ),
    Quote(
      text: 'The greatest glory in living lies not in never falling, but in rising every time we fall.',
      author: 'Nelson Mandela',
    ),
    
    // Perspective & Wisdom
    Quote(
      text: 'This too shall pass.',
      author: 'Persian Proverb',
      context: 'A reminder that both good and bad times are temporary.',
    ),
    Quote(
      text: 'Between stimulus and response there is a space. In that space is our power to choose our response.',
      author: 'Viktor Frankl',
      context: 'From "Man\'s Search for Meaning" - written after surviving Nazi concentration camps.',
    ),
    Quote(
      text: 'The mind is everything. What you think you become.',
      author: 'Buddha',
    ),
    Quote(
      text: 'We cannot direct the wind, but we can adjust our sails.',
      author: 'Dolly Parton',
    ),
    Quote(
      text: 'When we are no longer able to change a situation, we are challenged to change ourselves.',
      author: 'Viktor Frankl',
    ),
    
    // Hope & Perseverance
    Quote(
      text: 'Even the darkest night will end and the sun will rise.',
      author: 'Victor Hugo',
    ),
    Quote(
      text: 'Rock bottom became the solid foundation on which I rebuilt my life.',
      author: 'J.K. Rowling',
    ),
    Quote(
      text: 'Stars can\'t shine without darkness.',
      author: 'D.H. Sidebottom',
    ),
    Quote(
      text: 'The comeback is always stronger than the setback.',
      author: 'Unknown',
    ),
    Quote(
      text: 'Out of your vulnerabilities will come your strength.',
      author: 'Sigmund Freud',
    ),
    
    // Military & Service Related
    Quote(
      text: 'The only easy day was yesterday.',
      author: 'U.S. Navy SEALs',
    ),
    Quote(
      text: 'Under pressure, you don\'t rise to the occasion, you sink to the level of your training.',
      author: 'Navy SEAL Saying',
      context: 'This is why building good habits matters.',
    ),
    Quote(
      text: 'It\'s not the size of the dog in the fight, it\'s the size of the fight in the dog.',
      author: 'Mark Twain',
    ),
    Quote(
      text: 'The more you sweat in training, the less you bleed in combat.',
      author: 'Richard Marcinko',
    ),
    
    // Stoic Philosophy
    Quote(
      text: 'We suffer more in imagination than in reality.',
      author: 'Seneca',
    ),
    Quote(
      text: 'You have power over your mind - not outside events. Realise this, and you will find strength.',
      author: 'Marcus Aurelius',
    ),
    Quote(
      text: 'Waste no more time arguing about what a good man should be. Be one.',
      author: 'Marcus Aurelius',
    ),
    Quote(
      text: 'It is not what happens to you, but how you react to it that matters.',
      author: 'Epictetus',
    ),
    Quote(
      text: 'Difficulties strengthen the mind, as labour does the body.',
      author: 'Seneca',
    ),
    
    // Connection & Support
    Quote(
      text: 'Alone we can do so little; together we can do so much.',
      author: 'Helen Keller',
    ),
    Quote(
      text: 'No man is an island entire of itself.',
      author: 'John Donne',
    ),
    Quote(
      text: 'Sometimes the most important thing in a whole day is the rest we take between two deep breaths.',
      author: 'Etty Hillesum',
    ),
    Quote(
      text: 'The strongest people are not those who show strength in front of us but those who win battles we know nothing about.',
      author: 'Unknown',
    ),
  ];
}



