# Guia de Configuração - Rede Local (Proxy e Execução)

Este documento detalha o ambiente de desenvolvimento em rede local para a **Lawrence Academy**, permitindo que dispositivos físicos Android se comuniquem com o servidor de desenvolvimento backend hospedado em um PC secundário.

---

## 1. Topologia da Rede Local

O ecossistema é composto pela seguinte infraestrutura:

```text
                  [ Roteador Wi-Fi (Rede Local) ]
                                 |
         +-----------------------+-----------------------+
         | Wi-Fi                                         | Wi-Fi
         ↓                                               ↓
  [ Celular Android ]                             [ PC1 (Gateway) ]
  (Executa App Flutter)                           IP: 192.168.0.15
  URL: http://192.168.0.15:8000                   PortProxy: 8000 -> 192.168.137.149:8000
         |                                               |
         |                                               | Cabo Ethernet
         |                                               ↓
         | (PortProxy redireciona tráfego)        [ PC2 (Servidor) ]
         +--------------------------------------> IP: 192.168.137.149
                                                  (Roda FastAPI/Uvicorn)
```

- **PC2 (Servidor Backend)**:
  - Roda o backend FastAPI/Uvicorn na porta `8000`.
  - IP Local: `192.168.137.149`.
  - Servidor acessível em: `http://192.168.137.149:8000`.
- **PC1 (Gateway Wi-Fi)**:
  - Conectado à rede Wi-Fi e conectado ao PC2 via cabo Ethernet.
  - IP Local na rede Wi-Fi: `192.168.0.15`.
  - Executa um **PortProxy** do Windows para encaminhar requisições da porta `8000` para o PC2.
- **Celular Android (Físico)**:
  - Conectado ao mesmo roteador Wi-Fi.
  - Como não enxerga a sub-rede Ethernet entre o PC1 e o PC2, conecta-se no IP do PC1 (`192.168.0.15`).

---

## 2. Configurando o PortProxy no PC1

Para redirecionar automaticamente as requisições que chegam ao PC1 para o PC2, execute o comando abaixo no **Terminal do Windows (PowerShell/CMD) como Administrador** no **PC1**:

### Adicionar o redirecionamento:
```cmd
netsh interface portproxy add v4tov4 listenaddress=192.168.0.15 listenport=8000 connectaddress=192.168.137.149 connectport=8000
```

### Validar se a regra foi adicionada:
```cmd
netsh interface portproxy show all
```

### Remover o redirecionamento (caso queira desativar):
```cmd
netsh interface portproxy delete v4tov4 listenaddress=192.168.0.15 listenport=8000
```

---

## 3. Configurando o Firewall do Windows no PC1

Certifique-se de que a porta `8000` está liberada no Firewall do PC1 para conexões de entrada. Execute o comando abaixo no terminal como Administrador no **PC1**:

```cmd
netsh advfirewall firewall add rule name="FastAPI 8000" dir=in action=allow protocol=TCP localport=8000
```

---

## 4. Configuração do Flutter (Frontend)

O aplicativo Flutter utiliza a classe `EnvConfig` para gerenciar as URLs de ambiente. Em desenvolvimento (`AppEnvironment.dev`), a URL está configurada permanentemente para o proxy do PC1:

- **Configuração no Arquivo**: `lib/app/config/env_config.dart`
- **Variável**: `apiBaseUrl = "http://192.168.0.15:8000/api/v1"`

### Controle de Tráfego Sem Criptografia (Cleartext Traffic)

- O arquivo `android/app/src/main/AndroidManifest.xml` possui as permissões necessárias para a rede (`INTERNET` e `ACCESS_NETWORK_STATE`).
- O tráfego HTTP puro (sem SSL/TLS) foi configurado **exclusivamente para a versão de desenvolvimento** no arquivo `android/app/src/debug/AndroidManifest.xml` via propriedade `android:usesCleartextTraffic="true"`. A build de produção (release) permanece segura contra conexões HTTP não seguras.

---

## 5. Como Executar a Aplicação

### Executar o Backend (no PC2)
No **PC2**, navegue até a pasta `backend`, ative o ambiente virtual e execute o uvicorn:
```bash
cd backend
python -m venv .venv
# Ativar no Windows (PowerShell):
.venv\Scripts\Activate.ps1
# Instalar dependências:
pip install -r requirements.txt
# Iniciar a API escutando em todas as interfaces do PC2:
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### Executar o Frontend (Celular conectado no PC1)
Conecte seu celular Android físico via cabo USB ao **PC1** (com depuração USB ativa) e execute:
```bash
cd lawrence
flutter pub get
flutter run
```
O aplicativo utilizará automaticamente as rotas da API hospedada no PC2 através do proxy.
