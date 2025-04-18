import 'package:flutter/material.dart';
import 'control_button.dart';
import '../utils/command_constants.dart';

class MovementPanel extends StatelessWidget {
  final Function(String) onStartContinuousCommand;
  final VoidCallback onStopContinuousCommand;
  final Function(String) onButtonPress;

  const MovementPanel({
    Key? key,
    required this.onStartContinuousCommand,
    required this.onStopContinuousCommand,
    required this.onButtonPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botão W (Frente)
          ControlButton(
            label: 'w',
            icon: Icons.keyboard_arrow_up,
            fontSize: 30,
            backgroundColor: Colors.blue[700],
            onPressed: () => onButtonPress(CommandConstants.moveForward),
            onTapDown: (_) => onStartContinuousCommand(CommandConstants.moveForward),
            onTapUp: (_) => onStopContinuousCommand(),
            onTapCancel: onStopContinuousCommand,
            useTapGesture: true,
          ),
          const SizedBox(height: 10),
          // Botões A, S, D
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlButton(
                label: 'a',
                icon: Icons.keyboard_arrow_left,
                fontSize: 30,
                backgroundColor: Colors.blue[700],
                onPressed: () => onButtonPress(CommandConstants.moveLeft),
                onTapDown: (_) => onStartContinuousCommand(CommandConstants.moveLeft),
                onTapUp: (_) => onStopContinuousCommand(),
                onTapCancel: onStopContinuousCommand,
                useTapGesture: true,
              ),
              const SizedBox(width: 10),
              ControlButton(
                label: 's',
                icon: Icons.keyboard_arrow_down,
                fontSize: 30,
                backgroundColor: Colors.blue[700],
                onPressed: () => onButtonPress(CommandConstants.moveBackward),
                onTapDown: (_) => onStartContinuousCommand(CommandConstants.moveBackward),
                onTapUp: (_) => onStopContinuousCommand(),
                onTapCancel: onStopContinuousCommand,
                useTapGesture: true,
              ),
              const SizedBox(width: 10),
              ControlButton(
                label: 'd',
                icon: Icons.keyboard_arrow_right,
                fontSize: 30,
                backgroundColor: Colors.blue[700],
                onPressed: () => onButtonPress(CommandConstants.moveRight),
                onTapDown: (_) => onStartContinuousCommand(CommandConstants.moveRight),
                onTapUp: (_) => onStopContinuousCommand(),
                onTapCancel: onStopContinuousCommand,
                useTapGesture: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 