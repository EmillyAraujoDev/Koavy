# Plano de Implementação - Projeto Koavy

Este documento detalha a reestruturação e implementação completa do sistema Koavy.

## 1. Arquitetura do Sistema

### Fluxo de Dados
1.  **ESP32/Arduino:** Coleta BPM -> Envia via HTTPS POST (JSON) para `/api/batimentos`.
2.  **API PHP:** Recebe dados -> Valida JWT do dispositivo/usuário -> Salva no MySQL -> Processa Anomalias.
3.  **Detecção de Anomalias:** Compara BPM com limites (Min/Max) -> Se crítico, cria registro em `alertas` e `emergencia`.
4.  **Notificações:** API envia Push via Firebase (FCM) para o Tutor/Paciente.
5.  **Frontend (Web/Mobile):** Consome APIs para exibir dados em tempo real e gerar relatórios.

### Tecnologias
- **Backend:** PHP 8.x (Slim Framework ou MVC Customizado), JWT para Auth.
- **Banco de Dados:** MySQL.
- **Frontend Web:** Vanilla JS (melhorado com Chart.js, Axios, jsPDF).
- **Mobile:** Flutter (Dio, Provider, FL Chart).
- **IoT:** C++ (ESP32/Arduino).

---

## 2. Banco de Dados (Refinamento)

### Novas Tabelas / Alterações:
- `configuracoes_cardiacas`: Armazena limites personalizados por usuário.
- `dispositivos`: Vincula pulseiras (MAC Address/Token) a usuários.
- `logs_auditoria`: Rastreia ações críticas no sistema.

---

## 3. API PHP (Endpoints)

### Auth
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh`

### Batimentos
- `POST /batimentos` (Uso pelo ESP32)
- `GET /batimentos/realtime/{userId}`
- `GET /batimentos/historico/{userId}`

### Alertas & Emergência
- `GET /alertas`
- `POST /emergencia/localizacao` (Atualiza GPS em tempo real)

---

## 4. Implementação por Etapas

### Etapa 1: Backend PHP & DB
1.  Criar estrutura de pastas `api/`.
2.  Configurar roteamento e Middleware de JWT.
3.  Implementar Controllers: `UsuarioController`, `BatimentoController`, `AlertaController`.
4.  Migrar dados do banco atual para a nova estrutura (se necessário).

### Etapa 2: Frontend Web
1.  Atualizar `Web/auth.js` para gerenciar tokens JWT.
2.  Substituir logins "demo" por chamadas reais.
3.  Implementar gráficos dinâmicos com `Chart.js`.
4.  Adicionar exportação de PDF via `jsPDF`.

### Etapa 3: Mobile (Flutter)
1.  Configurar `Dio` com interceptors para JWT.
2.  Implementar Repositories e Providers.
3.  Adicionar suporte a Firebase Messaging.
4.  Remover credenciais hardcoded.

### Etapa 4: IoT (ESP32)
1.  Criar script de exemplo para leitura de sensor e envio JSON.
2.  Implementar lógica de buffer offline.

---

## 5. Verificação e Testes
- Testar fluxo de ponta a ponta: ESP32 -> API -> MySQL -> Dashboard.
- Validar segurança (tentativa de acesso sem token).
- Simular anomalias e verificar disparo de notificações.
