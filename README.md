# Arduino Controller

Aplicativo Flutter para controle de um carrinho Arduino via Bluetooth (HM-10).

## Versão 0.7 - Novidades
- **Tela inicial para configuração de MAC**: Adicionada uma tela de configuração que permite ao usuário inserir o endereço MAC do dispositivo Bluetooth
- **Melhorias na interface do carrinho**: Interface redesenhada para melhor experiência de usuário e controle mais preciso
- **Troubleshooting aprimorado**: Adicionadas novas verificações e mensagens de erro para facilitar a resolução de problemas de conexão
- **Renomeação do app**: Agora o app se chama "Arduino Controller" na tela inicial do dispositivo

## Funcionalidades

- Controle de movimento (WASD)
- Controle de ataque
- Controle dos faróis
- Conexão Bluetooth automática
- Interface otimizada para uso horizontal
- Configuração de endereço MAC

## Ações Disponíveis

| Botão | Ação |
|-------|------|
| Y | Acender faróis: Liga os faróis e lanternas |
| X | Apagar faróis: Desliga os faróis e lanternas |
| B | Ataque: Aciona o braço servo para atacar |
| A | Parar: Interrompe o movimento do carrinho |

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
6. Se o app não se conectar, reinicie o módulo Bluetooth HM-10
7. Verifique o status das luzes LED do módulo para confirmar o funcionamento

## Arduino

O código do Arduino correspondente está disponível em `arduino/ard.cpp`
