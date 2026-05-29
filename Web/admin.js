// ================= ESTADO GLOBAL =================
let usuariosMemoria = [];
let usuarioEditandoId = null;
let filtroAtual = 0; // 0: Todos, 1: Pacientes, 2: Tutores
let liveInterval = null;

// ================= INICIALIZAÇÃO =================
document.addEventListener("DOMContentLoaded", () => {
    carregarUsuarios();
    
    // Busca em tempo real
    document.getElementById("global-search").addEventListener("input", (e) => {
        const termo = e.target.value.toLowerCase();
        filtrarUsuarios(termo);
    });
});

async function carregarUsuarios() {
    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios`);
        if (!response.ok) throw new Error("API Indisponível");
        usuariosMemoria = await response.json();
        renderizarTabela(usuariosMemoria);
        atualizarStats();
    } catch (err) {
        console.error("Erro ao carregar:", err);
        // Fallback para demonstração se a API falhar
        usuariosMemoria = [
            { id: 100, nome: "João Silva", email: "joao@email.com", perfilId: 1, ativo: true, idade: 45, tipoSanguineo: "O+" },
            { id: 101, nome: "Ana Costa", email: "ana@email.com", perfilId: 1, ativo: true, idade: 32, tipoSanguineo: "A-" },
            { id: 200, nome: "Maria Tutor", email: "maria@email.com", perfilId: 2, ativo: true }
        ];
        renderizarTabela(usuariosMemoria);
        atualizarStats();
    }
}

function renderizarTabela(lista) {
    const tabela = document.getElementById("tabelaUsuarios");
    if (!tabela) return;
    
    // Aplica filtro de papel
    let filtrados = lista;
    if (filtroAtual > 0) {
        filtrados = lista.filter(u => u.perfilId === filtroAtual);
    }

    tabela.innerHTML = "";
    filtrados.forEach(u => {
        const perfilText = u.perfilId === 1 ? 'Paciente' : u.perfilId === 2 ? 'Tutor' : 'Admin';
        const perfilClass = u.perfilId === 1 ? 'text-emerald-400 bg-emerald-500/10' : 'text-neon1 bg-neon1/10';
        const iniciais = u.nome ? u.nome.substring(0, 2).toUpperCase() : '??';
        const statusClass = u.ativo ? 'text-emerald-500' : 'text-gray-600';
        const statusDot = u.ativo ? 'bg-emerald-500 animate-pulse' : 'bg-gray-600';

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
                    <span class="flex items-center gap-2 text-[10px] font-bold ${statusClass}">
                        <span class="w-1.5 h-1.5 rounded-full ${statusDot}"></span> ${u.ativo ? 'Ativo' : 'Inativo'}
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
        (u.nome && u.nome.toLowerCase().includes(termo)) || 
        (u.email && u.email.toLowerCase().includes(termo)) || 
        (u.id && u.id.toString().includes(termo))
    );
    renderizarTabela(filtrados);
}

function setFilter(perfilId) {
    filtroAtual = perfilId;
    
    // Update UI buttons
    const btns = document.querySelectorAll('#filter-container button');
    btns.forEach((btn, idx) => {
        if (idx === perfilId) {
            btn.className = "px-6 py-2 bg-neon1 text-black font-black rounded-lg text-[10px] uppercase";
        } else {
            btn.className = "px-6 py-2 text-gray-500 font-black rounded-lg text-[10px] uppercase";
        }
    });

    renderizarTabela(usuariosMemoria);
}

function inspectUser(id) {
    const user = usuariosMemoria.find(u => u.id === id);
    if (!user) return;
    
    usuarioEditandoId = id;
    document.getElementById("inspect-name").innerText = user.nome;
    document.getElementById("inspect-id-display").innerText = `ID: #${user.id}`;
    document.getElementById("inspect-initials").innerText = user.nome ? user.nome.substring(0,2).toUpperCase() : '??';
    
    // Preenche campos de edição
    document.getElementById("editNome").value = user.nome || "";
    document.getElementById("editEmail").value = user.email || "";
    document.getElementById("editTelefone").value = user.telefone || "";
    document.getElementById("editPeso").value = user.peso || "";
    document.getElementById("editAltura").value = user.altura || "";
    document.getElementById("editTipoSanguineo").value = user.tipoSanguineo || "";
    
    document.getElementById("modalEditar").classList.remove("hidden");
    document.getElementById("modalEditar").classList.add("flex");
}

function fecharModal() {
    document.getElementById("modalEditar").classList.add("hidden");
    document.getElementById("modalEditar").classList.remove("flex");
}

async function atualizarStats() {
    const statUsuarios = document.getElementById("stat-usuarios");
    const statPacientes = document.getElementById("stat-pacientes");
    const statTutors = document.getElementById("stat-tutors");

    if (statUsuarios) statUsuarios.innerText = usuariosMemoria.length;
    if (statPacientes) statPacientes.innerText = usuariosMemoria.filter(u => u.perfilId === 1).length;
    if (statTutors) statTutors.innerText = usuariosMemoria.filter(u => u.perfilId === 2).length;
}

function mostrar(secaoId) {
    const ids = ['dashboard', 'usuarios', 'dados'];
    ids.forEach(id => {
        const el = document.getElementById(id);
        const btn = document.getElementById(`btn-${id}`);
        if (el) el.classList.toggle('hidden', id !== secaoId);
        if (btn) {
            btn.classList.toggle('active', id === secaoId);
            btn.classList.toggle('bg-neon1/10', id === secaoId);
            btn.classList.toggle('text-neon1', id === secaoId);
        }
    });

    if (secaoId === 'dados') {
        startLiveTelemetry();
    } else {
        stopLiveTelemetry();
    }
}

// ================= TELEMETRIA REAL =================
function startLiveTelemetry() {
    stopLiveTelemetry();
    updateLiveGrid();
    liveInterval = setInterval(updateLiveGrid, 3000);
}

function stopLiveTelemetry() {
    if (liveInterval) clearInterval(liveInterval);
}

async function updateLiveGrid() {
    const grid = document.getElementById("live-telemetry-grid");
    if (!grid) return;

    const pacientes = usuariosMemoria.filter(u => u.perfilId === 1 && u.ativo);
    
    // Se grid está vazio, inicializa esqueletos
    if (grid.children.length === 0) {
        pacientes.forEach(p => {
            grid.innerHTML += `
                <div id="live-card-${p.id}" class="glass rounded-[40px] p-8 border-white/5 hover:border-neon1/20 transition-all">
                    <div class="flex justify-between items-start mb-8">
                        <div class="flex items-center gap-4">
                            <div class="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center font-black text-neon1">${p.nome.substring(0,2).toUpperCase()}</div>
                            <div>
                                <h4 class="font-black text-white">${p.nome}</h4>
                                <span class="text-[10px] font-bold text-gray-500 uppercase tracking-widest" id="status-${p.id}">Conectando...</span>
                            </div>
                        </div>
                        <div class="text-right">
                            <p class="text-[10px] font-black text-gray-600 uppercase mb-1">Último Batimento</p>
                            <p class="text-3xl font-black text-white" id="bpm-${p.id}">--</p>
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="bg-black/20 p-4 rounded-2xl">
                            <p class="text-[10px] font-bold text-gray-600 uppercase mb-1">Saturação</p>
                            <p class="text-xl font-black text-emerald-400" id="sat-${p.id}">--%</p>
                        </div>
                        <div class="bg-black/20 p-4 rounded-2xl">
                            <p class="text-[10px] font-bold text-gray-600 uppercase mb-1">Alerta Recente</p>
                            <p class="text-[10px] font-black text-gray-400" id="alert-${p.id}">Nenhum</p>
                        </div>
                    </div>
                </div>
            `;
        });
    }

    // Atualiza dados de cada paciente
    pacientes.forEach(async p => {
        try {
            const res = await fetch(`${CONFIG.API_BASE_URL}/api/batimentos/usuario/${p.id}`);
            if (res.ok) {
                const history = await res.json();
                if (history.length > 0) {
                    const last = history[0];
                    const bpmEl = document.getElementById(`bpm-${p.id}`);
                    const satEl = document.getElementById(`sat-${p.id}`);
                    const statusEl = document.getElementById(`status-${p.id}`);
                    
                    if (bpmEl) bpmEl.innerText = Math.round(last.frequenciaCard);
                    if (satEl) satEl.innerText = `${Math.round(last.saturacao || 98)}%`;
                    if (statusEl) {
                        statusEl.innerText = "ONLINE";
                        statusEl.className = "text-[10px] font-bold text-emerald-500 uppercase tracking-widest";
                    }

                    // Check for anomaly
                    const card = document.getElementById(`live-card-${p.id}`);
                    if (last.frequenciaCard > 120 || last.frequenciaCard < 50) {
                        card.classList.add('border-red-500/50', 'bg-red-500/5');
                        document.getElementById(`alert-${p.id}`).innerText = "RITMO IRREGULAR";
                        document.getElementById(`alert-${p.id}`).className = "text-[10px] font-black text-red-500";
                    } else {
                        card.classList.remove('border-red-500/50', 'bg-red-500/5');
                        document.getElementById(`alert-${p.id}`).innerText = "ESTÁVEL";
                        document.getElementById(`alert-${p.id}`).className = "text-[10px] font-black text-emerald-500";
                    }
                }
            }
        } catch (e) {
            const statusEl = document.getElementById(`status-${p.id}`);
            if (statusEl) {
                statusEl.innerText = "OFFLINE";
                statusEl.className = "text-[10px] font-bold text-gray-600 uppercase tracking-widest";
            }
        }
    });
}

async function salvarEdicao() {
    if (!usuarioEditandoId) return;

    const btn = document.querySelector('button[onclick="salvarEdicao()"]');
    const originalText = btn.innerText;
    btn.disabled = true;
    btn.innerText = "Salvando...";

    const dados = {
        nome: document.getElementById("editNome").value,
        email: document.getElementById("editEmail").value,
        telefone: document.getElementById("editTelefone").value,
        peso: Number(document.getElementById("editPeso").value),
        altura: Number(document.getElementById("editAltura").value),
        tipoSanguineo: document.getElementById("editTipoSanguineo").value,
        cep: document.getElementById("editCep") ? document.getElementById("editCep").value : ""
    };

    try {
        const resOrig = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios/${usuarioEditandoId}`);
        const userOrig = await resOrig.json();
        
        const payload = { ...userOrig, ...dados };

        const response = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios/${usuarioEditandoId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            alert("Cadastro atualizado com sucesso!");
            fecharModal();
            carregarUsuarios();
        } else {
            alert("Erro ao atualizar cadastro.");
        }
    } catch (err) {
        console.error(err);
        alert("Erro de conexão com o servidor.");
    } finally {
        btn.disabled = false;
        btn.innerText = originalText;
    }
}

async function banirUsuario() {
    if (!usuarioEditandoId || !confirm("Deseja realmente desativar este usuário?")) return;

    try {
        const resOrig = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios/${usuarioEditandoId}`);
        const userOrig = await resOrig.json();
        
        const payload = { ...userOrig, ativo: false };

        const response = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios/${usuarioEditandoId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            alert("Usuário desativado com sucesso.");
            fecharModal();
            carregarUsuarios();
        } else {
            alert("Erro ao desativar usuário.");
        }
    } catch (err) {
        console.error(err);
        alert("Erro de conexão.");
    }
}

