# Análise Arquitetural - Projeto Koavy

Como arquiteto de software, conduzi uma análise técnica detalhada do sistema Koavy. Abaixo estão os resultados organizados por pilares de engenharia.

## 1. Pontos Fortes
- **Domínio Bem Definido:** A separação de usuários em Pacientes e Tutores atende perfeitamente ao caso de uso de saúde.
- **Modelagem de Dados:** O banco de dados está bem estruturado, utilizando tipos de dados apropriados (`DECIMAL` para precisão, `ENUM` para categorias) e chaves estrangeiras corretas.
- **Simplicidade de Fluxo:** O sistema é direto e cumpre o que promete sem complexidade desnecessária na interface.
- **Uso de JPA/Hibernate:** Facilita a manutenção da persistência e evita SQL Injection nas consultas parametrizadas.

## 2. Pontos Fracos e Riscos
- **Segurança Crítica:** 
    - Senhas são armazenadas e comparadas em texto plano.
    - Ausência de um framework de segurança (como Spring Security).
    - CORS configurado como `*`, o que é um risco em ambientes de produção.
- **Arquitetura de Backend Anêmica:** 
    - O Controller acessa diretamente o Repository. Falta uma camada de **Service** para isolar a lógica de negócio e permitir testes unitários mais eficazes.
- **Escalabilidade:** 
    - O frontend utiliza caminhos hardcoded para a API (`localhost:8080`), o que dificulta o deploy em diferentes ambientes (Staging/Prod).
- **Tratamento de Erros:** 
    - Pouca robustez no tratamento de exceções no backend; erros internos podem expor stacktraces ao frontend.

## 3. Avaliação de Critérios
- **Robustez:** Média. O sistema funciona para o fluxo feliz, mas pode falhar sob condições adversas de entrada de dados.
- **Escalabilidade:** Baixa. A falta de variáveis de ambiente no frontend e a acoplagem no backend exigirão refatoração para crescer.
- **Manutenibilidade:** Média. O código é limpo, mas a falta de divisões de camada (Service) tornará a manutenção difícil conforme a lógica de negócio crescer.
- **Adesão às Boas Práticas:** Regular. Segue os padrões básicos de MVC, mas ignora padrões modernos de segurança e separação de interesses.

## 4. Recomendações
1. **Segurança:** Implementar `BCryptPasswordEncoder` para senhas e adicionar Spring Security com JWT.
2. **Refatoração:** Introduzir `@Service` para encapsular a lógica de login e validações.
3. **Frontend:** Criar um arquivo de configuração/ambiente para a URL da API.
4. **DevOps:** Adicionar um arquivo `docker-compose.yml` para facilitar o setup do ambiente completo (App + MySQL).

---
**Conclusão:** O Koavy é um excelente protótipo funcional (MVP), mas requer uma "blindagem" arquitetural antes de ser considerado pronto para uso real com dados sensíveis de pacientes.
