<?php
// api/src/Controllers/VinculoController.php

namespace App\Controllers;

use App\Database;
use PDO;

class VinculoController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function vincular($data, $authTutorId = null) {
        $pacienteId = $data['pacienteId'] ?? $data['paciente_id'] ?? null;
        if (!$pacienteId) {
            return ["status" => 400, "data" => ["message" => "ID do paciente é obrigatório"]];
        }

        // Verificar se o paciente existe e tem perfil de Paciente (perfil_id = 1)
        $stmtPac = $this->db->prepare("SELECT id FROM usuarios WHERE id = :pid AND perfil_id = 1 AND ativo = 1");
        $stmtPac->execute(['pid' => $pacienteId]);
        if (!$stmtPac->fetch()) {
            return ["status" => 404, "data" => ["message" => "Paciente ativo não encontrado"]];
        }

        $tutorId = $authTutorId;

        // Se o tutor não estiver logado, realiza o fluxo de cadastro do Tutor
        if (!$tutorId) {
            $nome = htmlspecialchars(strip_tags($data['nome'] ?? $data['nomeTutor'] ?? ''));
            $email = filter_var($data['email'] ?? '', FILTER_VALIDATE_EMAIL);
            $senha = $data['senha'] ?? null;
            $telefone = htmlspecialchars(strip_tags($data['telefone'] ?? ''));

            if (empty($nome) || !$email || empty($senha)) {
                return ["status" => 400, "data" => ["message" => "Para cadastrar um tutor, informe Nome completo, E-mail válido e Senha"]];
            }

            // Verificar se o e-mail já existe
            $stmtCheck = $this->db->prepare("SELECT id FROM usuarios WHERE email = :email");
            $stmtCheck->execute(['email' => $email]);
            if ($stmtCheck->fetch()) {
                return ["status" => 409, "data" => ["message" => "E-mail de tutor já cadastrado"]];
            }

            // Hashing da senha
            $hash = password_hash($senha, PASSWORD_BCRYPT);

            // Inserir Tutor no banco
            $sqlTutor = "INSERT INTO usuarios (perfil_id, nome, email, senha, telefone, ativo) 
                         VALUES (2, :nome, :email, :senha, :telefone, 1)";
            $stmtTutor = $this->db->prepare($sqlTutor);
            try {
                $stmtTutor->execute([
                    'nome' => $nome,
                    'email' => $email,
                    'senha' => $hash,
                    'telefone' => $telefone
                ]);
                $tutorId = $this->db->lastInsertId();
            } catch (\PDOException $e) {
                error_log("Erro ao cadastrar tutor: " . $e->getMessage());
                return ["status" => 500, "data" => ["message" => "Erro interno ao cadastrar tutor."]];
            }
        }

        // Criar o vínculo na tabela tutor_paciente
        $stmtCheckVinculo = $this->db->prepare("SELECT id FROM tutor_paciente WHERE paciente_id = :pid AND tutor_id = :tid");
        $stmtCheckVinculo->execute(['pid' => $pacienteId, 'tid' => $tutorId]);
        if ($stmtCheckVinculo->fetch()) {
            return ["status" => 200, "data" => ["message" => "Vínculo já existente", "tutorId" => $tutorId]];
        }

        $sqlLink = "INSERT INTO tutor_paciente (paciente_id, tutor_id, principal) VALUES (:pid, :tid, 0)";
        $stmtLink = $this->db->prepare($sqlLink);
        try {
            $stmtLink->execute(['pid' => $pacienteId, 'tid' => $tutorId]);
            return ["status" => 201, "data" => ["message" => "Tutor vinculado com sucesso", "tutorId" => $tutorId]];
        } catch (\PDOException $e) {
            error_log("Erro ao vincular tutor: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao vincular tutor."]];
        }
    }

    public function getTutoresPaciente($pacienteId) {
        $sql = "SELECT tp.id, tp.principal, tp.data_vinculo, u.id as tutor_id, u.nome, u.email, u.telefone
                FROM tutor_paciente tp
                INNER JOIN usuarios u ON u.id = tp.tutor_id
                WHERE tp.paciente_id = :paciente_id AND u.ativo = 1
                ORDER BY tp.principal DESC, u.nome ASC";

        try {
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['paciente_id' => $pacienteId]);
            $rows = $stmt->fetchAll();

            $mapped = array_map(function($row) {
                return [
                    'id' => $row['id'],
                    'tutorId' => $row['tutor_id'],
                    'nome' => $row['nome'],
                    'email' => $row['email'],
                    'telefone' => $row['telefone'],
                    'principal' => (bool)$row['principal'],
                    'dataVinculo' => $row['data_vinculo'] ?? null
                ];
            }, $rows);

            return ["status" => 200, "data" => $mapped];
        } catch (\PDOException $e) {
            error_log("Erro ao buscar tutores do paciente: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao buscar tutores."]];
        }
    }

    public function remover($vinculoId, $auth) {
        if (!$auth) {
            return ["status" => 401, "data" => ["message" => "Não autorizado"]];
        }

        try {
            $stmt = $this->db->prepare("SELECT tutor_id, paciente_id FROM tutor_paciente WHERE id = :id");
            $stmt->execute(['id' => $vinculoId]);
            $vinculo = $stmt->fetch();

            if (!$vinculo) {
                return ["status" => 404, "data" => ["message" => "Vínculo não encontrado"]];
            }

            $perfil = $auth['perfilId'] ?? null;
            $canRemove = $perfil == 3 || $auth['id'] == $vinculo['tutor_id'] || $auth['id'] == $vinculo['paciente_id'];
            if (!$canRemove) {
                return ["status" => 403, "data" => ["message" => "Acesso proibido"]];
            }

            $stmtDelete = $this->db->prepare("DELETE FROM tutor_paciente WHERE id = :id");
            $stmtDelete->execute(['id' => $vinculoId]);

            return ["status" => 200, "data" => ["message" => "Vínculo removido com sucesso"]];
        } catch (\PDOException $e) {
            error_log("Erro ao remover vinculo: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao remover vínculo."]];
        }
    }

    public function getPacientesTutor($tutorId) {
        $sql = "SELECT u.*, 
                       (SELECT bpm FROM batimentos WHERE usuario_id = u.id ORDER BY timestamp DESC LIMIT 1) as ultimo_bpm,
                       (SELECT saturacao FROM batimentos WHERE usuario_id = u.id ORDER BY timestamp DESC LIMIT 1) as ultima_saturacao,
                       (SELECT timestamp FROM batimentos WHERE usuario_id = u.id ORDER BY timestamp DESC LIMIT 1) as ultimo_timestamp
                FROM usuarios u
                INNER JOIN tutor_paciente tp ON tp.paciente_id = u.id
                WHERE tp.tutor_id = :tutor_id AND u.ativo = 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['tutor_id' => $tutorId]);
        $rows = $stmt->fetchAll();

        // Mapear compatibilidade
        $mapped = array_map(function($row) {
            unset($row['senha']); // segurança
            $row['perfilId'] = $row['perfil_id'];
            $row['dataNascimento'] = $row['data_nascimento'];
            $row['tipoSanguineo'] = $row['tipo_sanguineo'];
            $row['obsMed'] = $row['obs_med'];
            $row['ultimoBpm'] = $row['ultimo_bpm'];
            $row['ultimaSaturacao'] = $row['ultima_saturacao'];
            $row['ultimoTimestamp'] = $row['ultimo_timestamp'];
            return $row;
        }, $rows);

        return ["status" => 200, "data" => $mapped];
    }
}
