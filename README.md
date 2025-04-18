# Arduino Controller

Aplicativo Flutter para controle de um carrinho Arduino via Bluetooth (HM-10).

## Funcionalidades

- Controle de movimento (WASD)
- Controle de ataque
- Controle dos faróis
- Conexão Bluetooth automática
- Interface otimizada para uso horizontal
- Configuração de endereço MAC

## Requisitos

- Flutter 3.x
- Android SDK
- Módulo Bluetooth HM-10
- Arduino com código compatível

## Dependências

- flutter_blue_plus: ^1.14.1
- permission_handler: ^11.3.0
- shared_preferences: ^2.2.2
- cupertino_icons: ^1.0.2

## Configuração

1. Clone o repositório (git clone https://github.com/mathazel/arduinocontroller)
2. Execute `flutter pub get`
3. Configure o endereço MAC do seu dispositivo HM-10 na tela de configuração
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
4. Tente reconectar usando o botão de reconectar no painel do controle
5. Verifique se o Arduino está energizado

## Arduino

O código do Arduino correspondente está disponível em `arduino/ard.cpp`
