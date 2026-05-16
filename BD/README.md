# Koavy Database - Modelagem de Dados

Este diretório contém os artefatos de banco de dados para o sistema Koavy.

## 📊 Esquema Relacional
O banco utiliza MySQL e é composto pelas seguintes tabelas:
1. `perfis`: Níveis de acesso (PACIENTE, TUTOR, ADMIN).
2. `usuarios`: Dados cadastrais e credenciais.
3. `tutor_paciente`: Tabela de relacionamento N:N entre responsáveis e pacientes.
4. `batimentos`: Histórico de telemetria de saúde.
5. `emergencia`: Registro de alertas e geolocalização.
6. `relatorios`: Dados consolidados para análise médica.

## 🛠️ Instalação
1. Crie um banco de dados chamado `bancokoavy`.
2. Execute o script `BancoKoavy.sql`.
   ```bash
   mysql -u seu_usuario -p bancokoavy < BancoKoavy.sql
   ```

## 🧠 Decisões de Modelagem
- Uso de `ENUM` para campos fixos (`sexo`, `tipo_sanguineo`) para garantir integridade.
- Índices compostos em `batimentos` para otimizar buscas por data e usuário.
- Chaves estrangeiras com `ON DELETE CASCADE` para manutenção da consistência.
