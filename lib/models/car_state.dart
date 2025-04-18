class CarState {
  final bool isMovingForward;
  final bool isMovingBackward;
  final bool isMovingLeft;
  final bool isMovingRight;
  final bool isAttacking;
  final bool areLightsOn;

  const CarState({
    this.isMovingForward = false,
    this.isMovingBackward = false,
    this.isMovingLeft = false,
    this.isMovingRight = false,
    this.isAttacking = false,
    this.areLightsOn = false,
  });

  CarState copyWith({
    bool? isMovingForward,
    bool? isMovingBackward,
    bool? isMovingLeft,
    bool? isMovingRight,
    bool? isAttacking,
    bool? areLightsOn,
  }) {
    return CarState(
      isMovingForward: isMovingForward ?? this.isMovingForward,
      isMovingBackward: isMovingBackward ?? this.isMovingBackward,
      isMovingLeft: isMovingLeft ?? this.isMovingLeft,
      isMovingRight: isMovingRight ?? this.isMovingRight,
      isAttacking: isAttacking ?? this.isAttacking,
      areLightsOn: areLightsOn ?? this.areLightsOn,
    );
  }

  bool get isMoving => isMovingForward || isMovingBackward || isMovingLeft || isMovingRight;

  @override
  String toString() {
    return 'CarState{isMovingForward: $isMovingForward, isMovingBackward: $isMovingBackward, isMovingLeft: $isMovingLeft, isMovingRight: $isMovingRight, isAttacking: $isAttacking, areLightsOn: $areLightsOn}';
  }
} 