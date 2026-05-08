document.addEventListener("DOMContentLoaded", () => {

    const API = "http://localhost:8080";

    const form = document.getElementById("formCadastro");
    const erroMsg = document.getElementById("mensagemErro");
    const sucessoMsg = document.getElementById("mensagemSucesso");

    // 🔥 proteção contra null (ESSENCIAL)
    if (!form) return;

    const inputs = form.querySelectorAll("input, select, textarea");

    inputs.forEach((input) => {
        input.addEventListener("blur", () => validarCampo(input));
        input.addEventListener("input", () => limparErro(input));
    });

    function setErro(input, mensagem) {
        let span = input.parentNode.querySelector(".erro-campo");

        if (!span) {
            span = document.createElement("span");
            span.classList.add("erro-campo");
            input.parentNode.appendChild(span);
        }

        span.innerText = mensagem;
        input.classList.add("erro");
        input.classList.remove("sucesso");
    }

    function setSucesso(input) {
        let span = input.parentNode.querySelector(".erro-campo");
        if (span) span.innerText = "";

        input.classList.remove("erro");
        input.classList.add("sucesso");
    }

    function limparErro(input) {
        input.classList.remove("erro");
    }

    function validarCampo(input) {
        const valor = input.value.trim();

        if (!valor) return true;

        if (input.name === "email" && !valor.includes("@")) {
            setErro(input, "Email inválido");
            return false;
        }

        if (
            ["idade", "peso", "altura", "telefone", "cep"].includes(input.name) &&
            isNaN(valor)
        ) {
            setErro(input, "Deve ser um número");
            return false;
        }

        if (input.name === "marcapasso") {
            const v = valor.toLowerCase();
            if (!["sim", "não", "nao"].includes(v)) {
                setErro(input, "Digite sim ou não");
                return false;
            }
        }

        setSucesso(input);
        return true;
    }

    function validarFormulario() {
        let valido = true;

        inputs.forEach((input) => {
            if (!validarCampo(input)) valido = false;
        });

        return valido;
    }

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        erroMsg.innerHTML = "";
        sucessoMsg.innerHTML = "";

        if (!validarFormulario()) {
            erroMsg.innerHTML = "Corrija os campos destacados";
            return;
        }

        const usuario = {
            perfilId: 1,
            ativo: true,
            nome: form.nome.value.trim(),
            email: form.email.value.trim(),
            senha: form.senha.value.trim(),
            telefone: form.telefone.value.trim(),

            idade: form.idade.value ? parseInt(form.idade.value) : null,
            peso: form.peso.value ? parseFloat(form.peso.value) : null,
            altura: form.altura.value ? parseFloat(form.altura.value) : null,

            sexo: form.sexo.value.trim(),
            tipoSanguineo: form.tipoSanguineo.value.trim(),

            marcapasso: form.marcapasso.value.trim().toLowerCase(),

            cep: form.cep.value.trim(),
            obsMed: form.obsMed ? form.obsMed.value.trim() : "",

            dataNascimento: form.dataNascimento.value || null
        };

        try {
            const response = await fetch(`${API}/api/usuarios/cadastro`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(usuario)
            });

            let data = null;

            try {
                data = await response.json();
            } catch {
             data = null;
        }
            if (response.ok) {
                const pacienteId = data.id;

                sucessoMsg.innerHTML = `
                    ID do paciente: <strong>${pacienteId}</strong>
                `;

                // 🔥 salva ID para próxima tela
                sessionStorage.setItem("pacienteId", pacienteId);


            } else {
                erroMsg.innerHTML = "Erro ao cadastrar usuário";
            }

        } catch (err) {
            console.error(err);
            erroMsg.innerHTML = "Erro de conexão com a API";
        }
    });
});