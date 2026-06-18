/**
 * navbar.js - Componente de Navegação Premium Koavy (Tailwind + CSS Transitions)
 * Injeta uma navbar responsiva de alta performance e um Drawer animado.
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

        // Determinar links corretos
        const getLink = (section, fallbackFile) => {
            return isIndex ? section : fallbackFile;
        };

        const initials = user ? user.nome.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() : '';
        const roleName = user ? (parseInt(user.perfil_id || user.perfilId) === 3 ? 'Admin' : (parseInt(user.perfil_id || user.perfilId) === 2 ? 'Tutor' : 'Paciente')) : '';

        // Inject Styles dynamically for extra smooth animations
        if (!document.getElementById('navbar-styles')) {
            const style = document.createElement('style');
            style.id = 'navbar-styles';
            style.innerHTML = `
                .nav-link-hover {
                    position: relative;
                }
                .nav-link-hover::after {
                    content: '';
                    position: absolute;
                    width: 0%;
                    height: 2px;
                    bottom: -4px;
                    left: 0;
                    background: linear-gradient(to right, #00f2ff, #00d4aa);
                    transition: width 0.3s ease;
                }
                .nav-link-hover:hover::after {
                    width: 100%;
                }
            `;
            document.head.appendChild(style);
        }

        const navHTML = `
        <!-- NAVBAR DESKTOP & BASE -->
        <nav class="fixed top-6 left-1/2 -translate-x-1/2 w-[95%] max-w-7xl z-[140] backdrop-blur-xl bg-black/50 border border-white/10 rounded-[24px] transition-all duration-500 px-6 py-3.5 flex items-center justify-between shadow-[0_20px_50px_rgba(0,0,0,0.5)]" id="main-nav">
            <div class="flex items-center gap-3">
                <a href="${getLink('#inicio', 'interface.html')}" class="flex items-center gap-3 group">
                    <div class="w-10 h-10 bg-gradient-to-br from-neon1 to-neon2 rounded-xl flex items-center justify-center shadow-[0_0_20px_rgba(0,242,255,0.2)] group-hover:scale-110 group-hover:shadow-[0_0_25px_rgba(0,242,255,0.4)] transition-all duration-300">
                        <span class="text-black font-black text-2xl">K</span>
                    </div>
                    <h1 class="text-2xl font-black bg-gradient-to-r from-neon1 to-neon2 bg-clip-text text-transparent tracking-tighter">Koavy</h1>
                </a>
            </div>

            <!-- Desktop Links -->
            <div class="hidden lg:flex gap-8 text-[11px] font-extrabold tracking-[0.15em] uppercase">
                <a href="${getLink('#inicio', 'interface.html')}" class="text-gray-400 hover:text-white nav-link-hover transition-colors">Início</a>
                <a href="${getLink('#sobre', 'sobre.html')}" class="text-gray-400 hover:text-white nav-link-hover transition-colors">Sobre</a>
                <a href="${getLink('#beneficios', 'funcionalidades.html')}" class="text-gray-400 hover:text-white nav-link-hover transition-colors">Funcionalidades</a>
                <a href="${dashboardHref}" class="text-gray-400 hover:text-white nav-link-hover transition-colors">Monitoramento</a>
                <a href="contato.html" class="text-gray-400 hover:text-white nav-link-hover transition-colors">Suporte</a>
            </div>

            <!-- Auth Buttons -->
            <div class="flex items-center gap-4">
                <div class="hidden lg:flex items-center gap-3">
                    ${user ? this.renderUserMenu(user, initials, roleName) : this.renderAuthButtons()}
                </div>
                <button id="mobile-menu-toggle" class="lg:hidden text-white p-2 hover:bg-white/5 rounded-xl transition-all" aria-label="Menu">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                    </svg>
                </button>
            </div>
        </nav>

        <!-- DRAWER MOBILE -->
        <div id="mobile-drawer-overlay" class="fixed inset-0 bg-black/75 backdrop-blur-md z-[150] opacity-0 pointer-events-none transition-opacity duration-300"></div>
        <div id="mobile-drawer" class="fixed top-0 right-0 h-full w-[340px] max-w-[85vw] bg-neutral-950 border-l border-white/10 z-[200] transform translate-x-full transition-transform duration-300 ease-out flex flex-col p-8 shadow-[0_0_50px_rgba(0,0,0,0.8)]">
            
            <!-- Drawer Header -->
            <div class="flex items-center justify-between mb-8 border-b border-white/5 pb-4">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-gradient-to-br from-neon1 to-neon2 rounded-lg flex items-center justify-center">
                        <span class="text-black font-black text-lg">K</span>
                    </div>
                    <span class="text-xl font-black text-white logo">Koavy</span>
                </div>
                <button id="mobile-drawer-close" class="text-gray-400 hover:text-white p-2 hover:bg-white/5 rounded-xl transition-colors">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>

            <!-- User Info (Se Logado) -->
            ${user ? `
            <div class="bg-white/5 border border-white/10 p-5 rounded-3xl flex items-center gap-4 mb-8">
                <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-neon1 to-neon2 flex items-center justify-center text-black font-black text-lg shadow-lg">
                    ${initials}
                </div>
                <div>
                    <h3 class="text-sm font-black text-white leading-tight">${user.nome}</h3>
                    <p class="text-[10px] text-gray-500 font-extrabold uppercase tracking-widest mt-1">${roleName}</p>
                </div>
            </div>
            ` : ''}

            <!-- Drawer Links -->
            <div class="flex-1 flex flex-col gap-6 text-base font-extrabold text-gray-300">
                <a href="${getLink('#inicio', 'interface.html')}" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                    <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>
                    Início
                </a>
                <a href="${getLink('#sobre', 'sobre.html')}" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                    <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                    Sobre
                </a>
                <a href="${getLink('#beneficios', 'funcionalidades.html')}" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                    <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>
                    Funcionalidades
                </a>
                <a href="${dashboardHref}" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                    <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19M12 4v1m0 12v1m9-9h-1m-12 0H3m2 2.05V18a2 2 0 002 2h10a2 2 0 002-2v-4.95"></path></svg>
                    Monitoramento
                </a>
                <a href="contato.html" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                    <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192l-3.536 3.536M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-5 0a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                    Suporte
                </a>
                
                ${user ? `
                    <a href="perfil.html" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
                        Meu Perfil
                    </a>
                    <a href="perfil.html#settings" class="flex items-center gap-4 hover:text-neon1 transition-colors py-2 px-3 hover:bg-white/5 rounded-xl">
                        <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                        Configurações
                    </a>
                ` : ''}
            </div>

            <!-- Drawer Bottom / Logout -->
            <div class="border-t border-white/5 pt-6 flex flex-col gap-4">
                ${user ? `
                    <button onclick="Auth.logout()" class="w-full py-4 bg-red-500/10 hover:bg-red-500/20 text-red-400 font-extrabold rounded-2xl flex items-center justify-center gap-3 transition-colors border border-red-500/10">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                        Sair da Conta
                    </button>
                ` : `
                    <a href="login.html" class="w-full py-4 bg-white/5 hover:bg-white/10 text-white text-center font-extrabold rounded-2xl transition-all border border-white/10 block">
                        Login
                    </a>
                    <a href="cadastro.html" class="w-full py-4 bg-gradient-to-r from-neon1 to-neon2 text-black text-center font-black rounded-2xl hover:shadow-[0_0_20px_rgba(0,242,255,0.3)] transition-all block">
                        Cadastrar
                    </a>
                `}
            </div>
        </div>
        `;

        const header = document.createElement('header');
        header.innerHTML = navHTML;
        document.body.prepend(header);
        
        this.initEvents();
    },

    renderAuthButtons() {
        return `
            <a href="login.html" class="flex items-center justify-center bg-white/5 hover:bg-white/10 border border-white/10 px-6 py-2 rounded-xl font-bold text-[10px] uppercase tracking-widest transition-all text-white hover:scale-105">
                Login
            </a>
            <a href="cadastro.html" class="flex items-center justify-center bg-white/5 hover:bg-white/10 border border-white/10 px-6 py-2 rounded-xl font-bold text-[10px] uppercase tracking-widest transition-all text-gray-400 hover:text-white hover:scale-105">
                Cadastrar
            </a>
            <a href="cadastro.html" class="bg-gradient-to-r from-neon1 to-neon2 text-black px-6 py-2 rounded-xl font-bold text-[10px] uppercase tracking-widest hover:shadow-[0_0_25px_rgba(0,242,255,0.4)] hover:scale-105 transition-all">
                Começar
            </a>
        `;
    },

    renderUserMenu(user, initials, roleName) {
        return `
            <div class="flex items-center gap-4 bg-white/5 border border-white/10 pl-4 pr-2 py-1.5 rounded-2xl backdrop-blur-md">
                <div class="flex flex-col items-end">
                    <span class="text-[10px] font-black text-white leading-none mb-1">${user.nome}</span>
                    <span class="text-[8px] uppercase tracking-widest text-gray-500 font-extrabold">${roleName}</span>
                </div>
                <a href="perfil.html" class="w-8 h-8 rounded-lg bg-gradient-to-br from-neon1 to-neon2 flex items-center justify-center text-black font-black text-xs hover:scale-110 shadow-lg shadow-neon1/10 transition-all">
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
        const close = document.getElementById('mobile-drawer-close');
        const overlay = document.getElementById('mobile-drawer-overlay');
        const drawer = document.getElementById('mobile-drawer');
        const nav = document.getElementById('main-nav');

        const openDrawer = () => {
            overlay.classList.remove('opacity-0', 'pointer-events-none');
            overlay.classList.add('opacity-100', 'pointer-events-auto');
            drawer.classList.remove('translate-x-full');
            drawer.classList.add('translate-x-0');
        };

        const closeDrawer = () => {
            overlay.classList.add('opacity-0', 'pointer-events-none');
            overlay.classList.remove('opacity-100', 'pointer-events-auto');
            drawer.classList.add('translate-x-full');
            drawer.classList.remove('translate-x-0');
        };

        if (toggle) toggle.addEventListener('click', openDrawer);
        if (close) close.addEventListener('click', closeDrawer);
        if (overlay) overlay.addEventListener('click', closeDrawer);

        // Smart Scroll Behavior
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                nav.classList.add('top-2', 'py-2.5', 'w-[98%]', 'rounded-[16px]', 'bg-black/70', 'border-white/10');
                nav.classList.remove('top-6', 'py-3.5', 'w-[95%]', 'rounded-[24px]', 'bg-black/50', 'border-white/10');
            } else {
                nav.classList.remove('top-2', 'py-2.5', 'w-[98%]', 'rounded-[16px]', 'bg-black/70', 'border-white/10');
                nav.classList.add('top-6', 'py-3.5', 'w-[95%]', 'rounded-[24px]', 'bg-black/50', 'border-white/10');
            }
        });
    }
};

document.addEventListener('DOMContentLoaded', () => Navbar.render());
