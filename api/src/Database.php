<?php
// api/src/Database.php

namespace App;

use PDO;
use PDOException;

class Database {
    private static $instance = null;
    private $conn;
    private $config;

    private function __construct() {
        $config = require __DIR__ . '/../config/database.php';
        $this->config = $config;
        try {
            if (isset($config['driver']) && $config['driver'] === 'sqlite') {
                $this->conn = new PDO("sqlite:" . $config['path'], null, null, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
                ]);
            } else {
                $dsn = "mysql:host={$config['host']};dbname={$config['dbname']};charset={$config['charset']}";
                $this->conn = new PDO($dsn, $config['user'], $config['pass'], [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::ATTR_PERSISTENT => true
                ]);
            }
            $this->runMigrations();
        } catch (PDOException $e) {
            // Em produção, não exiba detalhes do erro para o usuário final
            error_log("Erro de conexão no banco: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(["message" => "Erro interno no servidor. Verifique a conexão com o banco de dados."]);
            exit;
        }
    }

    public static function getInstance() {
        if (!self::$instance) {
            self::$instance = new self();
        }
        return self::$instance->getConnection();
    }

    public function getConnection() {
        return $this->conn;
    }

    private function isSqlite() {
        return isset($this->config['driver']) && $this->config['driver'] === 'sqlite';
    }

    private function columnExists($table, $column) {
        if ($this->isSqlite()) {
            $stmt = $this->conn->query("PRAGMA table_info($table)");
            foreach ($stmt->fetchAll() as $row) {
                if (($row['name'] ?? null) === $column) return true;
            }
            return false;
        }

        $stmt = $this->conn->prepare("SHOW COLUMNS FROM `$table` LIKE :column");
        $stmt->execute(['column' => $column]);
        return (bool)$stmt->fetch();
    }

    private function addColumnIfMissing($table, $column, $definition) {
        if ($this->columnExists($table, $column)) return;
        $this->conn->exec("ALTER TABLE $table ADD COLUMN $column $definition");
    }

    private function runMigrations() {
        if (!$this->isSqlite()) return;

        $this->conn->exec("PRAGMA foreign_keys = ON");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS perfis (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL UNIQUE
        )");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS usuarios (
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
            cadastro TEXT DEFAULT CURRENT_TIMESTAMP
        )");

        $this->addColumnIfMissing('usuarios', 'idade', 'INTEGER');
        $this->addColumnIfMissing('usuarios', 'data_nascimento', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'sexo', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'telefone', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'tipo_sanguineo', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'peso', 'REAL');
        $this->addColumnIfMissing('usuarios', 'altura', 'REAL');
        $this->addColumnIfMissing('usuarios', 'marcapasso', 'INTEGER DEFAULT 0');
        $this->addColumnIfMissing('usuarios', 'obs_med', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'cep', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'avatar_url', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'fcm_token', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'ativo', 'INTEGER DEFAULT 1');
        $this->addColumnIfMissing('usuarios', 'ultimo_login', 'TEXT');
        $this->addColumnIfMissing('usuarios', 'cadastro', 'TEXT DEFAULT CURRENT_TIMESTAMP');

        $this->conn->exec("CREATE TABLE IF NOT EXISTS dispositivos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER,
            codigo_identificador TEXT UNIQUE NOT NULL,
            nome TEXT,
            modelo TEXT,
            versao_firmware TEXT,
            status TEXT DEFAULT 'ATIVO',
            ultima_comunicacao TEXT,
            criado_em TEXT DEFAULT CURRENT_TIMESTAMP
        )");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS batimentos (
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
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP
        )");
        $this->addColumnIfMissing('batimentos', 'dispositivo_id', 'INTEGER');
        $this->addColumnIfMissing('batimentos', 'pressao_sistolica', 'INTEGER');
        $this->addColumnIfMissing('batimentos', 'pressao_diastolica', 'INTEGER');
        $this->addColumnIfMissing('batimentos', 'temperatura', 'REAL');
        $this->addColumnIfMissing('batimentos', 'classificacao', "TEXT DEFAULT 'NORMAL'");
        $this->addColumnIfMissing('batimentos', 'origem', "TEXT DEFAULT 'MANUAL'");
        $this->conn->exec("CREATE INDEX IF NOT EXISTS idx_batimentos_usuario_timestamp ON batimentos(usuario_id, timestamp)");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS configuracoes_cardiacas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER UNIQUE NOT NULL,
            bpm_minimo INTEGER DEFAULT 60,
            bpm_maximo INTEGER DEFAULT 100,
            bpm_critico_baixo INTEGER DEFAULT 40,
            bpm_critico_alto INTEGER DEFAULT 140,
            notificar_tutor INTEGER DEFAULT 1,
            intervalo_leitura INTEGER DEFAULT 5,
            condicao_cardiaca TEXT,
            frequencia_media INTEGER
        )");
        $this->addColumnIfMissing('configuracoes_cardiacas', 'bpm_minimo', 'INTEGER DEFAULT 60');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'bpm_maximo', 'INTEGER DEFAULT 100');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'bpm_critico_baixo', 'INTEGER DEFAULT 40');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'bpm_critico_alto', 'INTEGER DEFAULT 140');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'notificar_tutor', 'INTEGER DEFAULT 1');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'intervalo_leitura', 'INTEGER DEFAULT 5');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'condicao_cardiaca', 'TEXT');
        $this->addColumnIfMissing('configuracoes_cardiacas', 'frequencia_media', 'INTEGER');

        $this->conn->exec("CREATE TABLE IF NOT EXISTS alertas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL,
            tipo TEXT NOT NULL,
            bpm_momento REAL,
            descricao TEXT,
            visto INTEGER DEFAULT 0,
            data_hora TEXT DEFAULT CURRENT_TIMESTAMP
        )");
        $this->addColumnIfMissing('alertas', 'visto', 'INTEGER DEFAULT 0');

        $this->conn->exec("CREATE TABLE IF NOT EXISTS emergencia (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL,
            alerta_id INTEGER,
            latitude REAL,
            longitude REAL,
            status TEXT DEFAULT 'PENDENTE',
            data_hora TEXT DEFAULT CURRENT_TIMESTAMP,
            data_resolucao TEXT
        )");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS tutor_paciente (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            paciente_id INTEGER NOT NULL,
            tutor_id INTEGER NOT NULL,
            principal INTEGER DEFAULT 0,
            data_vinculo TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(paciente_id, tutor_id)
        )");

        $this->conn->exec("CREATE TABLE IF NOT EXISTS recuperacoes_senha (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            token TEXT NOT NULL UNIQUE,
            expiracao TEXT NOT NULL,
            usado INTEGER DEFAULT 0,
            criado_em TEXT DEFAULT CURRENT_TIMESTAMP
        )");
        $this->addColumnIfMissing('recuperacoes_senha', 'usado', 'INTEGER DEFAULT 0');
        $this->addColumnIfMissing('recuperacoes_senha', 'criado_em', 'TEXT DEFAULT CURRENT_TIMESTAMP');

        $this->conn->exec("CREATE TABLE IF NOT EXISTS relatorios (
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
            data_geracao TEXT DEFAULT CURRENT_TIMESTAMP
        )");
        $this->addColumnIfMissing('relatorios', 'total_alertas', 'INTEGER DEFAULT 0');
        $this->addColumnIfMissing('relatorios', 'data_inicio', 'TEXT');
        $this->addColumnIfMissing('relatorios', 'data_fim', 'TEXT');
        $this->addColumnIfMissing('relatorios', 'file_path', 'TEXT');

        $this->seedBaseData();
    }

    private function seedBaseData() {
        $stmt = $this->conn->prepare("INSERT OR IGNORE INTO perfis (id, nome) VALUES (:id, :nome)");
        foreach ([[1, 'PACIENTE'], [2, 'TUTOR'], [3, 'ADMIN']] as $perfil) {
            $stmt->execute(['id' => $perfil[0], 'nome' => $perfil[1]]);
        }

        $users = [
            ['perfil_id' => 3, 'nome' => 'Administrador Koavy', 'email' => 'admin@koavy.com', 'senha' => 'admin123'],
            ['perfil_id' => 1, 'nome' => 'Paciente Koavy', 'email' => 'paciente@koavy.com', 'senha' => 'paciente123'],
            ['perfil_id' => 2, 'nome' => 'Tutor Koavy', 'email' => 'tutor@koavy.com', 'senha' => 'tutor123'],
        ];

        $select = $this->conn->prepare("SELECT id, senha FROM usuarios WHERE email = :email");
        $insert = $this->conn->prepare("INSERT INTO usuarios (perfil_id, nome, email, senha, ativo) VALUES (:perfil_id, :nome, :email, :senha, 1)");
        $update = $this->conn->prepare("UPDATE usuarios SET perfil_id = :perfil_id, nome = :nome, senha = :senha, ativo = 1 WHERE email = :email");
        $insertConfig = $this->conn->prepare("INSERT OR IGNORE INTO configuracoes_cardiacas (usuario_id) VALUES (:uid)");

        foreach ($users as $user) {
            $select->execute(['email' => $user['email']]);
            $existing = $select->fetch();
            $hash = password_hash($user['senha'], PASSWORD_BCRYPT);

            if ($existing) {
                if (!password_verify($user['senha'], $existing['senha'])) {
                    $update->execute([
                        'perfil_id' => $user['perfil_id'],
                        'nome' => $user['nome'],
                        'email' => $user['email'],
                        'senha' => $hash
                    ]);
                }
                $userId = $existing['id'];
            } else {
                $insert->execute([
                    'perfil_id' => $user['perfil_id'],
                    'nome' => $user['nome'],
                    'email' => $user['email'],
                    'senha' => $hash
                ]);
                $userId = $this->conn->lastInsertId();
            }

            $insertConfig->execute(['uid' => $userId]);
        }
    }
}
