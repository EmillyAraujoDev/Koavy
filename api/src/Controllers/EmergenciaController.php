<?php
// api/src/Controllers/EmergenciaController.php

namespace App\Controllers;

use App\Database;
use PDO;

class EmergenciaController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function registrar($data, $userId) {
<<<<<<< HEAD
        // Validação de dados
        if (!isset($data['batMomento'])) {
            return ["status" => 400, "data" => ["message" => "Dados de batimento incompletos"]];
        }

        $sql = "INSERT INTO emergencia (usuario_id, latitude, longitude, status) 
                VALUES (:uid, :lat, :lng, 'PENDENTE')";
        
        $stmt = $this->db->prepare($sql);
        try {
            $stmt->execute([
                'uid' => $userId,
                'lat' => $data['latitude'] ?? null,
                'lng' => $data['longitude'] ?? null
            ]);

            $emergenciaId = $this->db->lastInsertId();

            // Também criar um alerta associado se necessário
            $stmtAlerta = $this->db->prepare("INSERT INTO alertas (usuario_id, tipo, bpm_momento, descricao) 
                                             VALUES (:uid, 'TAQUICARDIA', :bpm, :desc)");
            $stmtAlerta->execute([
                'uid' => $userId,
                'bpm' => $data['batMomento'],
                'desc' => $data['descricao'] ?? "Emergência acionada automaticamente"
            ]);

            return ["status" => 201, "data" => ["message" => "Emergência registrada", "id" => $emergenciaId]];
        } catch (\PDOException $e) {
            error_log("Erro ao registrar emergência: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao registrar emergência"]];
        }
    }

    public function getHistorico($userId) {
        $stmt = $this->db->prepare("SELECT e.*, a.tipo, a.bpm_momento as batMomento, a.descricao 
                                   FROM emergencia e 
                                   LEFT JOIN alertas a ON e.alerta_id = a.id
                                   WHERE e.usuario_id = :uid 
                                   ORDER BY e.data_hora DESC LIMIT 10");
        $stmt->execute(['uid' => $userId]);
        $emergencias = $stmt->fetchAll();

        // Se não houver alertas vinculados via alerta_id (novo schema), tenta buscar alertas soltos para compatibilidade
        if (empty($emergencias)) {
            $stmt = $this->db->prepare("SELECT id as id, usuario_id, tipo, bpm_momento as batMomento, descricao, data_hora 
                                       FROM alertas WHERE usuario_id = :uid ORDER BY data_hora DESC LIMIT 10");
            $stmt->execute(['uid' => $userId]);
            $emergencias = $stmt->fetchAll();
        }

        return ["status" => 200, "data" => $emergencias];
=======
        $bpm = $data['batMomento'] ?? $data['bpm_momento'] ?? null;
        $saturacao = $data['satMomento'] ?? $data['saturacao'] ?? null;
        $tipo = htmlspecialchars(strip_tags($data['tipo'] ?? 'CRITICO'));
        $descricao = htmlspecialchars(strip_tags($data['descricao'] ?? "Alerta de emergência cardíaca"));
        $latitude = isset($data['latitude']) ? (float)$data['latitude'] : null;
        $longitude = isset($data['longitude']) ? (float)$data['longitude'] : null;

        // 1. Criar alerta associado
        $sqlAlerta = "INSERT INTO alertas (usuario_id, tipo, bpm_momento, descricao) 
                      VALUES (:uid, :tipo, :bpm, :descricao)";
        $stmtAlerta = $this->db->prepare($sqlAlerta);
        $stmtAlerta->execute([
            'uid' => $userId,
            'tipo' => $tipo,
            'bpm' => $bpm,
            'descricao' => $descricao
        ]);

        $alertaId = $this->db->lastInsertId();

        // 2. Criar registro de emergência
        $sqlEmergencia = "INSERT INTO emergencia (usuario_id, alerta_id, latitude, longitude, status) 
                          VALUES (:uid, :alerta_id, :lat, :lng, 'PENDENTE')";
        $stmtEmerg = $this->db->prepare($sqlEmergencia);
        $stmtEmerg->execute([
            'uid' => $userId,
            'alerta_id' => $alertaId,
            'lat' => $latitude,
            'lng' => $longitude
        ]);

        $emergenciaId = $this->db->lastInsertId();

        return ["status" => 201, "data" => [
            "message" => "Emergência registrada com sucesso",
            "id" => $emergenciaId,
            "alertaId" => $alertaId
        ]];
    }

    public function getHistoricoUsuario($patientId) {
        $sql = "SELECT e.*, a.tipo, a.bpm_momento, a.descricao 
                FROM emergencia e 
                LEFT JOIN alertas a ON e.alerta_id = a.id 
                WHERE e.usuario_id = :uid 
                ORDER BY e.data_hora DESC";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['uid' => $patientId]);
        $rows = $stmt->fetchAll();

        // Mapear compatibilidade camelCase/snake_case
        $mapped = array_map(function($row) {
            $row['dataHora'] = $row['data_hora'];
            $row['alertaId'] = $row['alerta_id'];
            $row['usuarioId'] = $row['usuario_id'];
            $row['batMomento'] = $row['bpm_momento'];
            // Se não houver satMomento na tabela alertas, inferimos ou deixamos null
            $row['satMomento'] = null; 
            return $row;
        }, $rows);

        return ["status" => 200, "data" => $mapped];
>>>>>>> c3ddca26d8b70f1dc0598fe5875b7f961c21046f
    }
}
