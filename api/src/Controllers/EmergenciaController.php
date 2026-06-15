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
    }
}
