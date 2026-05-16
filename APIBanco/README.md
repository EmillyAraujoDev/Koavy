# Koavy API - Backend

Esta é a API REST central do sistema Koavy, construída para gerenciar o fluxo de dados de saúde e autenticação de usuários.

## 🛠️ Stack Técnica
- **Linguagem:** Java 17
- **Framework:** Spring Boot 3.x/4.x
- **Persistência:** Spring Data JPA / Hibernate
- **Banco de Dados:** MySQL

## 📂 Organização de Pacotes
- `controller/`: Exposição dos endpoints REST e tratamento de requisições.
- `model/`: Entidades JPA que representam as tabelas do banco.
- `repository/`: Interfaces de abstração de dados (Spring Data).

## 🚦 Endpoints Principais
- `POST /api/usuarios/cadastro`: Registro de novos usuários.
- `POST /api/usuarios/login`: Autenticação simples.
- `GET /api/usuarios`: Listagem geral (Admin).
- `GET /api/batimentos`: Consulta de histórico de sinais vitais.

## ⚙️ Configuração
1. Certifique-se de ter o MySQL rodando.
2. Edite `src/main/resources/application.properties` com suas credenciais.
3. Execute `./mvnw spring-boot:run`.

## ⚠️ Observações de Segurança (Aviso de Arquiteto)
- A autenticação atual utiliza comparação de texto plano. **Não utilize em produção**.
- Recomenda-se a implementação de Spring Security com JWT.
