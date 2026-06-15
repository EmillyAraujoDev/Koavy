<?php
// api/src/Controllers/TutorController.php

namespace App\Controllers;

use App\Database;
use PDO;

class TutorController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function vincular($data) {
        if (!isset($data['pacienteId']) || !isset($data['nome'])) {
            return ["status" => 400, "data" => ["message" => "Dados incompletos"]];
        }

        // 1. Verificar se o tutor existe ou criar um registro básico
        // Aqui assumimos que o 'nome' do tutor é para um novo registro ou identificação.
        // Em um sistema real, o tutor já deveria estar logado.
        
        // Vamos tentar encontrar um usuário com esse nome (simulando que ele já existe)
        // Ou, se o sistema permite vincular sem login prévio (fluxo de cadastro),
        // precisaríamos criar o usuário Tutor primeiro.
        
        // Para simplificar e seguir o fluxo do frontend:
        // Procuramos um usuário com perfil 2 (TUTOR) e nome X, ou criamos um temporário.
        
        // Melhor abordagem para o fluxo atual:
        // O tutor deveria ser um usuário real. Se ele está preenchendo o formulário,
        // talvez ele deva ser criado agora.
        
        // No entanto, o frontend não pede e-mail nem senha do tutor.
        // Isso sugere que o tutor é apenas um nome vinculado ao paciente.
        // Mas a tabela `usuarios` requer email/senha se seguirmos o schema V2.
        
        // Vou verificar se existe um usuário com esse nome para ser o tutor.
        $stmt = $this->db->prepare("SELECT id FROM usuarios WHERE nome = :nome AND perfil_id = 2 LIMIT 1");
        $stmt->execute(['nome' => $data['nome']]);
        $tutor = $stmt->fetch();

        if (!$tutor) {
            // Se não existe, criamos um usuário tutor básico (precisaria de email/senha fake ou convite)
            // Para não quebrar o fluxo, vou criar um registro "fantasma" ou retornar erro.
            // Mas o ideal é que o tutor já tenha conta.
            
            // Vamos assumir que para este MVP, se não achar, criamos um.
            try {
                $stmtCreate = $this->db->prepare("INSERT INTO usuarios (nome, email, senha, perfil_id, ativo) VALUES (:nome, :email, 'NP', 2, 1)");
                $emailFake = strtolower(str_replace(' ', '.', $data['nome'])) . "@tutor.koavy.com";
                $stmtCreate->execute(['nome' => $data['nome'], 'email' => $emailFake]);
                $tutorId = $this->db->lastInsertId();
            } catch (\PDOException $e) {
                return ["status" => 500, "data" => ["message" => "Erro ao criar registro de tutor"]];
            }
        } else {
            $tutorId = $tutor['id'];
        }

        // 2. Criar vínculo na tabela tutor_paciente
        $sql = "INSERT INTO tutor_paciente (paciente_id, tutor_id, principal, data_vinculo) 
                VALUES (:pid, :tid, :principal, CURRENT_TIMESTAMP)
                ON DUPLICATE KEY UPDATE principal = :principal";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'pid' => $data['pacienteId'],
                'tid' => $tutorId,
                'principal' => $data['principal'] ? 1 : 0
            ]);

            return ["status" => 201, "data" => ["message" => "Vínculo criado com sucesso"]];
        } catch (\PDOException $e) {
            return ["status" => 500, "data" => ["message" => "Erro ao criar vínculo: " . $e->getMessage()]];
        }
    }
}
