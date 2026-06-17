# Koavy Frontend - Interface Web

Interface de usuário para o sistema Koavy, focada em simplicidade e acessibilidade para pacientes cardíacos e seus tutores.

## 🎨 Design e UI
- **Estética:** Clean e intuitiva, com foco em legibilidade.
- **Feedback Visual:** Uso de cores para indicar estados de emergência.

## 💻 Tecnologias
- HTML5 Semântico.
- CSS3 (Flexbox/Grid).
- JavaScript Moderno (Async/Await, Fetch API).

## 🔑 Funcionalidades
- **Login/Cadastro:** Fluxos diferenciados para Paciente, Tutor e Admin.
- **Dashboard:** Visualização de batimentos cardíacos e pressão.
- **Gestão:** Administração de perfis e relatórios médicos.

## 🚀 Como rodar
Por ser uma aplicação estática, basta abrir o arquivo `login.html` em um navegador, ou utilizar um servidor simples:
```bash
python3 -m http.server 8000
```

## 📝 Notas de Desenvolvimento
- As chamadas de API estão apontando para `localhost:8080`.
- O estado da sessão é mantido via `localStorage`.
