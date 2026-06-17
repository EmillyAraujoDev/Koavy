/**
 * navbar.js - Componente de Navegação Unificado Koavy
 * Este script injeta a navbar moderna em todas as páginas.
 */

const Navbar = {
    render() {
        // Garantir que o script de demo esteja disponível
        if (typeof Demo === 'undefined') {
            const script = document.createElement('script');
            script.src = 'components/demo.js';
            document.head.appendChild(script);
        }

        const user = typeof Auth !== 'undefined' ? Auth.getUser() : null;
        const isIndex = window.location.pathname.endsWith('interface.html') || window.location.pathname.endsWith('/') || window.location.pathname.endsWith('index.html');
        
        let dashboardHref = 'login.html';
        if (user) {
            if (user.isDemo) {
                dashboardHref = 'dashboard.html?demo=true';
            } else {
                const role = parseInt(user.perfil_id || user.perfilId);
                if (role === 3) dashboardHref = 'admin.html';
                else if (role === 2) dashboardHref = 'dashboard_tutor.html';
                else dashboardHref = 'dashboard_paciente.html';
            }
        }

        const navHTML = `
        <nav class="fixed top-6 left-1/2 -translate-x-1/2 w-[95%] max-w-7xl z-[100] backdrop-blur-2xl bg-black/60 border border-white/10 rounded-[24px] transition-all duration-500 px-6 py-3 flex items-center justify-between shadow-2xl" id="main-nav">
            <div class="flex items-center gap-3">
                <a href="${isIndex ? '#inicio' : 'interface.html'}" class="flex items-center gap-3 group">
                    <div class="w-10 h-10 bg-gradient-to-br from-neon1 to-neon2 rounded-xl flex items-center justify-center shadow-lg shadow-neon1/20 group-hover:scale-110 transition-transform">
                        <span class="text-black font-extrabold text-2xl">K</span>
                    </div>
                    <h1 class="text-2xl font-extrabold bg-gradient-to-r from-neon1 to-neon2 bg-clip-text text-transparent logo">Koavy</h1>
                </a>
            </div>

            <!-- Desktop Links -->
            <div class="hidden lg:flex gap-8 text-[11px] font-bold tracking-[0.1em] uppercase">
                <a href="${isIndex ? '#inicio' : 'interface.html'}" class="text-gray-400 hover:text-white transition-colors">Início</a>
                <a href="${isIndex ? '#sobre' : 'sobre.html'}" class="text-gray-400 hover:text-white transition-colors">Sobre</a>
                <a href="${isIndex ? '#beneficios' : 'funcionalidades.html'}" class="text-gray-400 hover:text-white transition-colors">Funcionalidades</a>
                <a href="${dashboardHref}" class="text-gray-400 hover:text-white transition-colors">Monitoramento</a>
                <a href="contato.html" class="text-gray-400 hover:text-white transition-colors">Suporte</a>
            </div>

            <div class="flex items-center gap-4">
                ${user ? this.renderUserMenu(user) : this.renderAuthButtons()}
                <button id="mobile-menu-toggle" class="lg:hidden text-white p-2">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                    </svg>
                </button>
            </div>

            <!-- Mobile Menu -->
            <div id="mobile-menu" class="absolute top-full left-0 w-full mt-4 bg-black/90 backdrop-blur-3xl border border-white/10 rounded-3xl p-8 hidden flex-col gap-6 lg:hidden shadow-2xl">
                <a href="${isIndex ? '#inicio' : 'interface.html'}" class="text-lg font-bold text-white">Início</a>
                <a href="sobre.html" class="text-lg font-bold text-white">Sobre</a>
                <a href="funcionalidades.html" class="text-lg font-bold text-white">Funcionalidades</a>
                <a href="${dashboardHref}" class="text-lg font-bold text-white">Dashboard</a>
                <a href="contato.html" class="text-lg font-bold text-white">Suporte</a>
                <div class="h-px bg-white/10 my-2"></div>
                ${user ? `
                    <a href="perfil.html" class="text-lg font-bold text-neon1">Meu Perfil</a>
                    <button onclick="Auth.logout()" class="text-left text-lg font-bold text-red-500">Sair</button>
                ` : `
                    <a href="login.html" class="text-lg font-bold text-white">Login</a>
                    <a href="cadastro.html" class="text-lg font-bold text-neon1">Criar Conta</a>
                `}
            </div>
        </nav>
        `;

        const header = document.createElement('header');
        header.innerHTML = navHTML;
        document.body.prepend(header);
        
        this.initEvents();
    },

    renderAuthButtons() {
        return `
            <a href="login.html" class="hidden sm:flex items-center justify-center bg-white/5 hover:bg-white/10 border border-white/10 px-6 py-2 rounded-xl font-bold text-[10px] uppercase tracking-widest transition-all">
                Login
            </a>
            <a href="cadastro.html" class="bg-gradient-to-r from-neon1 to-neon2 text-black px-6 py-2 rounded-xl font-bold text-[10px] uppercase tracking-widest hover:shadow-[0_0_20px_rgba(0,242,255,0.3)] hover:scale-105 transition-all">
                Começar
            </a>
        `;
    },

    renderUserMenu(user) {
        const initials = user.nome.split(' ').map(n => n[0]).join('').substring(0,2).toUpperCase();
        return `
            <div class="flex items-center gap-4 bg-white/5 border border-white/10 pl-4 pr-2 py-1.5 rounded-2xl">
                <div class="hidden md:flex flex-col items-end">
                    <span class="text-[10px] font-bold text-white leading-none mb-1">${user.nome}</span>
                    <span class="text-[8px] uppercase tracking-tighter text-gray-500">${user.perfilId === 1 ? 'Paciente' : 'Tutor'}</span>
                </div>
                <a href="perfil.html" class="w-8 h-8 rounded-lg bg-gradient-to-br from-neon1 to-neon2 flex items-center justify-center text-black font-black text-xs hover:scale-110 transition-transform">
                    ${initials}
                </a>
                <button onclick="Auth.logout()" class="p-2 hover:bg-red-500/10 text-red-400 rounded-lg transition-colors" title="Sair">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                    </svg>
                </button>
            </div>
        `;
    },

    initEvents() {
        const toggle = document.getElementById('mobile-menu-toggle');
        const menu = document.getElementById('mobile-menu');
        const nav = document.getElementById('main-nav');

        if (toggle && menu) {
            toggle.addEventListener('click', () => {
                menu.classList.toggle('hidden');
                menu.classList.toggle('flex');
            });
        }

        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                nav.classList.add('top-2', 'py-2', 'w-[98%]', 'rounded-[16px]');
                nav.classList.remove('top-6', 'py-3', 'w-[95%]', 'rounded-[24px]');
            } else {
                nav.classList.remove('top-2', 'py-2', 'w-[98%]', 'rounded-[16px]');
                nav.classList.add('top-6', 'py-3', 'w-[95%]', 'rounded-[24px]');
            }
        });
    }
};

document.addEventListener('DOMContentLoaded', () => Navbar.render());
