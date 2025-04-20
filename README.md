# Arduino Controller

Aplicativo Flutter para controle de um carrinho Arduino via Bluetooth (HM-10).

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
- Arduino com código parecido com o do `arduino/ard.cpp`

## Configuração

- Clone o repositório (git clone https://github.com/mathazel/arduinocontroller)
- Execute `flutter pub get`
- Execute `flutter run`

## Configurações APP
- Coloque o endereço MAC do seu módulo HM-10/HM-05 etc...
- Aperte em Conectar
- Assim q estiver na interface do controle aperte em reconectar 2 vezes e aguarde

## Permissões Necessárias do app

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
