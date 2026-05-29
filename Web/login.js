const form = document.getElementById("login_form");
const submitBtn = form?.querySelector('button[type="submit"]');

// Redireciona se já estiver logado
document.addEventListener("DOMContentLoaded", () => {
    const currentUser = Auth.getUser();
    if (currentUser) {
        Auth.redirectByRole(currentUser);
    }
});

if (form) {
    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const emailInput = document.getElementById("name");
        const senhaInput = document.getElementById("password");
        const email = emailInput.value.trim();
        const senha = senhaInput.value.trim();

        if (!email || !senha) {
            showError("Por favor, preencha todos os campos.");
            return;
        }

        // ================= CONTAS DE TESTE (DEMO) =================
        const demoAccounts = {
            "admin@koavy.com": { senha: "admin123", data: { id: 1, nome: "Admin Demo", email: "admin@koavy.com", perfilId: 3, ativo: true } },
            "paciente@koavy.com": { senha: "paciente123", data: { id: 100, nome: "Paciente Demo", email: "paciente@koavy.com", perfilId: 1, ativo: true, idade: 30, tipoSanguineo: "O+" } },
            "tutor@koavy.com": { senha: "tutor123", data: { id: 200, nome: "Tutor Demo", email: "tutor@koavy.com", perfilId: 2, ativo: true } }
        };

        if (demoAccounts[email] && demoAccounts[email].senha === senha) {
            console.log("Login via conta de demonstração");
            Auth.saveSession(demoAccounts[email].data);
            Auth.redirectByRole(demoAccounts[email].data);
            return;
        }
        // ==========================================================

        setLoading(true);

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/api/usuarios/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email, senha })
            });

            const data = await response.json();

            if (response.ok) {
                console.log("Login bem-sucedido");
                Auth.saveSession(data);
                Auth.redirectByRole(data);
            } else {
                showError(data.message || "E-mail ou senha incorretos.");
            }

        } catch (err) {
            console.error("Erro no login:", err);
            showError("Erro de conexão com o servidor. Verifique se o backend está rodando.");
        } finally {
            setLoading(false);
        }
    });
}

// ================= SIMULAÇÃO GOOGLE =================
async function loginWithGoogle() {
    console.log("Simulando login com Google...");
    alert("Simulando conexão com Google...");
    
    const testUser = {
        id: 999,
        nome: "Usuário Google Teste",
        email: "google@teste.com",
        perfilId: 1,
        idade: 25,
        ativo: true
    };
    
    Auth.saveSession(testUser);
    Auth.redirectByRole(testUser);
}

// ================= ESQUECI A SENHA =================
function openForgotModal() {
    document.getElementById("forgotModal").classList.remove("hidden");
    document.getElementById("forgotModal").classList.add("flex");
}

function closeForgotModal() {
    document.getElementById("forgotModal").classList.add("hidden");
    document.getElementById("forgotModal").classList.remove("flex");
}

async function handleForgotSubmit(e) {
    e.preventDefault();
    const email = document.getElementById("forgotEmail").value;
    const msgEl = document.getElementById("forgotMessage");
    
    msgEl.innerText = "Processando solicitação...";
    msgEl.className = "mt-4 text-sm font-bold text-neon1";

    setTimeout(() => {
        msgEl.innerHTML = `<div class="bg-emerald-500/10 border border-emerald-500/20 p-4 rounded-2xl text-emerald-400 text-xs font-medium">
            Sucesso! Um link de recuperação foi enviado para <b>${email}</b>. 
            Verifique sua caixa de entrada.
        </div>`;
        console.log("Link de recuperação gerado (Simulado): redefinir-senha.html");
    }, 1500);
}

const forgotForm = document.getElementById("forgot_form");
if (forgotForm) {
    forgotForm.addEventListener("submit", handleForgotSubmit);
}

// ================= UTILITÁRIOS =================
function showError(msg) {
    const errorEl = document.getElementById("mensagemErro");
    if (errorEl) {
        errorEl.innerText = msg;
        setTimeout(() => errorEl.innerText = "", 5000);
    }
}

function setLoading(isLoading) {
    if (!submitBtn) return;
    if (isLoading) {
        submitBtn.disabled = true;
        submitBtn.dataset.originalText = submitBtn.innerText;
        submitBtn.innerText = "Verificando...";
    } else {
        submitBtn.disabled = false;
        submitBtn.innerText = submitBtn.dataset.originalText || "Entrar no Sistema";
    }
}
