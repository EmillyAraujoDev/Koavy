# Koavy: Monitoramento Cardíaco Inteligente

![Koavy Logo](Web/imagens/heartKoavy.png)

## 📋 Visão Geral
O **Koavy** é uma solução Full-Stack de monitoramento de saúde focada em usuários cardíacos. O projeto integra um dispositivo vestível (emulado via API/Web) que coleta sinais vitais como frequência cardíaca, saturação e pressão arterial, permitindo que tutores e médicos acompanhem o histórico do paciente em tempo real.

## 🏗️ Estrutura do Projeto
O ecossistema é dividido em três componentes principais:

- **[APIBanco/](./APIBanco):** Backend robusto desenvolvido em Java com Spring Boot, responsável pela lógica de negócio, persistência de dados e autenticação.
- **[Web/](./Web):** Frontend responsivo em HTML/CSS/JS para visualização de dashboards, relatórios e gestão de usuários.
- **[BD/](./BD):** Scripts SQL para provisionamento e manutenção do banco de dados relacional (MySQL).

## 🚀 Tecnologias Principais
- **Backend:** Java 17, Spring Boot, Spring Data JPA.
- **Frontend:** Vanilla JavaScript, CSS3 (Modern UI).
- **Database:** MySQL 8.0+.

## 🛠️ Como Iniciar
Consulte os READMEs específicos de cada diretório para instruções detalhadas de configuração:
1. Configure o [Banco de Dados](./BD/README.md).
2. Inicie a [API Spring](./APIBanco/README.md).
3. Abra a [Interface Web](./Web/README.md).

---
*Este projeto é parte de uma iniciativa de saúde digital focada em acessibilidade e prevenção.*
