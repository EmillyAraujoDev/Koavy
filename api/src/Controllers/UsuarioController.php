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

    private function mapUserKeys($user) {
        if (!$user) return null;
        unset($user['senha']); // remover senha por segurança
        $user['perfilId'] = $user['perfil_id'] ?? null;
        $user['dataNascimento'] = $user['data_nascimento'] ?? null;
        $user['tipoSanguineo'] = $user['tipo_sanguineo'] ?? null;
        $user['obsMed'] = $user['obs_med'] ?? null;
        $user['avatarUrl'] = $user['avatar_url'] ?? null;
        $user['fcmToken'] = $user['fcm_token'] ?? null;
        $user['ultimoLogin'] = $user['ultimo_login'] ?? null;
        return $user;
    }

    public function login($data) {
        if (!isset($data['email']) || !isset($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "E-mail e senha são obrigatórios"]];
        }

        $email = filter_var($data['email'], FILTER_VALIDATE_EMAIL);
        if (!$email) {
            return ["status" => 400, "data" => ["message" => "Formato de e-mail inválido"]];
        }

        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE email = :email AND ativo = 1");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if ($user && password_verify($data['senha'], $user['senha'])) {
            $token = JWTHelper::generate([
                'id' => $user['id'],
                'email' => $user['email'],
                'perfilId' => $user['perfil_id']
            ]);

            // Atualiza data do último login
            $stmtUpdate = $this->db->prepare("UPDATE usuarios SET ultimo_login = NOW() WHERE id = :id");
            $stmtUpdate->execute(['id' => $user['id']]);

            $mappedUser = $this->mapUserKeys($user);

            return ["status" => 200, "data" => [
                "user" => $mappedUser,
                "token" => $token
            ]];
        }

        return ["status" => 401, "data" => ["message" => "E-mail ou senha inválidos"]];
    }

    public function cadastrar($data) {
        // Validações básicas
        if (empty($data['nome']) || empty($data['email']) || empty($data['senha'])) {
            return ["status" => 400, "data" => ["message" => "Dados obrigatórios incompletos"]];
        }

        $nome = htmlspecialchars(strip_tags($data['nome']));
        $email = filter_var($data['email'], FILTER_VALIDATE_EMAIL);
        $senha = $data['senha'];

        if (!$email) {
            return ["status" => 400, "data" => ["message" => "E-mail em formato inválido"]];
        }

        if (strlen($senha) < 8) {
            return ["status" => 400, "data" => ["message" => "A senha deve possuir no mínimo 8 caracteres"]];
        }

        $hash = password_hash($senha, PASSWORD_BCRYPT);

        // Mapear campos opcionais clínicos e de perfil
        $perfil_id = $data['perfilId'] ?? $data['perfil_id'] ?? 1;
        $idade = isset($data['idade']) ? (int)$data['idade'] : null;
        $data_nascimento = $data['dataNascimento'] ?? $data['data_nascimento'] ?? null;
        $sexo = $data['sexo'] ?? 'O';
        $telefone = htmlspecialchars(strip_tags($data['telefone'] ?? ''));
        $tipo_sanguineo = $data['tipoSanguineo'] ?? $data['tipo_sanguineo'] ?? null;
        $peso = isset($data['peso']) ? (float)$data['peso'] : null;
        $altura = isset($data['altura']) ? (float)$data['altura'] : null;
        $marcapasso = isset($data['marcapasso']) ? (bool)$data['marcapasso'] : false;
        $obs_med = htmlspecialchars(strip_tags($data['obsMed'] ?? $data['obs_med'] ?? ''));
        $cep = htmlspecialchars(strip_tags($data['cep'] ?? ''));

        $sql = "INSERT INTO usuarios (perfil_id, nome, email, senha, idade, data_nascimento, sexo, telefone, tipo_sanguineo, peso, altura, marcapasso, obs_med, cep, ativo) 
                VALUES (:perfil_id, :nome, :email, :senha, :idade, :data_nascimento, :sexo, :telefone, :tipo_sanguineo, :peso, :altura, :marcapasso, :obs_med, :cep, 1)";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'perfil_id' => $perfil_id,
                'nome' => $nome,
                'email' => $email,
                'senha' => $hash,
                'idade' => $idade,
                'data_nascimento' => $data_nascimento,
                'sexo' => $sexo,
                'telefone' => $telefone,
                'tipo_sanguineo' => $tipo_sanguineo,
                'peso' => $peso,
                'altura' => $altura,
                'marcapasso' => $marcapasso ? 1 : 0,
                'obs_med' => $obs_med,
                'cep' => $cep
            ]);

            $newId = $this->db->lastInsertId();

            return ["status" => 201, "data" => [
                "message" => "Usuário cadastrado com sucesso",
                "id" => $newId
            ]];
        } catch (\PDOException $e) {
            if ($e->getCode() == 23000) {
                return ["status" => 409, "data" => ["message" => "E-mail já cadastrado"]];
            }
            return ["status" => 500, "data" => ["message" => "Erro interno: " . $e->getMessage()]];
        }
    }

    public function getTodos() {
        $stmt = $this->db->query("SELECT * FROM usuarios ORDER BY nome ASC");
        $users = $stmt->fetchAll();
        $mapped = array_map([$this, 'mapUserKeys'], $users);
        return ["status" => 200, "data" => $mapped];
    }

    public function getPorId($id) {
        $stmt = $this->db->prepare("SELECT * FROM usuarios WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();
        if (!$user) {
            return ["status" => 404, "data" => ["message" => "Usuário não encontrado"]];
        }
        return ["status" => 200, "data" => $this->mapUserKeys($user)];
    }

    public function atualizar($id, $data) {
        // Verificar se usuário existe
        $stmtCheck = $this->db->prepare("SELECT * FROM usuarios WHERE id = :id");
        $stmtCheck->execute(['id' => $id]);
        $user = $stmtCheck->fetch();
        if (!$user) {
            return ["status" => 404, "data" => ["message" => "Usuário não encontrado"]];
        }

        // Ler campos e mesclar
        $nome = htmlspecialchars(strip_tags($data['nome'] ?? $user['nome']));
        $email = filter_var($data['email'] ?? $user['email'], FILTER_VALIDATE_EMAIL);
        if (!$email) {
            return ["status" => 400, "data" => ["message" => "E-mail inválido"]];
        }

        $telefone = htmlspecialchars(strip_tags($data['telefone'] ?? $user['telefone'] ?? ''));
        $peso = isset($data['peso']) ? (float)$data['peso'] : ($user['peso'] ? (float)$user['peso'] : null);
        $altura = isset($data['altura']) ? (float)$data['altura'] : ($user['altura'] ? (float)$user['altura'] : null);
        $tipo_sanguineo = $data['tipoSanguineo'] ?? $data['tipo_sanguineo'] ?? $user['tipo_sanguineo'];
        $cep = htmlspecialchars(strip_tags($data['cep'] ?? $user['cep'] ?? ''));
        $ativo = isset($data['ativo']) ? ($data['ativo'] ? 1 : 0) : $user['ativo'];
        $sexo = $data['sexo'] ?? $user['sexo'];
        $idade = isset($data['idade']) ? (int)$data['idade'] : ($user['idade'] ? (int)$user['idade'] : null);
        $data_nascimento = $data['dataNascimento'] ?? $data['data_nascimento'] ?? $user['data_nascimento'];
        $marcapasso = isset($data['marcapasso']) ? ($data['marcapasso'] ? 1 : 0) : $user['marcapasso'];
        $obs_med = htmlspecialchars(strip_tags($data['obsMed'] ?? $data['obs_med'] ?? $user['obs_med'] ?? ''));

        // Se uma nova senha for fornecida e for diferente do hash atual
        $senha = $user['senha'];
        if (!empty($data['senha']) && strpos($data['senha'], '$2y$') !== 0) {
            if (strlen($data['senha']) < 8) {
                return ["status" => 400, "data" => ["message" => "A nova senha deve possuir no mínimo 8 caracteres"]];
            }
            $senha = password_hash($data['senha'], PASSWORD_BCRYPT);
        }

        $sql = "UPDATE usuarios SET 
                    nome = :nome,
                    email = :email,
                    senha = :senha,
                    telefone = :telefone,
                    peso = :peso,
                    altura = :altura,
                    tipo_sanguineo = :tipo_sanguineo,
                    cep = :cep,
                    ativo = :ativo,
                    sexo = :sexo,
                    idade = :idade,
                    data_nascimento = :data_nascimento,
                    marcapasso = :marcapasso,
                    obs_med = :obs_med
                WHERE id = :id";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'nome' => $nome,
                'email' => $email,
                'senha' => $senha,
                'telefone' => $telefone,
                'peso' => $peso,
                'altura' => $altura,
                'tipo_sanguineo' => $tipo_sanguineo,
                'cep' => $cep,
                'ativo' => $ativo,
                'sexo' => $sexo,
                'idade' => $idade,
                'data_nascimento' => $data_nascimento,
                'marcapasso' => $marcapasso,
                'obs_med' => $obs_med,
                'id' => $id
            ]);

            // Obter registro atualizado
            $stmtUpdated = $this->db->prepare("SELECT * FROM usuarios WHERE id = :id");
            $stmtUpdated->execute(['id' => $id]);
            $updatedUser = $stmtUpdated->fetch();

            return ["status" => 200, "data" => $this->mapUserKeys($updatedUser)];
        } catch (\PDOException $e) {
            return ["status" => 500, "data" => ["message" => "Erro ao atualizar usuário: " . $e->getMessage()]];
        }
    }
}
