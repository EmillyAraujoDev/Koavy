/**
 * demo.js - Sistema de Demonstração Interativa Koavy
 * Permite que usuários vejam o potencial da plataforma sem login.
 */

const Demo = {
    isDemoMode: false,

    start() {
        this.isDemoMode = true;
        // Salva um usuário fake temporário para a sessão
        const fakeUser = {
            id: "DEMO",
            nome: "Visitante",
            perfilId: 1,
            idade: 28,
            tipoSanguineo: "AB+",
            isDemo: true
        };
        localStorage.setItem("koavy_user", JSON.stringify(fakeUser));
        window.location.href = "dashboard.html?demo=true";
    },

    setupDashboard() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('demo') === 'true') {
            this.injectDemoUI();
        }
    },

    injectDemoUI() {
        const banner = document.createElement('div');
        banner.className = "fixed bottom-8 left-1/2 -translate-x-1/2 z-[200] glass px-8 py-4 rounded-2xl flex items-center gap-6 shadow-2xl border-neon1/30 animate-bounce";
        banner.innerHTML = `
            <div class="flex flex-col">
                <span class="text-neon1 font-bold text-xs uppercase tracking-widest">Modo Demonstração</span>
                <span class="text-white text-sm">Gostou do que viu? Crie sua conta real.</span>
            </div>
            <a href="cadastro.html" class="bg-neon1 text-black px-6 py-2 rounded-xl font-bold text-xs hover:scale-105 transition-all">Criar Conta Agora</a>
        `;
        document.body.appendChild(banner);

        // Bloqueia ações reais no modo demo
        document.querySelectorAll('button, a').forEach(el => {
            if (el.innerText.includes('Salvar') || el.innerText.includes('Exportar')) {
                el.onclick = (e) => {
                    e.preventDefault();
                    alert("Esta funcionalidade está desativada no modo de demonstração.");
                };
            }
        });
    }
};

window.Demo = Demo;
