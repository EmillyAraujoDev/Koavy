<?php
// api/src/Controllers/UsuarioController.php

namespace App\Controllers;

use App\Database;
use App\JWTHelper;
use PDO;

class UsuarioController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function login($data) {
        if (!isset($data['email']) || !isset($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "E-mail e senha são obrigatórios"]];
        }

        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE email = :email AND ativo = 1");
        $stmt->execute(['email' => $data['email']]);
        $user = $stmt->fetch();

        if ($user && password_verify($data['senha'], $user['senha'])) {
            $token = JWTHelper::generate([
                'id' => $user['id'],
                'email' => $user['email'],
                'perfilId' => $user['perfil_id']
            ]);

            unset($user['senha']);
            return ["status" => 200, "data" => [
                "user" => $user,
                "token" => $token
            ]];
        }

        return ["status" => 401, "data" => ["message" => "E-mail ou senha inválidos"]];
    }

    public function cadastrar($data) {
        // Validações básicas
        if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "Dados incompletos"]];
        }

        $hash = password_hash($data['senha'], PASSWORD_BCRYPT);

        $sql = "INSERT INTO usuarios (perfil_id, nome, email, senha, idade, sexo, telefone) 
                VALUES (:perfil_id, :nome, :email, :senha, :idade, :sexo, :telefone)";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'perfil_id' => $data['perfil_id'] ?? 1,
                'nome' => $data['nome'],
                'email' => $data['email'],
                'senha' => $hash,
                'idade' => $data['idade'] ?? null,
                'sexo' => $data['sexo'] ?? 'O',
                'telefone' => $data['telefone'] ?? null
            ]);

            return ["status" => 201, "data" => ["message" => "Usuário cadastrado com sucesso", "id" => $this->db->lastInsertId()]];
        } catch (\PDOException $e) {
            if ($e->getCode() == 23000) {
                return ["status" => 409, "data" => ["message" => "E-mail já cadastrado"]];
            }
            return ["status" => 500, "data" => ["message" => "Erro interno: " . $e->getMessage()]];
        }
    }
}
