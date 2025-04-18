import 'package:flutter/material.dart';
import 'control_button.dart';
import '../utils/command_constants.dart';

class ActionPanel extends StatelessWidget {
  final Function(String) onCommandSend;
  final VoidCallback onReconnect;

  const ActionPanel({
    Key? key,
    required this.onCommandSend,
    required this.onReconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular tamanho do botão baseado na largura disponível
        final maxWidth = constraints.maxWidth;
        final buttonSize = (maxWidth * 0.15).clamp(40.0, 80.0);
        final spacingFactor = maxWidth * 0.03;
        
        return Padding(
          padding: EdgeInsets.all(spacingFactor),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Y no topo
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: spacingFactor * 1.5),
                  child: ControlButton(
                    label: 'Y',
                    height: buttonSize,
                    width: buttonSize,
                    backgroundColor: Colors.yellow[700],
                    onPressed: () => onCommandSend(CommandConstants.lightsOn),
                    borderRadius: buttonSize / 2,
                    shadowColor: Colors.yellow[900],
                  ),
                ),
              ),
              
              // X e B na linha do meio com espaçamento melhorado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: buttonSize * 0.7),
                    child: ControlButton(
                      label: 'X',
                      height: buttonSize,
                      width: buttonSize,
                      backgroundColor: Colors.blue[600],
                      onPressed: () => onCommandSend(CommandConstants.lightsOff),
                      borderRadius: buttonSize / 2,
                      shadowColor: Colors.blue[900],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: buttonSize * 0.7),
                    child: ControlButton(
                      label: 'B',
                      height: buttonSize,
                      width: buttonSize,
                      backgroundColor: Colors.red[600],
                      onPressed: () => onCommandSend(CommandConstants.attack),
                      borderRadius: buttonSize / 2,
                      shadowColor: Colors.red[900],
                    ),
                  ),
                ],
              ),
              
              // A na parte inferior
              Padding(
                padding: EdgeInsets.only(top: spacingFactor * 1.5),
                child: ControlButton(
                  label: 'A',
                  height: buttonSize,
                  width: buttonSize,
                  backgroundColor: Colors.green[600],
                  onPressed: () => onCommandSend(CommandConstants.stop),
                  borderRadius: buttonSize / 2,
                  shadowColor: Colors.green[900],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}