document.addEventListener("DOMContentLoaded", () => {
    console.log("JS tutor carregado");

    const form = document.getElementById("tutor_form");
    const mensagem = document.getElementById("mensagemTutor");
    const pacienteIdInput = document.getElementById("pacienteId");
    const cadastroTutorFields = document.getElementById("cadastroTutorFields");

    if (!form) return;

    // Verificar se o usuário já está logado como tutor
    const loggedUser = typeof Auth !== 'undefined' ? Auth.getUser() : null;
    const isLoggedTutor = loggedUser && parseInt(loggedUser.perfil_id || loggedUser.perfilId) === 2;

    if (isLoggedTutor && cadastroTutorFields) {
        cadastroTutorFields.style.display = "none";
        console.log("Tutor já logado. Ocultando campos de cadastro.");
    }

    // Tenta pegar ID do sessionStorage para preencher automaticamente
    const pacienteIdSalvo = sessionStorage.getItem("pacienteId");
    if (pacienteIdSalvo && pacienteIdInput) {
        pacienteIdInput.value = pacienteIdSalvo;
        console.log("ID preenchido do sessionStorage:", pacienteIdSalvo);
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const pacienteId = pacienteIdInput.value.trim();
        const dataInputEl = document.getElementById("dataVinculo");
        const dataInput = dataInputEl ? dataInputEl.value : null;

        if (!pacienteId) {
            exibirMensagem("❌ Preencha o ID do Paciente", true);
            return;
        }

        let vinculo = {
            pacienteId: Number(pacienteId),
            dataVinculo: dataInput ? new Date(dataInput).toISOString().slice(0, 19).replace('T', ' ') : null,
            principal: false
        };

        // Se NÃO estiver logado como tutor, exige e adiciona as novas credenciais
        if (!isLoggedTutor) {
            const nomeTutor = document.getElementById("nomeTutor").value.trim();
            const emailTutor = document.getElementById("emailTutor").value.trim();
            const senhaTutor = document.getElementById("senhaTutor").value;
            const telefoneTutor = document.getElementById("telefoneTutor").value.trim();

            if (!nomeTutor || !emailTutor || !senhaTutor) {
                exibirMensagem("❌ Por favor, preencha Nome, E-mail e Senha para criar sua conta.", true);
                return;
            }

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(emailTutor)) {
                exibirMensagem("❌ Formato de e-mail inválido.", true);
                return;
            }

            if (senhaTutor.length < 8) {
                exibirMensagem("❌ A senha deve conter no mínimo 8 caracteres.", true);
                return;
            }

            vinculo.nome = nomeTutor;
            vinculo.email = emailTutor;
            vinculo.senha = senhaTutor;
            vinculo.telefone = telefoneTutor;
        }

        const btn = document.getElementById("btnTutor");
        const originalText = btn.innerText;
        btn.disabled = true;
        btn.innerText = "Vinculando...";

        try {
            const headers = { "Content-Type": "application/json" };
            if (typeof Auth !== 'undefined' && Auth.getToken()) {
                headers['Authorization'] = `Bearer ${Auth.getToken()}`;
            }

            const response = await fetch(`${CONFIG.API_BASE_URL}/vinculos`, {
                method: "POST",
                headers: headers,
                body: JSON.stringify(vinculo)
            });

            const result = await response.json();

            if (response.ok) {
                exibirMensagem("✔ Vínculo realizado com sucesso!", false);
                setTimeout(() => {
                    form.reset();
                    sessionStorage.removeItem("pacienteId");
                    
                    if (isLoggedTutor) {
                        window.location.href = "dashboard_tutor.html";
                    } else {
                        window.location.href = "login.html"; 
                    }
                }, 2000);
            } else {
                exibirMensagem("❌ " + (result.message || "Erro ao salvar vínculo"), true);
            }
        } catch (err) {
            console.error("Erro fetch:", err);
            exibirMensagem("❌ Erro de conexão com o servidor", true);
        } finally {
            btn.disabled = false;
            btn.innerText = originalText;
        }
    });

    function exibirMensagem(msg, erro = false) {
        if (mensagem) {
            mensagem.innerHTML = msg;
            mensagem.className = `mb-6 p-4 rounded-xl text-sm font-bold text-center ${erro ? 'bg-red-500/10 text-red-500 border border-red-500/20' : 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20'}`;
        } else {
            alert(msg);
        }
    }
});
