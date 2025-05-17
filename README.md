# Arduino Controller

Aplicativo Flutter para controle de um carrinho Arduino via Bluetooth (HM-10).

## Funcionalidades

- Controle de movimento (WASD)
- Controle de ataque
- Controle dos faróis
- Escaneamento de dispositivos Bluetooth
- Configuração manual do endereço MAC
- Interface otimizada para uso horizontal
- Desconexão automática ao sair do app

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

## Como Usar

### Método 1: Escaneamento Automático
1. Abra o aplicativo
2. Aguarde o escaneamento de dispositivos Bluetooth
3. Selecione seu dispositivo na lista
4. Na tela de controle, clique no botão "Conectar" na parte superior
5. Aguarde a conexão ser estabelecida, caso não conecte aperte novamente

### Método 2: Configuração Manual do MAC
1. Abra o aplicativo
2. Clique no ícone de engrenagem na tela de escaneamento
3. Digite o endereço MAC do seu dispositivo no formato XX:XX:XX:XX:XX:XX
4. Clique em "Conectar"
5. Na tela do controle, clique no botão "Conectar" na parte superior
6. Aguarde a conexão ser estabelecida, caso não conecte aperte novamente

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
4. Tente reconectar usando o botão "Conectar" no painel de controle
5. Verifique se o Arduino está energizado
6. Se o problema persistir, tente:
   - Desconectar e reconectar o dispositivo
   - Reiniciar o aplicativo
   - Verificar se o dispositivo está no alcance

## Arduino

O código do Arduino correspondente está disponível em `arduino/ard.cpp`
