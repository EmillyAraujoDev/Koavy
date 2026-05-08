document.addEventListener("DOMContentLoaded", () => {

    console.log("JS tutor carregado");

    const form = document.getElementById("tutor_form");
    const mensagem = document.getElementById("mensagemTutor");

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
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

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
            return;
        }

        const vinculo = {
            nome,
            pacienteId: Number(pacienteIdSalvo),
            dataVinculo: dataInput ? new Date(dataInput).toISOString() : null,
            principal: false
        };

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