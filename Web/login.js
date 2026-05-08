const form = document.getElementById("login_form");

if (form) {
    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const email = document.getElementById("name").value.trim();
        const senha = document.getElementById("password").value.trim();

        try {
            const response = await fetch("http://localhost:8080/api/usuarios/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ email, senha })
            });

            let data;

            // 🔥 lê UMA vez só
            const contentType = response.headers.get("content-type");

            if (contentType && contentType.includes("application/json")) {
                data = await response.json();
            } else {
                data = await response.text();
            }

            if (response.ok) {
                console.log("Login OK:", data);

                localStorage.setItem("user", JSON.stringify(data));

                if (data.perfilId === 2) {
                    window.location.href = "admin.html";
                } else if (data.perfilId === 1) {
                    window.location.href = "dashboard.html";
                } else {
                    window.location.href = "tutor.html";
                }

            } else {
                alert(data || "Usuário ou senha inválidos");
            }

        } catch (err) {
            console.error(err);
            alert("Erro de conexão com o servidor");
        }
    });
}