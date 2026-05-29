document.addEventListener("DOMContentLoaded", () => {
    const API = CONFIG.API_BASE_URL;
    const form = document.getElementById("formCadastro");
    const erroMsg = document.getElementById("mensagemErro");
    const sucessoMsg = document.getElementById("mensagemSucesso");
    const submitBtn = form?.querySelector('button[type="submit"]');

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
        
        const usuario = {
            perfilId: 1,
            ativo: true,
            nome: nome,
            email: email,
            senha: senha,
            telefone: document.getElementById("telefone").value.trim(),
            dataNascimento: dataNascValue || null,
            idade: calcularIdade(dataNascValue),
            peso: Number(document.getElementById("peso").value) || null,
            altura: Number(document.getElementById("altura").value) || null,
            sexo: document.getElementById("sexo").value,
            tipoSanguineo: document.getElementById("tipoSanguineo").value.trim(),
            marcapasso: document.getElementById("marcapasso").value === "true",
            cep: document.getElementById("cep").value.trim(),
            obsMed: document.getElementById("obsMed").value.trim()
        };

        // Feedback de carregamento
        if (submitBtn) {
            submitBtn.disabled = true;
            var originalText = submitBtn.innerText;
            submitBtn.innerText = "Cadastrando...";
        }

        try {
            const response = await fetch(`${API}/api/usuarios/cadastro`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(usuario)
            });

            const data = await response.json();

            if (response.ok) {
                const pacienteId = data.id;
                sessionStorage.setItem("pacienteId", pacienteId);
                
                mostrarFeedback(`
                    <div class="flex flex-col gap-2">
                        <span class="text-lg font-bold text-emerald-400">✔ Cadastro realizado!</span>
                        <span>Seu ID de paciente é: <strong class="text-2xl text-white tracking-widest">${pacienteId}</strong></span>
                        <span class="text-xs opacity-70">Guarde este ID para vincular seu tutor.</span>
                        <a href="cadastrotutor.html" class="mt-4 bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-2xl font-black transition text-center">Vincular Tutor Agora</a>
                    </div>
                `, "sucesso");
                
                form.reset();
                window.scrollTo({ top: 0, behavior: 'smooth' });
            } else {
                mostrarFeedback(data.message || "Erro ao realizar cadastro.", "erro");
            }
        } catch (err) {
            console.error(err);
            mostrarFeedback("Falha na conexão com o servidor.", "erro");
        } finally {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerText = originalText;
            }
        }
    });
});
