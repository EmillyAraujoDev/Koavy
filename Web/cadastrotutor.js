document.addEventListener("DOMContentLoaded", () => {
<<<<<<< HEAD
=======

>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
    console.log("JS tutor carregado");

    const form = document.getElementById("tutor_form");
    const mensagem = document.getElementById("mensagemTutor");
<<<<<<< HEAD
    const pacienteIdInput = document.getElementById("pacienteId");

    if (!form) return;

    // Tenta pegar ID do sessionStorage para preencher automaticamente
    const pacienteIdSalvo = sessionStorage.getItem("pacienteId");
    if (pacienteIdSalvo && pacienteIdInput) {
        pacienteIdInput.value = pacienteIdSalvo;
        console.log("ID preenchido do sessionStorage:", pacienteIdSalvo);
=======

    // 🔥 proteção contra página errada
    if (!form) {
        console.warn("Form tutor_form não encontrado");
        return;
    }

    // 🔥 pega ID salvo
    const pacienteIdSalvo = sessionStorage.getItem("pacienteId");
    console.log("Paciente ID:", pacienteIdSalvo);

    if (!pacienteIdSalvo) {
        alert("Paciente não encontrado. Faça o cadastro primeiro.");
        window.location.href = "cadastro.html";
        return;
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

<<<<<<< HEAD
        const nomeInput = document.getElementById("nomeTutor");
        const dataInputEl = document.getElementById("dataVinculo");

        const nome = nomeInput.value.trim();
        const pacienteId = pacienteIdInput.value.trim();
        const dataInput = dataInputEl ? dataInputEl.value : null;

        if (!nome || !pacienteId) {
            exibirMensagem("❌ Preencha seu nome e o ID do Paciente", true);
=======
        console.log("Submit disparado");

        const nomeInput = document.getElementById("nomeTutor");
        const dataInputEl = document.getElementById("dataVinculo");

        if (!nomeInput) {
            console.error("Campo nomeTutor não encontrado");
            return;
        }

        const nome = nomeInput.value.trim();
        const dataInput = dataInputEl ? dataInputEl.value : null;

        if (!nome) {
            exibirMensagem("❌ Nome obrigatório", true);
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
            return;
        }

        const vinculo = {
            nome,
<<<<<<< HEAD
            pacienteId: Number(pacienteId),
=======
            pacienteId: Number(pacienteIdSalvo),
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
            dataVinculo: dataInput ? new Date(dataInput).toISOString() : null,
            principal: false
        };

<<<<<<< HEAD
        const btn = document.getElementById("btnTutor");
        const originalText = btn.innerText;
        btn.disabled = true;
        btn.innerText = "Vinculando...";

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/api/vinculos`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(vinculo)
            });

            if (response.ok) {
                exibirMensagem("✔ Tutor vinculado com sucesso!", false);
                setTimeout(() => {
                    form.reset();
                    sessionStorage.removeItem("pacienteId");
                    window.location.href = "login.html"; // Redireciona para login após sucesso
                }, 2000);
            } else {
                const texto = await response.text();
                exibirMensagem("❌ " + (texto || "Erro ao salvar vínculo"), true);
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
=======
        console.log("Enviando:", vinculo);

        try {
            const response = await fetch("http://localhost:8080/api/vinculos", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(vinculo)
            });

            console.log("Status:", response.status);

            let texto = "";
            try {
                texto = await response.text();
            } catch {
                texto = "";
            }

            console.log("Resposta:", texto);

            if (response.ok) {
                exibirMensagem("✔ Tutor vinculado com sucesso!", false);

                // delay pra usuário ver mensagem
                setTimeout(() => {
                    form.reset();
                    sessionStorage.removeItem("pacienteId");
                }, 1500);

            } else {
                exibirMensagem("❌ " + (texto || "Erro ao salvar"), true);
            }

        } catch (err) {
            console.error("Erro fetch:", err);
            exibirMensagem("❌ Erro de conexão com a API", true);
        }
    });

    // 🔥 função segura pra mostrar mensagem
    function exibirMensagem(msg, erro = false) {
        if (mensagem) {
            mensagem.innerHTML = msg;
            mensagem.style.color = erro ? "red" : "green";
        } else {
            alert(msg); // fallback
        }
    }

});
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
