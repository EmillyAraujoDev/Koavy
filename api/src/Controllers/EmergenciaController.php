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
        $bpm = $data['batMomento'] ?? $data['bpm_momento'] ?? null;
        $tipo = htmlspecialchars(strip_tags($data['tipo'] ?? 'CRITICO'));
        $descricao = htmlspecialchars(strip_tags($data['descricao'] ?? "Alerta de emergência cardíaca"));
        $latitude = isset($data['latitude']) ? (float)$data['latitude'] : null;
        $longitude = isset($data['longitude']) ? (float)$data['longitude'] : null;

        try {
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
        } catch (\PDOException $e) {
            error_log("Erro ao registrar emergência: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro interno ao registrar emergência"]];
        }
    }

    public function getHistoricoUsuario($patientId) {
        $sql = "SELECT e.*, a.tipo, a.bpm_momento, a.descricao 
                FROM emergencia e 
                LEFT JOIN alertas a ON e.alerta_id = a.id 
                WHERE e.usuario_id = :uid 
                ORDER BY e.data_hora DESC";
        
        try {
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['uid' => $patientId]);
            $rows = $stmt->fetchAll();

            // Mapear compatibilidade camelCase/snake_case
            $mapped = array_map(function($row) {
                $row['dataHora'] = $row['data_hora'];
                $row['alertaId'] = $row['alerta_id'];
                $row['usuarioId'] = $row['usuario_id'];
                $row['batMomento'] = $row['bpm_momento'];
                $row['satMomento'] = null; 
                return $row;
            }, $rows);

            return ["status" => 200, "data" => $mapped];
        } catch (\PDOException $e) {
            error_log("Erro ao buscar histórico: " . $e->getMessage());
            return ["status" => 500, "data" => ["message" => "Erro ao buscar histórico"]];
        }
    }

    public function getHistorico($userId) {
        return $this->getHistoricoUsuario($userId);
    }
}
