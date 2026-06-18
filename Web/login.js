const form = document.getElementById("login_form");
const submitBtn = form?.querySelector('button[type="submit"]');

// ================= CONFIGURAÇÃO GOOGLE GIS =================
window.onload = function () {
    if (typeof google !== 'undefined') {
        google.accounts.id.initialize({
            client_id: "564333524566-cq8tcbvlhadhnrqtncp7rb9qpdo1iftf.apps.googleusercontent.com",
            callback: handleGoogleResponse,
            auto_select: false,
            cancel_on_tap_outside: true
        });

        // Renderiza o botão oficial do Google para melhor feedback visual
        const googleBtnWrapper = document.getElementById("googleBtnWrapper");
        if (googleBtnWrapper) {
            google.accounts.id.renderButton(googleBtnWrapper, {
                theme: "outline",
                size: "large",
                width: "100%",
                text: "continue_with",
                shape: "pill"
            });
        }
    }
};

async function handleGoogleResponse(response) {
    if (!response || !response.credential) {
        showError("Falha ao obter credenciais do Google.");
        return;
    }

    setLoading(true);

    try {
        // Decodifica o payload localmente para fins de UI (opcional)
        const base64Url = response.credential.split('.')[1];
        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
        const payload = JSON.parse(window.atob(base64));

        const res = await fetch(`${CONFIG.API_BASE_URL}/google-login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                credential: response.credential,
                email: payload.email,
                nome: payload.name
            })
        });

        const result = await res.json();

        if (res.ok && result.token) {
            Auth.save(result.token, result.user);
            Auth.redirectByRole(result.user);
        } else {
            showError(result.message || "Erro na autenticação com o servidor.");
        }
    } catch (e) {
        console.error("Google Login Error:", e);
        showError("Falha na conexão com o servidor de autenticação.");
    } finally {
        setLoading(false);
    }
}

function loginWithGoogle() {
    if (typeof google !== 'undefined') {
        google.accounts.id.prompt();
    } else {
        alert("Google Identity Services não carregado.");
    }
}

// Redireciona se já estiver logado
document.addEventListener("DOMContentLoaded", () => {
    const currentUser = Auth.check();
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

        setLoading(true);

        try {
            const response = await fetch(`${CONFIG.API_BASE_URL}/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email, senha })
            });

            const result = await response.json();

            if (response.ok) {
                Auth.save(result.token, result.user);
                Auth.redirectByRole(result.user);
            } else {
                showError(result.message || "E-mail ou senha incorretos.");
            }

        } catch (err) {
            showError("Erro de conexão com o servidor.");
        } finally {
            setLoading(false);
        }
    });
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

const forgotForm = document.getElementById("forgot_form");
if (forgotForm) {
    forgotForm.addEventListener("submit", async (e) => {
        e.preventDefault();
        const email = document.getElementById("forgotEmail").value;
        const msgEl = document.getElementById("forgotMessage");
        
        msgEl.innerText = "Processando solicitação...";
        msgEl.className = "mt-4 text-sm font-bold text-neon1";

        try {
            const res = await fetch(`${CONFIG.API_BASE_URL}/recuperar-senha`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ email })
            });
            const data = await res.json();
            
            if (res.ok) {
                msgEl.innerHTML = `<div class="bg-emerald-500/10 border border-emerald-500/20 p-4 rounded-2xl text-emerald-400 text-xs font-medium">
                    ${data.message}
                </div>`;
            } else {
                msgEl.innerText = data.message;
                msgEl.className = "mt-4 text-sm font-bold text-red-500";
            }
        } catch (e) {
            msgEl.innerText = "Erro de conexão.";
        }
    });
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

// ================= MOCK GOOGLE LOGIN PARA APRESENTAÇÃO =================
function openGoogleMockModal() {
    const modal = document.getElementById("googleMockModal");
    if (modal) {
        modal.classList.remove("hidden");
        modal.classList.add("flex");
    }
}

function closeGoogleMockModal() {
    const modal = document.getElementById("googleMockModal");
    if (modal) {
        modal.classList.add("hidden");
        modal.classList.remove("flex");
    }
}

async function loginWithGoogleMock(perfil) {
    closeGoogleMockModal();
    setLoading(true);

    let email = "google_demo_paciente@koavy.com";
    let nome = "Paciente Google Demo";
    
    if (perfil === 'tutor') {
        email = "google_demo_tutor@koavy.com";
        nome = "Tutor Google Demo";
    }

    try {
        const res = await fetch(`${CONFIG.API_BASE_URL}/google-login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                credential: "mock_presentation_google_" + perfil,
                email: email,
                nome: nome
            })
        });

        const result = await res.json();

        if (res.ok && result.token) {
            Auth.save(result.token, result.user);
            Auth.redirectByRole(result.user);
        } else {
            showError(result.message || "Erro na autenticação de demonstração.");
        }
    } catch (e) {
        console.error("Google Login Error:", e);
        showError("Falha na conexão com o servidor.");
    } finally {
        setLoading(false);
    }
}
