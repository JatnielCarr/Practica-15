class AssetManager {
  // Aliens (Enemigos)
  static const String alienGreenRound = 'assets/PNG/Aliens/alienGreen_round.png';
  static const String alienBlueRound = 'assets/PNG/Aliens/alienBlue_round.png';
  static const String alienPinkRound = 'assets/PNG/Aliens/alienPink_round.png';
  static const String alienYellowRound = 'assets/PNG/Aliens/alienYellow_round.png';
  static const String alienBeigeRound = 'assets/PNG/Aliens/alienBeige_round.png';
  
  // Backgrounds
  static const String bgBlueGrass = 'assets/PNG/Backgrounds/blue_grass.png';
  static const String bgBlueLand = 'assets/PNG/Backgrounds/blue_land.png';
  static const String bgColoredGrass = 'assets/PNG/Backgrounds/colored_grass.png';
  static const String bgColoredLand = 'assets/PNG/Backgrounds/colored_land.png';
  
  // Wood Elements (Bloques de madera)
  static const String woodBlock1 = 'assets/PNG/Wood elements/elementWood000.png';
  static const String woodBlock2 = 'assets/PNG/Wood elements/elementWood001.png';
  static const String woodBlock3 = 'assets/PNG/Wood elements/elementWood014.png';
  static const String woodBlock4 = 'assets/PNG/Wood elements/elementWood015.png';
  static const String woodBlockSquare = 'assets/PNG/Wood elements/elementWood020.png';
  static const String woodBlockRect = 'assets/PNG/Wood elements/elementWood021.png';
  
  // Stone Elements (Bloques de piedra)
  static const String stoneBlock1 = 'assets/PNG/Stone elements/elementStone000.png';
  static const String stoneBlock2 = 'assets/PNG/Stone elements/elementStone001.png';
  static const String stoneBlock3 = 'assets/PNG/Stone elements/elementStone014.png';
  static const String stoneBlock4 = 'assets/PNG/Stone elements/elementStone015.png';
  static const String stoneBlockSquare = 'assets/PNG/Stone elements/elementStone020.png';
  static const String stoneBlockRect = 'assets/PNG/Stone elements/elementStone021.png';
  
  // Explosive Elements (Para el pájaro o efectos especiales)
  static const String birdRed = 'assets/PNG/Explosive elements/elementExplosive028.png'; // Bola roja
  static const String birdYellow = 'assets/PNG/Explosive elements/elementExplosive029.png'; // Bola amarilla
  static const String birdBlue = 'assets/PNG/Explosive elements/elementExplosive034.png'; // Bola azul
  
  // Debris (Partículas)
  static const List<String> debrisWood = [
    'assets/PNG/Debris/debrisWood_1.png',
    'assets/PNG/Debris/debrisWood_2.png',
    'assets/PNG/Debris/debrisWood_3.png',
    'assets/PNG/Debris/debrisWood_4.png',
  ];
  
  static const List<String> debrisStone = [
    'assets/PNG/Debris/debrisStone_1.png',
    'assets/PNG/Debris/debrisStone_2.png',
    'assets/PNG/Debris/debrisStone_3.png',
    'assets/PNG/Debris/debrisStone_4.png',
  ];
  
  // Método helper para obtener alien aleatorio
  static List<String> get alienImages => [
    alienGreenRound,
    alienBlueRound,
    alienPinkRound,
    alienYellowRound,
    alienBeigeRound,
  ];
  
  // Método helper para obtener bloques de madera
  static List<String> get woodBlocks => [
    woodBlock1,
    woodBlock2,
    woodBlock3,
    woodBlock4,
    woodBlockSquare,
    woodBlockRect,
  ];
  
  // Método helper para obtener bloques de piedra
  static List<String> get stoneBlocks => [
    stoneBlock1,
    stoneBlock2,
    stoneBlock3,
    stoneBlock4,
    stoneBlockSquare,
    stoneBlockRect,
  ];
}
