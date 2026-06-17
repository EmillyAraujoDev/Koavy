<?php
// api/src/Database.php

namespace App;

use PDO;
use PDOException;

class Database {
    private static $instance = null;
    private $conn;

    private function __construct() {
        $config = require __DIR__ . '/../config/database.php';
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
}
