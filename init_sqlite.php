<?php
// init_sqlite.php

$dbPath = __DIR__ . '/koavy.sqlite';
if (file_exists($dbPath)) {
    unlink($dbPath);
}

try {
    $db = new PDO("sqlite:" . $dbPath);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->exec("PRAGMA foreign_keys = ON");

    echo "Creating Koavy SQLite schema...\n";

    $db->exec("CREATE TABLE perfis (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL UNIQUE
    )");

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
        avatar_url TEXT,
        fcm_token TEXT,
        ativo INTEGER DEFAULT 1,
        ultimo_login TEXT,
        cadastro TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(perfil_id) REFERENCES perfis(id)
    )");

    $db->exec("CREATE TABLE tutor_paciente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER NOT NULL,
        tutor_id INTEGER NOT NULL,
        principal INTEGER DEFAULT 0,
        data_vinculo TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(paciente_id, tutor_id),
        FOREIGN KEY(paciente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY(tutor_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )");

    $db->exec("CREATE TABLE dispositivos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        codigo_identificador TEXT UNIQUE NOT NULL,
        nome TEXT,
        modelo TEXT,
        versao_firmware TEXT,
        status TEXT DEFAULT 'ATIVO',
        ultima_comunicacao TEXT,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
    )");

    $db->exec("CREATE TABLE batimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        dispositivo_id INTEGER,
        bpm REAL NOT NULL,
        saturacao REAL,
        pressao_sistolica INTEGER,
        pressao_diastolica INTEGER,
        temperatura REAL,
        classificacao TEXT DEFAULT 'NORMAL',
        origem TEXT DEFAULT 'MANUAL',
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY(dispositivo_id) REFERENCES dispositivos(id) ON DELETE SET NULL
    )");
    $db->exec("CREATE INDEX idx_batimentos_usuario_timestamp ON batimentos(usuario_id, timestamp)");

    $db->exec("CREATE TABLE configuracoes_cardiacas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER UNIQUE NOT NULL,
        bpm_minimo INTEGER DEFAULT 60,
        bpm_maximo INTEGER DEFAULT 100,
        bpm_critico_baixo INTEGER DEFAULT 40,
        bpm_critico_alto INTEGER DEFAULT 140,
        notificar_tutor INTEGER DEFAULT 1,
        intervalo_leitura INTEGER DEFAULT 5,
        condicao_cardiaca TEXT,
        frequencia_media INTEGER,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )");

    $db->exec("CREATE TABLE alertas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        bpm_momento REAL,
        descricao TEXT,
        visto INTEGER DEFAULT 0,
        data_hora TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )");

    $db->exec("CREATE TABLE emergencia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        alerta_id INTEGER,
        latitude REAL,
        longitude REAL,
        status TEXT DEFAULT 'PENDENTE',
        data_hora TEXT DEFAULT CURRENT_TIMESTAMP,
        data_resolucao TEXT,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
        FOREIGN KEY(alerta_id) REFERENCES alertas(id) ON DELETE SET NULL
    )");

    $db->exec("CREATE TABLE notificacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        titulo TEXT,
        mensagem TEXT,
        lida INTEGER DEFAULT 0,
        tipo TEXT,
        data_envio TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )");

    $db->exec("CREATE TABLE recuperacoes_senha (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        token TEXT NOT NULL UNIQUE,
        expiracao TEXT NOT NULL,
        usado INTEGER DEFAULT 0,
        criado_em TEXT DEFAULT CURRENT_TIMESTAMP
    )");

    $db->exec("CREATE TABLE relatorios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        data_inicio TEXT,
        data_fim TEXT,
        media_bpm REAL,
        bpm_max REAL,
        bpm_min REAL,
        total_alertas INTEGER DEFAULT 0,
        obs_ia TEXT,
        file_path TEXT,
        data_geracao TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )");

    $db->exec("CREATE TABLE auditoria (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        acao TEXT,
        tabela_afetada TEXT,
        registro_id INTEGER,
        dados_anteriores TEXT,
        dados_novos TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
    )");

    echo "Seeding demo users...\n";

    $db->exec("INSERT INTO perfis (id, nome) VALUES (1, 'PACIENTE'), (2, 'TUTOR'), (3, 'ADMIN')");

    $insertUser = $db->prepare("INSERT INTO usuarios (perfil_id, nome, email, senha, idade, tipo_sanguineo, ativo) VALUES (:perfil, :nome, :email, :senha, :idade, :sangue, 1)");
    $users = [
        [3, 'Administrador Koavy', 'admin@koavy.com', 'admin123', null, null],
        [1, 'Paciente Koavy', 'paciente@koavy.com', 'paciente123', 38, 'O+'],
        [2, 'Tutor Koavy', 'tutor@koavy.com', 'tutor123', 42, null],
    ];

    foreach ($users as $user) {
        $insertUser->execute([
            'perfil' => $user[0],
            'nome' => $user[1],
            'email' => $user[2],
            'senha' => password_hash($user[3], PASSWORD_BCRYPT),
            'idade' => $user[4],
            'sangue' => $user[5],
        ]);
        $userId = (int)$db->lastInsertId();
        $db->prepare("INSERT INTO configuracoes_cardiacas (usuario_id) VALUES (:uid)")->execute(['uid' => $userId]);
    }

    $db->exec("INSERT INTO tutor_paciente (paciente_id, tutor_id, principal) VALUES (2, 3, 1)");

    echo "SUCCESS: Local database initialized at {$dbPath}.\n";
} catch (Exception $e) {
    die("FATAL ERROR: " . $e->getMessage() . "\n");
}
