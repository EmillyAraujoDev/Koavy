<<<<<<< HEAD
// ================= ADMIN CORE =================
const adminUser = Auth.check();
if (adminUser.perfilId !== 3) Auth.redirectByRole(adminUser);

// ================= ESTADO GLOBAL =================
let usuariosMemoria = [];
let usuarioEditandoId = null;
=======
// ================= PROTEÇÃO E AUTH =================
const user = JSON.parse(localStorage.getItem("user"));

if (!user || user.perfilId !== 2) {
    window.location.href = "login.html";
}

document.getElementById("admin-name").innerText = user.nome || "Admin";

// ================= ESTADO GLOBAL =================
let usuarioEditandoId = null;
let dadosOriginaisUsuario = null;
let tutorEditandoId = null;

// ================= UTILITÁRIOS =================
function calcularIdade(dataNascimento) {
    if (!dataNascimento) return "";
    const hoje = new Date();
    const nasc = new Date(dataNascimento);
    let idade = hoje.getFullYear() - nasc.getFullYear();
    const m = hoje.getMonth() - nasc.getMonth();
    if (m < 0 || (m === 0 && hoje.getDate() < nasc.getDate())) {
        idade--;
    }
    return idade;
}

function calcularIdadeAutomatico() {
    const dataNasc = document.getElementById("editDataNascimento").value;
    const idadeInput = document.getElementById("editIdade");
    if (dataNasc) {
        idadeInput.value = calcularIdade(dataNasc);
    }
}

// ================= DASHBOARD CORE =================
async function atualizarStats() {
    try {
        const res = await fetch("http://localhost:8080/api/usuarios");
        const usuarios = await res.json();
        
        document.getElementById("stat-usuarios").innerText = usuarios.length;
        document.getElementById("stat-pacientes").innerText = usuarios.filter(u => u.perfilId === 1).length;
        document.getElementById("stat-admins").innerText = usuarios.filter(u => u.perfilId === 2).length;
    } catch (err) {
        console.error("Erro ao carregar estatísticas:", err);
    }
}

// ================= USUÁRIOS =================
async function carregarUsuarios() {
    const tabela = document.getElementById("tabelaUsuarios");
    if (!tabela) return;

    try {
        const response = await fetch("http://localhost:8080/api/usuarios");
        const usuarios = await response.json();
        tabela.innerHTML = "";

        usuarios.forEach(u => {
            const statusClass = u.ativo ? 'text-emerald-500 bg-emerald-500/10' : 'text-red-500 bg-red-500/10';
            const statusText = u.ativo ? 'Ativo' : 'Inativo';
            const tipoText = u.perfilId === 1 ? 'Paciente' : 'Admin';
            const iniciais = u.nome ? u.nome.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() : '??';

            tabela.innerHTML += `
                <tr class="hover:bg-white/[0.02] transition-colors">
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full bg-white/5 flex items-center justify-center text-[10px] font-bold text-gray-400 border border-white/10">
                                ${iniciais}
                            </div>
                            <div>
                                <p class="text-sm font-bold text-white">${u.nome}</p>
                                <p class="text-xs text-gray-500">ID: ${u.id}</p>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-400">${u.email || "-"}</td>
                    <td class="px-6 py-4">
                        <span class="text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded bg-white/5 border border-white/10">
                            ${tipoText}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <span class="text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded ${statusClass}">
                            ${statusText}
                        </span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex justify-center gap-2">
                            <button onclick="editarUsuario(${u.id})" class="p-2 hover:bg-neon1/10 hover:text-neon1 rounded-lg transition-all">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                </svg>
                            </button>
                            <button onclick="deletarUsuario(${u.id})" class="p-2 hover:bg-red-500/10 hover:text-red-500 rounded-lg transition-all">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                </svg>
                            </button>
                        </div>
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

        if (!usuario) return;
        dadosOriginaisUsuario = usuario;

        document.getElementById("editNome").value = usuario.nome || "";
        document.getElementById("editEmail").value = usuario.email || "";
        document.getElementById("editTelefone").value = usuario.telefone || "";
        document.getElementById("editPeso").value = usuario.peso || "";
        document.getElementById("editAltura").value = usuario.altura || "";
        document.getElementById("editSexo").value = usuario.sexo || "M";
        document.getElementById("editTipoSanguineo").value = usuario.tipoSanguineo || "";
        document.getElementById("editMarcapasso").value = usuario.marcapasso || "Não";
        document.getElementById("editCep").value = usuario.cep || "";
        document.getElementById("editDataNascimento").value = usuario.dataNascimento ? usuario.dataNascimento.split("T")[0] : "";
        document.getElementById("editObs").value = usuario.obsMed || "";
        
        calcularIdadeAutomatico();

        const modal = document.getElementById("modalEditar");
        modal.classList.remove("hidden");
        modal.classList.add("flex");
    } catch (err) { console.error(err); }
}

async function salvarEdicao() {
    if (!usuarioEditandoId || !dadosOriginaisUsuario) return;

    const dataNasc = document.getElementById("editDataNascimento").value;

    const usuarioAtualizado = {
        ...dadosOriginaisUsuario,
        nome: document.getElementById("editNome").value.trim(),
        email: document.getElementById("editEmail").value.trim(),
        telefone: document.getElementById("editTelefone").value.trim(),
        idade: calcularIdade(dataNasc),
        peso: Number(document.getElementById("editPeso").value) || null,
        altura: Number(document.getElementById("editAltura").value) || null,
        sexo: document.getElementById("editSexo").value,
        tipoSanguineo: document.getElementById("editTipoSanguineo").value,
        marcapasso: document.getElementById("editMarcapasso").value,
        cep: document.getElementById("editCep").value,
        dataNascimento: dataNasc,
        obsMed: document.getElementById("editObs").value,
    };

    try {
        const response = await fetch(`http://localhost:8080/api/usuarios/${usuarioEditandoId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(usuarioAtualizado)
        });

        if (response.ok) {
            fecharModal();
            carregarUsuarios();
            atualizarStats();
            alert("Dados do paciente atualizados com sucesso!");
        } else {
            alert("Erro ao salvar alterações. Verifique os dados.");
        }
    } catch (err) { console.error(err); }
}

// ================= TUTORES =================
async function carregarTutores() {
    const tabela = document.getElementById("tabelaTutores");
    if (!tabela) return;

    try {
        const response = await fetch("http://localhost:8080/api/vinculos");
        const dados = await response.json();
        tabela.innerHTML = "";
        
        dados.forEach(t => {
            tabela.innerHTML += `
                <tr class="hover:bg-white/[0.02] transition-colors">
                    <td class="px-6 py-4 font-bold text-white">${t.nome}</td>
                    <td class="px-6 py-4 text-sm text-gray-400">#${t.pacienteId}</td>
                    <td class="px-6 py-4 text-sm text-gray-400">${t.dataVinculo ? t.dataVinculo.split("T")[0] : "-"}</td>
                    <td class="px-6 py-4">
                        <div class="flex justify-center gap-2">
                            <button onclick="editarTutor(${t.id})" class="p-2 hover:bg-neon1/10 hover:text-neon1 rounded-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                </svg>
                            </button>
                            <button onclick="deletarTutor(${t.id})" class="p-2 hover:bg-red-500/10 hover:text-red-500 rounded-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                </svg>
                            </button>
                        </div>
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
        modal.classList.add("flex");
    } catch (err) { console.error(err); }
}

// ================= NAVEGAÇÃO =================
function mostrar(secaoId) {
    const secoes = ["dashboard", "usuarios", "dados"];
    secoes.forEach(id => {
        const el = document.getElementById(id);
        const btn = document.getElementById(`btn-${id}`);
        if (id === secaoId) {
            el.classList.remove("hidden");
            btn.classList.add("active");
        } else {
            el.classList.add("hidden");
            btn.classList.remove("active");
        }
    });

    // Atualiza título da página
    const titles = {
        "dashboard": "Dashboard Geral",
        "usuarios": "Gestão de Usuários",
        "dados": "Monitoramento Real"
    };
    document.getElementById("page-title").innerText = titles[secaoId];
}

// ================= MODAIS =================
function fecharModal() {
    const modal = document.getElementById("modalEditar");
    modal.classList.add("hidden");
    modal.classList.remove("flex");
}

function fecharModalTutor() {
    const modal = document.getElementById("modalTutor");
    modal.classList.add("hidden");
    modal.classList.remove("flex");
}

// ================= SISTEMA =================
async function deletarUsuario(id) {
    if (!confirm("Tem certeza que deseja remover este usuário permanentemente?")) return;
    try {
        await fetch(`http://localhost:8080/api/usuarios/${id}`, { method: "DELETE" });
        carregarUsuarios();
        atualizarStats();
    } catch (err) { console.error(err); }
}

async function deletarTutor(id) {
    if (!confirm("Remover este vínculo de tutor?")) return;
    try {
        await fetch(`http://localhost:8080/api/vinculos/${id}`, { method: "DELETE" });
        carregarTutores();
    } catch (err) { console.error(err); }
}

function logout() {
    localStorage.removeItem("user");
    window.location.href = "login.html";
}
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27

// ================= INICIALIZAÇÃO =================
document.addEventListener("DOMContentLoaded", () => {
    carregarUsuarios();
<<<<<<< HEAD
    atualizarStats();
    
    // Busca em tempo real
    document.getElementById("global-search").addEventListener("input", (e) => {
        const termo = e.target.value.toLowerCase();
        filtrarUsuarios(termo);
    });
});

async function carregarUsuarios() {
    try {
        const response = await fetch("http://localhost:8080/api/usuarios");
        if (!response.ok) throw new Error("API Indisponível");
        usuariosMemoria = await response.json();
        renderizarTabela(usuariosMemoria);
    } catch (err) {
        console.error("Erro ao carregar:", err);
        // Fallback para demonstração se a API falhar
        usuariosMemoria = [
            { id: 100, nome: "João Silva", email: "joao@email.com", perfilId: 1, ativo: true, idade: 45 },
            { id: 200, nome: "Maria Tutor", email: "maria@email.com", perfilId: 2, ativo: true }
        ];
        renderizarTabela(usuariosMemoria);
    }
}

function renderizarTabela(lista) {
    const tabela = document.getElementById("tabelaUsuarios");
    if (!tabela) return;
    tabela.innerHTML = "";

    lista.forEach(u => {
        const perfilText = u.perfilId === 1 ? 'Paciente' : u.perfilId === 2 ? 'Tutor' : 'Admin';
        const perfilClass = u.perfilId === 1 ? 'text-emerald-400 bg-emerald-500/10' : 'text-neon1 bg-neon1/10';
        const iniciais = u.nome.substring(0, 2).toUpperCase();

        tabela.innerHTML += `
            <tr class="hover:bg-white/[0.03] transition-all">
                <td class="px-10 py-6">
                    <div class="flex items-center gap-4">
                        <div class="w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center font-black text-xs">${iniciais}</div>
                        <div>
                            <p class="font-bold text-white">${u.nome}</p>
                            <p class="text-[10px] text-gray-500">ID: #${u.id}</p>
                        </div>
                    </div>
                </td>
                <td class="px-10 py-6 text-sm text-gray-400">${u.email}</td>
                <td class="px-10 py-6">
                    <span class="px-3 py-1 rounded-lg text-[9px] font-black uppercase tracking-widest ${perfilClass}">${perfilText}</span>
                </td>
                <td class="px-10 py-6">
                    <span class="flex items-center gap-2 text-[10px] font-bold text-emerald-500">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span> Ativo
                    </span>
                </td>
                <td class="px-10 py-6 text-right">
                    <button onclick="inspectUser(${u.id})" class="p-3 hover:bg-neon1/10 text-gray-500 hover:text-neon1 transition-all rounded-xl">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                    </button>
                </td>
            </tr>
        `;
    });
}

function filtrarUsuarios(termo) {
    const filtrados = usuariosMemoria.filter(u => 
        u.nome.toLowerCase().includes(termo) || 
        u.email.toLowerCase().includes(termo) || 
        u.id.toString().includes(termo)
    );
    renderizarTabela(filtrados);
}

function inspectUser(id) {
    const user = usuariosMemoria.find(u => u.id === id);
    if (!user) return;
    
    usuarioEditandoId = id;
    document.getElementById("inspect-name").innerText = user.nome;
    document.getElementById("inspect-id-display").innerText = `ID: #${user.id}`;
    document.getElementById("inspect-initials").innerText = user.nome.substring(0,2).toUpperCase();
    
    // Preenche campos de edição
    document.getElementById("editNome").value = user.nome;
    document.getElementById("editEmail").value = user.email;
    document.getElementById("editTelefone").value = user.telefone || "";
    document.getElementById("editPeso").value = user.peso || "";
    
    document.getElementById("modalEditar").classList.remove("hidden");
    document.getElementById("modalEditar").classList.add("flex");
}

function fecharModal() {
    document.getElementById("modalEditar").classList.add("hidden");
    document.getElementById("modalEditar").classList.remove("flex");
}

async function atualizarStats() {
    document.getElementById("stat-usuarios").innerText = usuariosMemoria.length;
    document.getElementById("stat-pacientes").innerText = usuariosMemoria.filter(u => u.perfilId === 1).length;
    document.getElementById("stat-admins").innerText = usuariosMemoria.filter(u => u.perfilId === 2).length;
}

function mostrar(secaoId) {
    const ids = ['dashboard', 'usuarios', 'dados'];
    ids.forEach(id => {
        document.getElementById(id).classList.toggle('hidden', id !== secaoId);
        document.getElementById(`btn-${id}`).classList.toggle('active', id === secaoId);
        document.getElementById(`btn-${id}`).classList.toggle('bg-neon1/10', id === secaoId);
        document.getElementById(`btn-${id}`).classList.toggle('text-neon1', id === secaoId);
    });
}

function salvarEdicao() {
    alert("Simulação: Alterações salvas no banco de dados.");
    fecharModal();
}
=======
    carregarTutores();
    atualizarStats();
});
>>>>>>> 0de5c821e4478e2161b6a5a2381235c8477e6d27
