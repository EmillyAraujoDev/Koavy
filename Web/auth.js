/**
 * auth.js - Sistema de Gerenciamento de Autenticação Koavy
 * Sistema Híbrido: Cookies + LocalStorage para máxima compatibilidade.
 */

const Auth = {
    COOKIE_NAME: "user_session",
    EXPIRY_DAYS: 7,

    // Salva sessão em ambos os locais
    saveSession(userData) {
        const d = new Date();
        d.setTime(d.getTime() + (this.EXPIRY_DAYS * 24 * 60 * 60 * 1000));
        let expires = "expires=" + d.toUTCString();
        document.cookie = this.COOKIE_NAME + "=" + encodeURIComponent(JSON.stringify(userData)) + ";" + expires + ";path=/;SameSite=Lax";
        localStorage.setItem("user", JSON.stringify(userData));
    },

    // Recupera tentando cookies primeiro, depois localStorage
    getUser() {
        let name = this.COOKIE_NAME + "=";
        let decodedCookie = decodeURIComponent(document.cookie);
        let ca = decodedCookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) == ' ') c = c.substring(1);
            if (c.indexOf(name) == 0) {
                try {
                    return JSON.parse(decodeURIComponent(c.substring(name.length, c.length)));
                } catch (e) { console.error("Erro no cookie:", e); }
            }
        }

        const localUser = localStorage.getItem("user");
        if (localUser) {
            try { return JSON.parse(localUser); } catch(e) { return null; }
        }
        return null;
    },

    // Redireciona o usuário para seu dashboard específico baseado no perfilId
    // 1: PACIENTE, 2: TUTOR, 3: ADMIN
    redirectByRole(user) {
        if (!user) {
            window.location.href = "login.html";
            return;
        }
        
        switch(user.perfilId) {
            case 3:
                window.location.href = "admin.html";
                break;
            case 2:
                window.location.href = "dashboard_tutor.html";
                break;
            case 1:
            default:
                window.location.href = "dashboard_paciente.html";
                break;
        }
    },

    check() {
        const user = this.getUser();
        if (!user) {
            window.location.href = "login.html";
            return null;
        }
        return user;
    },

    logout() {
        document.cookie = this.COOKIE_NAME + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
        localStorage.removeItem("user");
        window.location.href = "login.html";
    },

    isAdmin() {
        const user = this.getUser();
        return user && user.perfilId === 3;
    },

    isAdult() {
        const user = this.getUser();
        if (!user) return false;
        // Se a idade estiver salva diretamente
        if (user.idade !== undefined && user.idade !== null) {
            return user.idade >= 18;
        }
        // Se precisar calcular pela data de nascimento
        if (user.dataNascimento) {
            const birthDate = new Date(user.dataNascimento);
            const today = new Date();
            let age = today.getFullYear() - birthDate.getFullYear();
            const m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
            return age >= 18;
        }
        return false;
    }
};

window.Auth = Auth;
