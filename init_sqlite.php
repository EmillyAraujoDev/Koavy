<?php
// init_sqlite.php
$dbPath = __DIR__ . '/koavy.sqlite';
if (file_exists($dbPath)) unlink($dbPath);

try {
    $db = new PDO("sqlite:" . $dbPath);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Creating schema...\n";

    // 1. Usuarios
    $db->exec("CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        perfil_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL,
        idade INTEGER,
        data_nascimento TEXT,
        sexo TEXT,
        telefone TEXT,
        tipo_sanguineo TEXT,
        peso REAL,
        altura REAL,
        marcapasso INTEGER DEFAULT 0,
        obs_med TEXT,
        cep TEXT,
        ativo INTEGER DEFAULT 1,
        ultimo_login TEXT,
        cadastro TEXT DEFAULT CURRENT_TIMESTAMP
    )");

    // 2. Batimentos
    $db->exec("CREATE TABLE batimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        bpm REAL NOT NULL,
        saturacao REAL,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
    )");

    // 3. Alertas
    $db->exec("CREATE TABLE alertas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        bpm_momento REAL,
        descricao TEXT,
        data_hora TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
    )");

    // 4. Emergencia
    $db->exec("CREATE TABLE emergencia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        alerta_id INTEGER NOT NULL,
        latitude REAL,
        longitude REAL,
        status TEXT DEFAULT 'PENDENTE',
        data_hora TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id),
        FOREIGN KEY(alerta_id) REFERENCES alertas(id)
    )");

    // 5. Tutor Paciente (Vinculos)
    $db->exec("CREATE TABLE tutor_paciente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tutor_id INTEGER NOT NULL,
        paciente_id INTEGER NOT NULL,
        data_vinculo TEXT DEFAULT CURRENT_TIMESTAMP,
        principal INTEGER DEFAULT 0,
        FOREIGN KEY(tutor_id) REFERENCES usuarios(id),
        FOREIGN KEY(paciente_id) REFERENCES usuarios(id)
    )");

    // 6. Configuracoes Cardiacas
    $db->exec("CREATE TABLE configuracoes_cardiacas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER UNIQUE NOT NULL,
        bpm_min INTEGER DEFAULT 60,
        bpm_max INTEGER DEFAULT 100,
        sat_min INTEGER DEFAULT 95,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
    )");

    echo "Seeding data...\n";

    $pass = password_hash('paciente123', PASSWORD_BCRYPT);
    $db->exec("INSERT INTO usuarios (perfil_id, nome, email, senha) VALUES (1, 'Paciente Demo', 'paciente@koavy.com', '$pass')");
    
    $userId = $db->lastInsertId();
    $db->exec("INSERT INTO configuracoes_cardiacas (usuario_id) VALUES ($userId)");

    echo "SUCCESS: Local database initialized.\n";

} catch (Exception $e) {
    die("FATAL ERROR: " . $e->getMessage() . "\n");
}
