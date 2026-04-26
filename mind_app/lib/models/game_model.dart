// ============================================================
// game_model.dart
// Place in: lib/models/game_model.dart
// ============================================================

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? funFact; // shown after answering
  final bool isImage;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.funFact,
    this.isImage = false,
  });
}

class GameLevel {
  final int levelNumber;
  final String title;
  final String icon; // emoji
  final int starsRequired; // stars needed to unlock
  final List<QuizQuestion> questions;

  const GameLevel({
    required this.levelNumber,
    required this.title,
    required this.icon,
    required this.starsRequired,
    required this.questions,
  });
}

class Subject {
  final String id;
  final String name;
  final String emoji;
  final List<String> gradientColors; // hex strings
  final List<GameLevel> levels;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientColors,
    required this.levels,
  });
}

// ============================================================
// GAME DATA — all subjects, levels, and questions
// ============================================================

class GameData {
  static const List<Subject> subjects = [
    Subject(
      id: 'science',
      name: 'Science',
      emoji: '🔬',
      gradientColors: ['#4FC3F7', '#0288D1'],
      levels: _scienceLevels,
    ),
    Subject(
      id: 'biology',
      name: 'Biology',
      emoji: '🌿',
      gradientColors: ['#81C784', '#388E3C'],
      levels: _biologyLevels,
    ),
    Subject(
      id: 'history',
      name: 'History',
      emoji: '🏰',
      gradientColors: ['#FFB74D', '#E65100'],
      levels: _historyLevels,
    ),
  ];

  // ── SCIENCE ────────────────────────────────────────────────
  static const List<GameLevel> _scienceLevels = [
    GameLevel(
      levelNumber: 1,
      title: 'What is Science?',
      icon: '🧪',
      starsRequired: 0,
      questions: [
        QuizQuestion(
          question:
              'What do we use to look at tiny objects that are too small to see?',
          options: ['Telescope', 'Microscope', 'Binoculars', 'Camera'],
          correctIndex: 1,
          funFact:
              'A microscope can magnify objects up to 2,000 times their real size! 🔬',
        ),
        QuizQuestion(
          question: 'What is the closest star to Earth?',
          options: ['Polaris', 'Sirius', 'The Sun', 'Proxima Centauri'],
          correctIndex: 2,
          funFact:
              'The Sun is 93 million miles away — that\'s very far, but still the closest star! ☀️',
        ),
        QuizQuestion(
          question: 'Which of these is NOT a state of matter?',
          options: ['Solid', 'Liquid', 'Energy', 'Gas'],
          correctIndex: 2,
          funFact:
              'The three states of matter are solid, liquid, and gas. Energy is not a state of matter! ⚡',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 2,
      title: 'Forces & Motion',
      icon: '🧲',
      starsRequired: 30,
      questions: [
        QuizQuestion(
          question: 'What force pulls objects toward the ground?',
          options: ['Magnetism', 'Friction', 'Gravity', 'Wind'],
          correctIndex: 2,
          funFact: 'Gravity is what keeps you from floating off into space! 🌍',
        ),
        QuizQuestion(
          question: 'What happens when you push a ball on a flat surface?',
          options: [
            'It stops immediately',
            'It moves forward',
            'It goes up',
            'Nothing happens'
          ],
          correctIndex: 1,
          funFact: 'Friction eventually slows the ball down and stops it! 🎳',
        ),
        QuizQuestion(
          question:
              'Which is heavier — a kilogram of feathers or a kilogram of rocks?',
          options: [
            'Rocks',
            'Feathers',
            'They weigh the same',
            'Depends on the day'
          ],
          correctIndex: 2,
          funFact: 'Both weigh exactly 1 kilogram — don\'t be tricked! ⚖️',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 3,
      title: 'Space Explorer',
      icon: '🔭',
      starsRequired: 60,
      questions: [
        QuizQuestion(
          question: 'How many planets are in our Solar System?',
          options: ['7', '8', '9', '10'],
          correctIndex: 1,
          funFact:
              'Pluto was reclassified as a dwarf planet in 2006, leaving us with 8! 🪐',
        ),
        QuizQuestion(
          question: 'What is the largest planet in our Solar System?',
          options: ['Saturn', 'Earth', 'Jupiter', 'Neptune'],
          correctIndex: 2,
          funFact:
              'Jupiter is so big that 1,300 Earths could fit inside it! 🌕',
        ),
        QuizQuestion(
          question: 'What do we call a rock from space that hits Earth?',
          options: ['Asteroid', 'Comet', 'Meteor', 'Meteorite'],
          correctIndex: 3,
          funFact:
              'A meteoroid becomes a meteor when it enters the atmosphere, and a meteorite when it lands! ☄️',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 4,
      title: 'Energy & Light',
      icon: '⚛️',
      starsRequired: 100,
      questions: [
        QuizQuestion(
          question: 'What color is made when red and blue light mix?',
          options: ['Green', 'Yellow', 'Purple', 'Orange'],
          correctIndex: 2,
          funFact: 'Mixing red and blue gives purple or magenta! 🎨',
        ),
        QuizQuestion(
          question: 'Which travels faster — sound or light?',
          options: [
            'Sound',
            'Light',
            'They travel the same speed',
            'Depends on weather'
          ],
          correctIndex: 1,
          funFact:
              'Light travels at 300,000 km per second — much faster than sound! ⚡',
        ),
        QuizQuestion(
          question: 'What source of energy comes from the Sun?',
          options: [
            'Nuclear energy',
            'Solar energy',
            'Wind energy',
            'Hydro energy'
          ],
          correctIndex: 1,
          funFact:
              'The Sun produces more energy in one second than all of human history combined! ☀️',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 5,
      title: 'Science Master',
      icon: '🏆',
      starsRequired: 150,
      questions: [
        QuizQuestion(
          question: 'What is H₂O more commonly known as?',
          options: ['Juice', 'Milk', 'Water', 'Air'],
          correctIndex: 2,
          funFact:
              'H₂O means 2 Hydrogen atoms and 1 Oxygen atom — that\'s water! 💧',
        ),
        QuizQuestion(
          question: 'What gas do plants absorb from the air?',
          options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Hydrogen'],
          correctIndex: 2,
          funFact:
              'Plants absorb CO₂ and release Oxygen — the opposite of what we do! 🌱',
        ),
        QuizQuestion(
          question: 'What is the hardest natural substance on Earth?',
          options: ['Iron', 'Diamond', 'Quartz', 'Granite'],
          correctIndex: 1,
          funFact:
              'Diamond is so hard it can only be scratched by another diamond! 💎',
        ),
      ],
    ),
  ];

  // ── BIOLOGY ────────────────────────────────────────────────
  static const List<GameLevel> _biologyLevels = [
    GameLevel(
      levelNumber: 1,
      title: 'Living Things',
      icon: '🌱',
      starsRequired: 0,
      questions: [
        QuizQuestion(
          question: 'Which of these is a living thing?',
          options: ['Rock', 'Tree', 'Cloud', 'Water'],
          correctIndex: 1,
          funFact:
              'Trees are living organisms — they grow, reproduce, and respond to the environment! 🌳',
        ),
        QuizQuestion(
          question: 'What do plants need to make their own food?',
          options: ['Moonlight', 'Sunlight', 'Darkness', 'Rain only'],
          correctIndex: 1,
          funFact:
              'Photosynthesis uses sunlight, water, and CO₂ to make sugar for plants! ☀️',
        ),
        QuizQuestion(
          question: 'What is the smallest unit of life?',
          options: ['Atom', 'Organ', 'Cell', 'Tissue'],
          correctIndex: 2,
          funFact: 'Your body has about 37 trillion cells! 🔬',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 2,
      title: 'Animal Kingdom',
      icon: '🦁',
      starsRequired: 30,
      questions: [
        QuizQuestion(
          question: 'What do we call animals that eat only plants?',
          options: ['Carnivores', 'Omnivores', 'Herbivores', 'Decomposers'],
          correctIndex: 2,
          funFact: 'Cows, rabbits, and elephants are herbivores! 🐘',
        ),
        QuizQuestion(
          question: 'Which animal is a mammal?',
          options: ['Snake', 'Frog', 'Shark', 'Whale'],
          correctIndex: 3,
          funFact:
              'Whales breathe air and feed their babies milk — just like you! 🐳',
        ),
        QuizQuestion(
          question: 'How many legs does an insect have?',
          options: ['4', '6', '8', '10'],
          correctIndex: 1,
          funFact:
              'All insects have exactly 6 legs! Spiders have 8 and are not insects. 🐛',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 3,
      title: 'Human Body',
      icon: '❤️',
      starsRequired: 60,
      questions: [
        QuizQuestion(
          question: 'How many bones does an adult human body have?',
          options: ['106', '206', '306', '406'],
          correctIndex: 1,
          funFact:
              'Babies are born with 270 bones, but many fuse together as we grow! 🦴',
        ),
        QuizQuestion(
          question: 'Which organ pumps blood around your body?',
          options: ['Lungs', 'Liver', 'Heart', 'Brain'],
          correctIndex: 2,
          funFact: 'Your heart beats about 100,000 times every single day! ❤️',
        ),
        QuizQuestion(
          question: 'What do your lungs do?',
          options: ['Digest food', 'Pump blood', 'Breathe air', 'Filter water'],
          correctIndex: 2,
          funFact:
              'Your lungs take in oxygen and release carbon dioxide with every breath! 🫁',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 4,
      title: 'Ecosystems',
      icon: '🌍',
      starsRequired: 100,
      questions: [
        QuizQuestion(
          question:
              'What do we call the place where an animal naturally lives?',
          options: ['Zoo', 'Habitat', 'Farm', 'Biome'],
          correctIndex: 1,
          funFact:
              'Protecting natural habitats is the best way to save endangered animals! 🐼',
        ),
        QuizQuestion(
          question:
              'What is the process called when a caterpillar turns into a butterfly?',
          options: ['Evolution', 'Metamorphosis', 'Migration', 'Hibernation'],
          correctIndex: 1,
          funFact:
              'Inside the chrysalis, the caterpillar literally dissolves before reforming as a butterfly! 🦋',
        ),
        QuizQuestion(
          question: 'Which of these animals hibernates in winter?',
          options: ['Penguin', 'Eagle', 'Bear', 'Dolphin'],
          correctIndex: 2,
          funFact:
              'Bears can sleep for 7 months straight during hibernation! 🐻',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 5,
      title: 'Biology Champion',
      icon: '🏅',
      starsRequired: 150,
      questions: [
        QuizQuestion(
          question: 'What is DNA?',
          options: [
            'A type of food',
            'Instructions for building living things',
            'A bone',
            'A disease'
          ],
          correctIndex: 1,
          funFact:
              'If you stretched out all the DNA in one human cell, it would be 2 meters long! 🧬',
        ),
        QuizQuestion(
          question: 'Which part of the plant absorbs water from the soil?',
          options: ['Leaves', 'Stem', 'Roots', 'Flowers'],
          correctIndex: 2,
          funFact: 'Some tree roots can spread wider than the tree is tall! 🌳',
        ),
        QuizQuestion(
          question: 'What do we call baby frogs before they grow legs?',
          options: ['Larvae', 'Tadpoles', 'Puppies', 'Nymphs'],
          correctIndex: 1,
          funFact:
              'Tadpoles have tails and gills, then grow legs and lungs as they become frogs! 🐸',
        ),
      ],
    ),
  ];

  // ── HISTORY ────────────────────────────────────────────────
  static const List<GameLevel> _historyLevels = [
    GameLevel(
      levelNumber: 1,
      title: 'Ancient Egypt',
      icon: '🏺',
      starsRequired: 0,
      questions: [
        QuizQuestion(
          question:
              'What did the Ancient Egyptians build as tombs for their pharaohs?',
          options: ['Castles', 'Pyramids', 'Coliseums', 'Temples'],
          correctIndex: 1,
          funFact:
              'The Great Pyramid was the tallest human-made structure for 3,800 years! 🔺',
        ),
        QuizQuestion(
          question:
              'What was the name of the writing system used in Ancient Egypt?',
          options: ['Alphabet', 'Cuneiform', 'Hieroglyphics', 'Latin'],
          correctIndex: 2,
          funFact:
              'Hieroglyphics used over 700 different picture symbols as letters! 📜',
        ),
        QuizQuestion(
          question: 'What was the River Nile important for in Ancient Egypt?',
          options: [
            'Swimming',
            'Farming and water',
            'Trading gold only',
            'Building pyramids'
          ],
          correctIndex: 1,
          funFact:
              'The Nile floods every year, leaving rich soil perfect for growing crops! 🌊',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 2,
      title: 'Ancient Greece',
      icon: '🏛️',
      starsRequired: 30,
      questions: [
        QuizQuestion(
          question: 'The Ancient Greeks invented which major sporting event?',
          options: ['World Cup', 'Olympic Games', 'Cricket', 'Chess Olympics'],
          correctIndex: 1,
          funFact:
              'The first Olympic Games were held in 776 BC in Olympia, Greece! 🏅',
        ),
        QuizQuestion(
          question: 'What is democracy?',
          options: [
            'Rule by one king',
            'Rule by the people',
            'Rule by priests',
            'Rule by the army'
          ],
          correctIndex: 1,
          funFact:
              'The Ancient Greeks invented democracy — the word means "rule by the people" in Greek! 🗳️',
        ),
        QuizQuestion(
          question: 'Who was the king of the Greek gods?',
          options: ['Poseidon', 'Hades', 'Zeus', 'Apollo'],
          correctIndex: 2,
          funFact:
              'Zeus was the god of lightning and the sky, and ruler of Mount Olympus! ⚡',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 3,
      title: 'Middle Ages',
      icon: '⚔️',
      starsRequired: 60,
      questions: [
        QuizQuestion(
          question: 'Where did knights and kings live in the Middle Ages?',
          options: ['Pyramids', 'Castles', 'Caves', 'Skyscrapers'],
          correctIndex: 1,
          funFact:
              'Castles had thick walls, drawbridges, and moats to protect against attackers! 🏰',
        ),
        QuizQuestion(
          question: 'What were the journeys to recapture Jerusalem called?',
          options: ['Expeditions', 'Crusades', 'Voyages', 'Pilgrimages'],
          correctIndex: 1,
          funFact: 'There were 9 major Crusades between 1095 and 1291! ⚔️',
        ),
        QuizQuestion(
          question:
              'What did monks do in the Middle Ages to preserve knowledge?',
          options: [
            'Printed books',
            'Copied manuscripts by hand',
            'Built libraries',
            'Used computers'
          ],
          correctIndex: 1,
          funFact:
              'Before printing, monks spent years carefully copying books by hand! 📖',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 4,
      title: 'Age of Exploration',
      icon: '⛵',
      starsRequired: 100,
      questions: [
        QuizQuestion(
          question: 'Who is credited with discovering America in 1492?',
          options: [
            'Vasco da Gama',
            'Ferdinand Magellan',
            'Christopher Columbus',
            'Marco Polo'
          ],
          correctIndex: 2,
          funFact:
              'Columbus was actually trying to find a sea route to Asia when he landed in America! 🌎',
        ),
        QuizQuestion(
          question:
              'Which explorer was the first to sail around the whole world?',
          options: ['Columbus', 'Magellan\'s expedition', 'Drake', 'Cook'],
          correctIndex: 1,
          funFact:
              'Magellan died during the voyage, but his crew completed the circumnavigation! ⛵',
        ),
        QuizQuestion(
          question: 'What tool helped sailors navigate the oceans?',
          options: ['Telescope', 'Compass', 'Calculator', 'Map only'],
          correctIndex: 1,
          funFact:
              'The magnetic compass was invented in China and reached Europe around 1190! 🧭',
        ),
      ],
    ),
    GameLevel(
      levelNumber: 5,
      title: 'History Hero',
      icon: '👑',
      starsRequired: 150,
      questions: [
        QuizQuestion(
          question: 'When did World War II end?',
          options: ['1939', '1942', '1945', '1950'],
          correctIndex: 2,
          funFact:
              'WWII ended in 1945 — it involved over 30 countries and 70 million soldiers! 🕊️',
        ),
        QuizQuestion(
          question: 'Who invented the telephone?',
          options: [
            'Thomas Edison',
            'Alexander Graham Bell',
            'Nikola Tesla',
            'Benjamin Franklin'
          ],
          correctIndex: 1,
          funFact:
              'Alexander Graham Bell made the first phone call in 1876 — to his assistant next door! 📞',
        ),
        QuizQuestion(
          question: 'What year did humans first land on the Moon?',
          options: ['1959', '1965', '1969', '1972'],
          correctIndex: 2,
          funFact:
              'Neil Armstrong and Buzz Aldrin landed on the Moon on July 20, 1969! 🌕',
        ),
      ],
    ),
  ];
}
