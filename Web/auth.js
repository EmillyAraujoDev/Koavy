/**
 * auth.js - Sistema de Gerenciamento de Autenticação Koavy
 * Sistema Híbrido: Cookies + LocalStorage para máxima compatibilidade.
 */

const Auth = {
    TOKEN_KEY: "koavy_token",
    USER_KEY: "koavy_user",

    saveSession(userData, token) {
        localStorage.setItem(this.USER_KEY, JSON.stringify(userData));
        if (token) localStorage.setItem(this.TOKEN_KEY, token);
    },

    save(token, userData) {
        this.saveSession(userData, token);
    },

    getUser() {
        const user = localStorage.getItem(this.USER_KEY);
        if (!user) return null;

        try {
            return JSON.parse(user);
        } catch (error) {
            localStorage.removeItem(this.USER_KEY);
            localStorage.removeItem(this.TOKEN_KEY);
            return null;
        }
    },

    getToken() {
        return localStorage.getItem(this.TOKEN_KEY);
    },

    getAuthHeader() {
        const token = this.getToken();
        return token ? { 'Authorization': `Bearer ${token}` } : {};
    },

    isAdult(userData = null) {
        const user = userData || this.getUser();
        if (!user) return false;

        if (Number.isFinite(Number(user.idade))) {
            return Number(user.idade) >= 18;
        }

        const birthDate = user.dataNascimento || user.data_nascimento;
        if (!birthDate) return false;

        const parsed = new Date(birthDate);
        if (Number.isNaN(parsed.getTime())) return false;

        const today = new Date();
        let age = today.getFullYear() - parsed.getFullYear();
        const monthDelta = today.getMonth() - parsed.getMonth();
        if (monthDelta < 0 || (monthDelta === 0 && today.getDate() < parsed.getDate())) {
            age -= 1;
        }
        return age >= 18;
    },

    redirectByRole(user) {
        if (!user) {
            window.location.href = "login.html";
            return;
        }
        
        switch(parseInt(user.perfil_id || user.perfilId)) {
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

    check(requiredRole = null) {
        const user = this.getUser();
        const token = this.getToken();
        
        if (!user || !token) {
            if (!window.location.pathname.endsWith('login.html')) {
                this.logout();
            }
            return null;
        }

        if (requiredRole !== null) {
            const role = parseInt(user.perfil_id || user.perfilId);
            if (role !== requiredRole) {
                this.redirectByRole(user);
                return null;
            }
        }
        return user;
    },

    logout() {
        localStorage.removeItem(this.USER_KEY);
        localStorage.removeItem(this.TOKEN_KEY);
        window.location.href = "login.html";
    }
};

window.Auth = Auth;
