document.addEventListener("DOMContentLoaded", () => {
    console.log("JS tutor carregado");

    const form = document.getElementById("tutor_form");
    const mensagem = document.getElementById("mensagemTutor");
    const pacienteIdInput = document.getElementById("pacienteId");

    if (!form) return;

    // Tenta pegar ID do sessionStorage para preencher automaticamente
    const pacienteIdSalvo = sessionStorage.getItem("pacienteId");
    if (pacienteIdSalvo && pacienteIdInput) {
        pacienteIdInput.value = pacienteIdSalvo;
        console.log("ID preenchido do sessionStorage:", pacienteIdSalvo);
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const nomeInput = document.getElementById("nomeTutor");
        const dataInputEl = document.getElementById("dataVinculo");

        const nome = nomeInput.value.trim();
        const pacienteId = pacienteIdInput.value.trim();
        const dataInput = dataInputEl ? dataInputEl.value : null;

        if (!nome || !pacienteId) {
            exibirMensagem("❌ Preencha seu nome e o ID do Paciente", true);
            return;
        }

        const vinculo = {
            nome,
            pacienteId: Number(pacienteId),
            dataVinculo: dataInput ? new Date(dataInput).toISOString() : null,
            principal: false
        };

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
