# Plano de Reestruturação Profissional Koavy

Este plano descreve as etapas para transformar o Koavy em uma aplicação de padrão profissional para TCC e mercado.

## 1. Auditoria e Correção de Autenticação
- **Google Login (Mobile):** 
    - [ ] Criar/Validar `google-services.json` no Firebase Console.
    - [ ] Adicionar SHA-1 e SHA-256 no Firebase Console.
    - [ ] Corrigir Client IDs no `UsuarioController.php`.
- **Google Login (Web):**
    - [ ] Configurar Authorized JavaScript Origins (e.g., `http://localhost`, `http://143.106.241.4`).
    - [ ] Validar Consent Screen e usuários de teste.
- **Fluxo de Recuperação de Senha:**
    - [ ] Implementar `sendPasswordResetEmail()` no Flutter.
    - [ ] Criar página `redefinir-senha.html` profissional com Tailwind.

## 2. Modernização de UI/UX (Design Premium)
- **Web (Tailwind CSS):**
    - [ ] Reconstruir Navbar com Glassmorphism, Blur e animações.
    - [ ] Adicionar "Cadastrar" na Navbar.
    - [ ] Padronizar cores (Dark Mode, Neon Cyan).
    - [ ] Implementar animações com CSS Transitions e Framer Motion (opcional se mantiver HTML/JS).
- **Mobile (Flutter):**
    - [ ] Criar Drawer moderno com ícones, avatar e links completos.
    - [ ] Adicionar `flutter_animate` para transições suaves.
    - [ ] Corrigir todos os erros de responsividade (Overflow).

## 3. Funcionalidades e Dashboards
- **Dashboards:**
    - [ ] Admin: Implementar contadores e gráficos de estatísticas.
    - [ ] Paciente: Implementar visualização de BPM em tempo real (Mock/Real).
    - [ ] Tutor: Implementar vínculo e alertas.
- **Relatórios e Exames:**
    - [ ] Implementar geração de PDF (jsPDF para Web, pdf package para Flutter).
    - [ ] Fluxo de Upload/Download de PDF de exames.

## 4. Limpeza e Qualidade de Código
- [ ] Remover código duplicado.
- [ ] Limpar imports não utilizados.
- [ ] Executar `dart fix --apply` e `flutter analyze`.
- [ ] Garantir que todos os botões tenham ações mapeadas.

## 5. Cronograma de Execução
1.  **Dia 1:** Correção Google Login e Fluxo de Autenticação.
2.  **Dia 2:** UI/UX Premium (Web & Mobile).
3.  **Dia 3:** Dashboards e Relatórios.
4.  **Dia 4:** Limpeza final e Testes.
