# Arduino Controller

Aplicativo Flutter para controle de um carrinho Arduino via Bluetooth (HM-10).

## Funcionalidades

- Controle de movimento (WASD)
- Controle de ataque
- Controle dos faróis
- Conexão Bluetooth automática
- Interface otimizada para uso horizontal

## Requisitos

- Flutter 3.x
- Android SDK
- Módulo Bluetooth HM-10
- Arduino com código compatível

## Configuração

1. Clone o repositório (git clone https://github.com/mathazel/arduinocontroller)
2. Execute `flutter pub get`
3. Configure o endereço MAC do seu HM-10 no arquivo `lib/main.dart`
4. Execute o app com `flutter run`

## Permissões Necessárias

- Bluetooth
- Bluetooth Admin
- Bluetooth Scan
- Bluetooth Connect
- Location (necessário para Bluetooth Low Energy)

## Troubleshooting

Se encontrar problemas:
1. Verifique se o Bluetooth está ativado
2. Confirme se o endereço MAC está correto
3. Certifique-se que todas as permissões foram concedidas
4. Tente reconectar usando o botão de reconectar
5. Verifique se o Arduino está energizado

## Arduino

O código do Arduino correspondente está disponível em `arduino/ard.cpp`
