/**
 * pacientes.js - Lógica da interface de perfil do paciente
 */

document.addEventListener("DOMContentLoaded", () => {
    const user = Auth.check();
    if (!user) return;

    // Inicialização da Interface
    renderUserData(user);
    loadTutors(user.id);
    setupPermissions(user);
    setupModal();
});

function renderUserData(user) {
    document.getElementById("user-name").innerText = user.nome;
    document.getElementById("user-email").innerText = user.email || "-";
    document.getElementById("user-id").innerText = `#${user.id}`;
    document.getElementById("user-phone").innerText = user.telefone || "-";
    document.getElementById("user-initials").innerText = user.nome.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();

    document.getElementById("user-birth").innerText = user.dataNascimento ? user.dataNascimento.split('T')[0] : '--/--/----';
    document.getElementById("user-age").innerText = `${user.idade || '--'} anos`;
    document.getElementById("user-blood").innerText = user.tipoSanguineo || '--';
    document.getElementById("user-weight").innerText = user.peso || '--';
    document.getElementById("user-height").innerText = user.altura || '--';
    document.getElementById("user-pacemaker").innerText = user.marcapasso ? 'Sim' : 'Não';
    document.getElementById("user-cep").innerText = `CEP: ${user.cep || '--'}`;

    if (user.obsMed) {
        const obsEl = document.getElementById("user-obs");
        obsEl.innerText = user.obsMed;
        obsEl.classList.remove('italic');
    }
}

async function loadTutors(userId) {
    const tutorsList = document.getElementById("tutors-list");
    tutorsList.innerHTML = '<div class="text-center py-4 text-xs text-gray-500">Carregando tutores...</div>';

    try {
        // Tentamos buscar da API. Se falhar, usamos um mock para demonstração
        const response = await fetch(`${CONFIG.API_BASE_URL}/vinculos/paciente/${userId}`);
        let tutors = [];
        
        if (response.ok) {
            tutors = await response.json();
        } else {
            console.warn("API de vínculos não retornou dados, usando mock.");
            tutors = [
                { id: 1, nome: "Maria Tutor", principal: true },
                { id: 2, nome: "José Auxiliar", principal: false }
            ];
        }

        renderTutors(tutors);
    } catch (err) {
        console.error("Erro ao carregar tutores:", err);
        tutorsList.innerHTML = '<div class="text-center py-4 text-xs text-red-500">Erro ao carregar tutores.</div>';
    }
}

function renderTutors(tutors) {
    const tutorsList = document.getElementById("tutors-list");
    tutorsList.innerHTML = "";

    if (tutors.length === 0) {
        tutorsList.innerHTML = '<div class="text-center py-4 text-xs text-gray-500">Nenhum tutor vinculado.</div>';
        return;
    }

    const isAdult = Auth.isAdult();

    tutors.forEach(t => {
        const initials = t.nome.substring(0, 2).toUpperCase();
        const item = document.createElement("div");
        item.className = "flex items-center justify-between p-4 bg-white/5 border border-white/5 rounded-2xl hover:bg-white/10 transition group";
        
        item.innerHTML = `
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-500 font-bold">${initials}</div>
                <div>
                    <p class="text-sm font-bold text-white">${t.nome}</p>
                    <p class="text-[10px] text-gray-500 uppercase tracking-tighter">${t.principal ? 'Principal' : 'Secundário'}</p>
                </div>
            </div>
            ${isAdult ? `
            <div class="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                <button onclick="removeTutor(${t.id})" class="p-2 hover:bg-red-500/10 text-red-500 rounded-lg transition" title="Remover">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                </button>
            </div>
            ` : ''}
        `;
        tutorsList.appendChild(item);
    });
}

function setupPermissions(user) {
    const isAdult = Auth.isAdult();
    const addTutorBtn = document.getElementById("btn-add-tutor");
    
    if (!isAdult) {
        addTutorBtn.disabled = true;
        addTutorBtn.classList.add("opacity-50", "cursor-not-allowed");
        addTutorBtn.title = "Apenas pacientes maiores de 18 anos podem gerenciar tutores.";
        
        const infoMsg = document.createElement("p");
        infoMsg.className = "text-[10px] text-gray-500 mt-2 italic text-center";
        infoMsg.innerText = "Gerenciamento de tutores restrito a maiores de 18 anos.";
        addTutorBtn.parentNode.appendChild(infoMsg);
    }
}

function setupModal() {
    const modal = document.getElementById("modal-tutor");
    const openBtn = document.getElementById("btn-add-tutor");
    const closeBtn = document.getElementById("btn-close-modal");
    const form = document.getElementById("form-tutor");

    if (!openBtn || !modal) return;

    openBtn.onclick = () => {
        if (Auth.isAdult()) {
            modal.classList.remove("hidden");
            modal.classList.add("flex");
        }
    };

    closeBtn.onclick = () => {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
    };

    form.onsubmit = async (e) => {
        e.preventDefault();
        const nome = document.getElementById("tutor-nome").value.trim();
        const principal = document.getElementById("tutor-principal").checked;
        const user = Auth.getUser();

        if (!nome) return;

        const submitBtn = form.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerText = "Salvando...";

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/vinculos`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    nome: nome,
                    pacienteId: user.id,
                    principal: principal,
                    dataVinculo: new Date().toISOString()
                })
            });

            if (response.ok) {
                modal.classList.add("hidden");
                modal.classList.remove("flex");
                form.reset();
                loadTutors(user.id);
            } else {
                alert("Erro ao salvar tutor.");
            }
        } catch (err) {
            console.error(err);
            alert("Erro de conexão.");
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerText = "Adicionar Tutor";
        }
    };
}

async function removeTutor(id) {
    if (!confirm("Deseja realmente remover este tutor?")) return;

    try {
        const response = await fetch(`${CONFIG.API_BASE_URL}/vinculos/${id}`, {
            method: "DELETE"
        });

        if (response.ok) {
            const user = Auth.getUser();
            loadTutors(user.id);
        } else {
            alert("Erro ao remover tutor.");
        }
    } catch (err) {
        console.error(err);
        alert("Erro de conexão.");
    }
}

function logout() {
    Auth.logout();
}

window.removeTutor = removeTutor;
window.logout = logout;
