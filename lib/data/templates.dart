class CardTemplate {
  const CardTemplate({
    required this.actionLabel,
    required this.goalLabel,
    required this.area,
  });

  final String actionLabel;
  final String goalLabel;
  final String area;
}

const List<CardTemplate> starterTemplates = [
  // Movement
  CardTemplate(
    area: 'Movement',
    actionLabel: 'Put on my running shoes',
    goalLabel: 'Move more',
  ),
  CardTemplate(
    area: 'Movement',
    actionLabel: 'Fill my water bottle',
    goalLabel: 'Stay hydrated',
  ),
  CardTemplate(
    area: 'Movement',
    actionLabel: 'Step outside for five minutes',
    goalLabel: 'Get fresh air',
  ),
  CardTemplate(
    area: 'Movement',
    actionLabel: 'Do five push-ups',
    goalLabel: 'Build strength',
  ),
  CardTemplate(
    area: 'Movement',
    actionLabel: 'Lay out my workout clothes for tomorrow',
    goalLabel: 'Exercise regularly',
  ),

  // Focus
  CardTemplate(
    area: 'Focus',
    actionLabel: 'Open the document and write one sentence',
    goalLabel: 'Make progress on work',
  ),
  CardTemplate(
    area: 'Focus',
    actionLabel: 'Clear my desk surface',
    goalLabel: 'Focus better',
  ),
  CardTemplate(
    area: 'Focus',
    actionLabel: 'Put my phone in another room',
    goalLabel: 'Focus better',
  ),
  CardTemplate(
    area: 'Focus',
    actionLabel: 'Write down three things I need to do today',
    goalLabel: 'Stay organised',
  ),
  CardTemplate(
    area: 'Focus',
    actionLabel: 'Close all browser tabs I don\'t need',
    goalLabel: 'Focus better',
  ),

  // Connection
  CardTemplate(
    area: 'Connection',
    actionLabel: 'Send one message I\'ve been putting off',
    goalLabel: 'Maintain relationships',
  ),
  CardTemplate(
    area: 'Connection',
    actionLabel: 'Reply to one email',
    goalLabel: 'Keep up with communication',
  ),
  CardTemplate(
    area: 'Connection',
    actionLabel: 'Text someone I haven\'t talked to in a while',
    goalLabel: 'Stay connected',
  ),
  CardTemplate(
    area: 'Connection',
    actionLabel: 'Write three things I\'m grateful for',
    goalLabel: 'Practice gratitude',
  ),
  CardTemplate(
    area: 'Connection',
    actionLabel: 'Check in on someone who might need it',
    goalLabel: 'Be a good friend',
  ),

  // Rest
  CardTemplate(
    area: 'Rest',
    actionLabel: 'Dim the lights and put my phone down',
    goalLabel: 'Sleep better',
  ),
  CardTemplate(
    area: 'Rest',
    actionLabel: 'Make a cup of tea and sit quietly',
    goalLabel: 'Rest more',
  ),
  CardTemplate(
    area: 'Rest',
    actionLabel: 'Set a bedtime alarm and close work apps',
    goalLabel: 'Sleep better',
  ),
  CardTemplate(
    area: 'Rest',
    actionLabel: 'Take five slow deep breaths',
    goalLabel: 'Reduce stress',
  ),
  CardTemplate(
    area: 'Rest',
    actionLabel: 'Tidy one small area of my space',
    goalLabel: 'Feel at home',
  ),
];

const List<String> templateAreas = ['Movement', 'Focus', 'Connection', 'Rest'];
