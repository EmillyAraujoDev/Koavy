// ================= PROTEÇÃO =================
const user = JSON.parse(localStorage.getItem("user"));

if (!user || user.perfilId !== 2) {
    window.location.href = "login.html";
}

// ================= ELEMENTOS =================
const tabelaUsuarios = document.getElementById("tabelaUsuarios");
const tabelaTutores = document.getElementById("tabelaTutores");

// ================= USUÁRIOS =================
let usuarioEditandoId = null;
let dadosOriginaisUsuario = null; 

async function carregarUsuarios() {
    try {
        const response = await fetch("http://localhost:8080/api/usuarios");
        const usuarios = await response.json();
        if (!tabelaUsuarios) return;
        tabelaUsuarios.innerHTML = "";

        usuarios.forEach(u => {
            tabelaUsuarios.innerHTML += `
                <tr class="border-b border-gray-700">
                    <td class="p-3">${u.nome}</td>
                    <td>${u.email || "-"}</td>
                    <td>${u.perfilId === 1 ? "Paciente" : "Admin"}</td>
                    <td class="${u.ativo ? 'text-green-400' : 'text-red-400'}">
                        ${u.ativo ? 'Ativo' : 'Inativo'}
                    </td>
                    <td class="text-center">
                        <button class="mr-2" onclick="editarUsuario(${u.id})">✏️</button>
                        <button onclick="deletarUsuario(${u.id})">🗑️</button>
                    </td>
                </tr>
            `;
        });
    } catch (err) {
        console.error("Erro ao carregar usuários:", err);
    }
}

async function editarUsuario(id) {
    usuarioEditandoId = id;
    try {
        const response = await fetch("http://localhost:8080/api/usuarios");
        const lista = await response.json();
        const usuario = lista.find(u => u.id == id);

        if (!usuario) return alert("Usuário não encontrado");

        dadosOriginaisUsuario = usuario;

        document.getElementById("editNome").value = usuario.nome || "";
        document.getElementById("editEmail").value = usuario.email || "";
        document.getElementById("editTelefone").value = usuario.telefone || "";
        document.getElementById("editIdade").value = usuario.idade || "";
        document.getElementById("editPeso").value = usuario.peso || "";
        document.getElementById("editAltura").value = usuario.altura || "";
        document.getElementById("editSexo").value = usuario.sexo || "";
        document.getElementById("editTipoSanguineo").value = usuario.tipoSanguineo || "";
        document.getElementById("editMarcapasso").value = usuario.marcapasso || "";
        document.getElementById("editCep").value = usuario.cep || "";
        document.getElementById("editDataNascimento").value =
            usuario.dataNascimento ? usuario.dataNascimento.split("T")[0] : "";
        document.getElementById("editObs").value = usuario.obsMed || "";

        const modal = document.getElementById("modalEditar");
        modal.classList.remove("hidden");
        modal.style.display = "flex";
    } catch (err) {
        console.error(err);
    }
}

async function salvarEdicao() {
    if (!usuarioEditandoId || !dadosOriginaisUsuario) return;

    const usuarioAtualizado = {
        ...dadosOriginaisUsuario, 
        nome: document.getElementById("editNome").value.trim(),
        email: document.getElementById("editEmail").value.trim(),
        telefone: document.getElementById("editTelefone").value.trim(),
        idade: Number(document.getElementById("editIdade").value) || null,
        peso: Number(document.getElementById("editPeso").value) || null,
        altura: Number(document.getElementById("editAltura").value) || null,
        sexo: document.getElementById("editSexo").value,
        tipoSanguineo: document.getElementById("editTipoSanguineo").value,
        marcapasso: document.getElementById("editMarcapasso").value,
        cep: document.getElementById("editCep").value,
        dataNascimento: document.getElementById("editDataNascimento").value,
        obsMed: document.getElementById("editObs").value,
    };

    try {
        const response = await fetch(`http://localhost:8080/api/usuarios/${usuarioEditandoId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(usuarioAtualizado)
        });

        if (response.ok) {
            alert("Atualizado com sucesso");
            fecharModal();
            carregarUsuarios();
            atualizarStats();
        } else {
            alert("Erro ao salvar no banco (verifique a senha ou campos obrigatórios)");
        }
    } catch (err) {
        console.error(err);
    }
}

// ================= NAVEGAÇÃO (ADICIONADO AQUI) =================

function mostrar(secaoId) {
    // Esconde todas as seções primeiro
    document.getElementById("dashboard").classList.add("hidden");
    document.getElementById("usuarios").classList.add("hidden");
    document.getElementById("dados").classList.add("hidden");

    // Mostra apenas a seção clicada
    const secaoAtiva = document.getElementById(secaoId);
    if (secaoAtiva) {
        secaoAtiva.classList.remove("hidden");
    }
}

// ================= TUTORES =================
let tutorEditandoId = null;

async function carregarTutores() {
    try {
        const response = await fetch("http://localhost:8080/api/vinculos");
        const dados = await response.json();
        if (!tabelaTutores) return;
        tabelaTutores.innerHTML = "";
        dados.forEach(t => {
            tabelaTutores.innerHTML += `
                <tr class="border-b border-gray-700">
                    <td class="p-3">${t.nome}</td>
                    <td>${t.pacienteId}</td>
                    <td>${t.dataVinculo ? t.dataVinculo.split("T")[0] : "-"}</td>
                    <td class="text-center">
                        <button class="mr-2" onclick="editarTutor(${t.id})">✏️</button>
                        <button onclick="deletarTutor(${t.id})">🗑️</button>
                    </td>
                </tr>
            `;
        });
    } catch (err) { console.error(err); }
}

async function editarTutor(id) {
    tutorEditandoId = id;
    try {
        const response = await fetch("http://localhost:8080/api/vinculos");
        const lista = await response.json();
        const tutor = lista.find(t => t.id === id);

        document.getElementById("editTutorNome").value = tutor.nome;
        document.getElementById("editTutorPaciente").value = tutor.pacienteId;
        document.getElementById("editTutorData").value = tutor.dataVinculo ? tutor.dataVinculo.split("T")[0] : "";

        const modal = document.getElementById("modalTutor");
        modal.classList.remove("hidden");
        modal.style.display = "flex";
    } catch (err) { console.error(err); }
}

// ================= FECHAR MODAIS =================

function fecharModal() {
    const modal = document.getElementById("modalEditar");
    modal.classList.add("hidden");
    modal.style.display = "none";
}

function fecharModalTutor() {
    const modal = document.getElementById("modalTutor");
    modal.classList.add("hidden");
    modal.style.display = "none";
}

// ================= DEMAIS FUNÇÕES =================

async function deletarUsuario(id) {
    if (!confirm("Deseja excluir?")) return;
    await fetch(`http://localhost:8080/api/usuarios/${id}`, { method: "DELETE" });
    carregarUsuarios();
    atualizarStats();
}

async function atualizarStats() {
    const res = await fetch("http://localhost:8080/api/usuarios");
    const usuarios = await res.json();
    const pTags = document.querySelectorAll("#dashboard p");
    if(pTags.length >= 3) {
        pTags[0].innerText = usuarios.length;
        pTags[1].innerText = usuarios.filter(u => u.perfilId === 1).length;
        pTags[2].innerText = usuarios.filter(u => u.perfilId === 2).length;
    }
}

function logout() {
    localStorage.removeItem("user");
    window.location.href = "login.html";
}

// INICIALIZAÇÃO
carregarUsuarios();
carregarTutores();
atualizarStats();