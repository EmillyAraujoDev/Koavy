document.addEventListener("DOMContentLoaded", () => {
<<<<<<< HEAD
    const API = CONFIG.API_BASE_URL;
    const form = document.getElementById("formCadastro");
    const erroMsg = document.getElementById("mensagemErro");
    const sucessoMsg = document.getElementById("mensagemSucesso");
    const submitBtn = form?.querySelector('button[type="submit"]');
=======
    const API = "http://localhost:8080";
    const form = document.getElementById("formCadastro");
    const erroMsg = document.getElementById("mensagemErro");
    const sucessoMsg = document.getElementById("mensagemSucesso");
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27

    if (!form) return;

    // Utilitário de idade
    function calcularIdade(dataNascimento) {
        if (!dataNascimento) return null;
        const hoje = new Date();
        const nasc = new Date(dataNascimento);
        let idade = hoje.getFullYear() - nasc.getFullYear();
        const m = hoje.getMonth() - nasc.getMonth();
        if (m < 0 || (m === 0 && hoje.getDate() < nasc.getDate())) {
            idade--;
        }
        return idade;
    }

    // Feedback Visual
    function mostrarFeedback(msg, tipo) {
        if (tipo === 'erro') {
            erroMsg.innerText = msg;
            erroMsg.classList.remove('hidden');
            sucessoMsg.classList.add('hidden');
        } else {
            sucessoMsg.innerHTML = msg;
            sucessoMsg.classList.remove('hidden');
            erroMsg.classList.add('hidden');
        }
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        
        const dataNascValue = document.getElementById("dataNascimento").value;
<<<<<<< HEAD
        const email = document.getElementById("email").value.trim();
        const senha = document.getElementById("senha").value.trim();
        const nome = document.getElementById("nome").value.trim();

        // Validação Robusta
        let erros = [];
        if (nome.length < 3) erros.push("Nome muito curto.");
        
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) erros.push("E-mail inválido.");
        
        if (senha.length < 8) erros.push("A senha deve ter no mínimo 8 caracteres.");
        if (!/[A-Z]/.test(senha) || !/[0-9]/.test(senha)) {
            erros.push("A senha deve conter pelo menos uma letra maiúscula e um número.");
        }

        if (erros.length > 0) {
            mostrarFeedback(erros.join("<br>"), "erro");
            return;
        }
=======
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
        
        const usuario = {
            perfilId: 1,
            ativo: true,
<<<<<<< HEAD
            nome: nome,
            email: email,
            senha: senha,
=======
            nome: document.getElementById("nome").value.trim(),
            email: document.getElementById("email").value.trim(),
            senha: document.getElementById("senha").value.trim(),
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
            telefone: document.getElementById("telefone").value.trim(),
            dataNascimento: dataNascValue || null,
            idade: calcularIdade(dataNascValue),
            peso: Number(document.getElementById("peso").value) || null,
            altura: Number(document.getElementById("altura").value) || null,
            sexo: document.getElementById("sexo").value,
            tipoSanguineo: document.getElementById("tipoSanguineo").value.trim(),
<<<<<<< HEAD
            marcapasso: document.getElementById("marcapasso").value === "true",
=======
            marcapasso: document.getElementById("marcapasso").value,
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
            cep: document.getElementById("cep").value.trim(),
            obsMed: document.getElementById("obsMed").value.trim()
        };

<<<<<<< HEAD
        // Feedback de carregamento
        submitBtn.disabled = true;
        const originalText = submitBtn.innerText;
        submitBtn.innerText = "Cadastrando...";
=======
        // Validação básica
        if (!usuario.nome || !usuario.email || !usuario.senha) {
            mostrarFeedback("Preencha os campos obrigatórios (Nome, Email, Senha)", "erro");
            return;
        }
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27

        try {
            const response = await fetch(`${API}/api/usuarios/cadastro`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(usuario)
            });

<<<<<<< HEAD
            const data = await response.json();

            if (response.ok) {
=======
            if (response.ok) {
                const data = await response.json();
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
                const pacienteId = data.id;
                sessionStorage.setItem("pacienteId", pacienteId);
                
                mostrarFeedback(`
                    <div class="flex flex-col gap-2">
<<<<<<< HEAD
                        <span class="text-lg font-bold text-emerald-400">✔ Cadastro realizado!</span>
                        <span>Seu ID de paciente é: <strong class="text-2xl text-white tracking-widest">${pacienteId}</strong></span>
                        <span class="text-xs opacity-70">Guarde este ID para vincular seu tutor.</span>
                        <a href="cadastrotutor.html" class="mt-4 bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-2xl font-black transition text-center">Vincular Tutor Agora</a>
=======
                        <span class="text-lg">✔ Cadastro realizado!</span>
                        <span>Seu ID de paciente é: <strong class="text-xl tracking-widest">${pacienteId}</strong></span>
                        <span class="text-xs opacity-80">Guarde este ID para seu tutor.</span>
                        <a href="cadastrotutor.html" class="mt-4 bg-white text-black py-2 rounded-xl font-bold">Vincular Tutor Agora</a>
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
                    </div>
                `, "sucesso");
                
                form.reset();
<<<<<<< HEAD
                window.scrollTo({ top: 0, behavior: 'smooth' });
            } else {
                mostrarFeedback(data.message || "Erro ao realizar cadastro.", "erro");
=======
            } else {
                const text = await response.text();
                mostrarFeedback(text || "Erro ao realizar cadastro.", "erro");
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
            }
        } catch (err) {
            console.error(err);
            mostrarFeedback("Falha na conexão com o servidor.", "erro");
<<<<<<< HEAD
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerText = originalText;
=======
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
        }
    });
});