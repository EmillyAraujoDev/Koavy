// ================= PARTÍCULAS =================
const criarParticulas = () => {
    const containerParticulas = document.getElementById('particulas');
    if (!containerParticulas) return;

    for (let i = 0; i < 40; i++) {
        const p = document.createElement('div');
        const tamanho = Math.random() * 3;

        p.style.cssText = `
            position: absolute;
            width: ${tamanho}px;
            height: ${tamanho}px;
            background: #00f2ff;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            opacity: ${Math.random() * 0.5};
            filter: blur(1px);
            border-radius: 50%;
        `;

        containerParticulas.appendChild(p);
    }
};

// ================= OLHOS =================
const iniciarOlhos = () => {
    const pupilas = document.querySelectorAll('.pupila');
    const olhos = document.querySelectorAll('.olho');

    if (!pupilas.length || !olhos.length) return;

    document.addEventListener('mousemove', (e) => {
        olhos.forEach((olho, i) => {
            const rect = olho.getBoundingClientRect();

            const dx = e.clientX - (rect.left + rect.width / 2);
            const dy = e.clientY - (rect.top + rect.height / 2);

            const angle = Math.atan2(dy, dx);
            const radius = 8;

            const x = Math.cos(angle) * radius;
            const y = Math.sin(angle) * radius;

            pupilas[i].style.transform =
                `translate(-50%, -50%) translate(${x}px, ${y}px)`;
        });
    });
};

// ================= THREE =================
const setupCena = () => {
    const canvas = document.getElementById('telaRelogio');
    if (!canvas || typeof THREE === "undefined") return;

    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
    renderer.setSize(400, 400);

    const cena = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, 1, 0.1, 1000);
    camera.position.z = 5;

    const luz = new THREE.PointLight(0x00f2ff, 1, 10);
    luz.position.set(2, 2, 2);
    cena.add(luz);

    cena.add(new THREE.AmbientLight(0xffffff, 0.2));

    const objeto = new THREE.Mesh(
        new THREE.TorusGeometry(1, 0.4, 16, 100),
        new THREE.MeshStandardMaterial({ color: 0x8a8d91, roughness: 0.3, metalness: 0.8 })
    );

    cena.add(objeto);

    const animar = () => {
        requestAnimationFrame(animar);
        objeto.rotation.y += 0.01;
        renderer.render(cena, camera);
    };

    animar();
};

// ================= MENU =================
const iniciarMenuMobile = () => {
    const btn = document.getElementById('menu-btn');
    const menu = document.getElementById('mobile-menu');

    if (!btn || !menu) return;

    btn.addEventListener('click', () => {
        menu.classList.toggle('hidden');
    });
};

// ================= INIT =================
window.addEventListener('DOMContentLoaded', () => {
    criarParticulas();
    iniciarOlhos();
    setupCena();
    iniciarMenuMobile();
});