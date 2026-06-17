<?php
// api/src/Controllers/BatimentoController.php

namespace App\Controllers;

use App\Database;
use PDO;

class BatimentoController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    private function formatBatimento($row) {
        if (!$row) return null;
        $row['frequenciaCard'] = (float)$row['bpm'];
        $row['dataHora'] = $row['timestamp'];
        $row['bpm'] = (float)$row['bpm'];
        $row['saturacao'] = isset($row['saturacao']) ? (float)$row['saturacao'] : null;
        $row['pressaoSistolica'] = isset($row['pressao_sistolica']) ? (int)$row['pressao_sistolica'] : null;
        $row['pressaoDiastolica'] = isset($row['pressao_diastolica']) ? (int)$row['pressao_diastolica'] : null;
        $row['dispositivoId'] = isset($row['dispositivo_id']) ? (int)$row['dispositivo_id'] : null;
        $row['usuarioId'] = (int)$row['usuario_id'];
        return $row;
    }

    public function registrar($data, $userId) {
        if (!isset($data['bpm'])) {
            return ["status" => 400, "data" => ["message" => "BPM é obrigatório"]];
        }

        $bpm = (float)$data['bpm'];
        $saturacao = $data['saturacao'] ?? null;
        $dispositivoId = $data['dispositivo_id'] ?? null;

        // 1. Buscar configurações do usuário
        $stmtConfig = $this->db->prepare("SELECT * FROM configuracoes_cardiacas WHERE usuario_id = :uid");
        $stmtConfig->execute(['uid' => $userId]);
        $config = $stmtConfig->fetch();

        // Valores padrão se não houver config
        $min = $config['bpm_minimo'] ?? 60;
        $max = $config['bpm_maximo'] ?? 100;
        $criticoBaixo = $config['bpm_critico_baixo'] ?? 40;
        $criticoAlto = $config['bpm_critico_alto'] ?? 140;

        // 2. Classificação Inteligente
        $classificacao = 'NORMAL';
        if ($bpm <= $criticoBaixo || $bpm >= $criticoAlto) {
            $classificacao = 'EMERGENCIA';
        } elseif ($bpm < $min || $bpm > $max) {
            $diff = ($bpm < $min) ? ($min - $bpm) : ($bpm - $max);
            if ($diff > 20) $classificacao = 'ALTO_RISCO';
            elseif ($diff > 10) $classificacao = 'MODERADO';
            else $classificacao = 'ATENCAO';
        }

        // 3. Salvar batimento
        $sql = "INSERT INTO batimentos (usuario_id, dispositivo_id, bpm, saturacao, classificacao) 
                VALUES (:uid, :did, :bpm, :sat, :class)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'uid' => $userId,
            'did' => $dispositivoId,
            'bpm' => $bpm,
            'sat' => $saturacao,
            'class' => $classificacao
        ]);

        $batimentoId = $this->db->lastInsertId();

        // 4. Tratar Alertas e Emergências
        if ($classificacao !== 'NORMAL') {
            $this->criarAlerta($userId, $bpm, $classificacao);
            
            if ($classificacao === 'EMERGENCIA') {
                $this->registrarEmergencia($userId, $bpm);
            }
        }

        return ["status" => 201, "data" => [
            "message" => "Leitura registrada",
            "id" => $batimentoId,
            "classificacao" => $classificacao,
            "frequenciaCard" => $bpm,
            "saturacao" => $saturacao
        ]];
    }

    private function criarAlerta($userId, $bpm, $class) {
        $tipo = ($bpm < 60) ? 'BRADICARDIA' : 'TAQUICARDIA';
        $stmt = $this->db->prepare("INSERT INTO alertas (usuario_id, tipo, bpm_momento, descricao) VALUES (:uid, :tipo, :bpm, :desc)");
        $stmt->execute([
            'uid' => $userId,
            'tipo' => $tipo,
            'bpm' => $bpm,
            'desc' => "Detectado estado de $class ($bpm BPM)"
        ]);
    }

    private function registrarEmergencia($userId, $bpm) {
        $alertaId = $this->db->lastInsertId();
        
        $stmt = $this->db->prepare("INSERT INTO emergencia (usuario_id, alerta_id, status) VALUES (:uid, :aid, 'PENDENTE')");
        $stmt->execute([
            'uid' => $userId,
            'aid' => $alertaId
        ]);
    }

    public function getHistorico($userId, $limit = 50) {
        $stmt = $this->db->prepare("SELECT id, usuario_id, dispositivo_id, bpm as frequenciaCard, saturacao, classificacao, timestamp as dataHora 
                                   FROM batimentos WHERE usuario_id = :uid ORDER BY timestamp DESC LIMIT :limit");
        $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll();
        return ["status" => 200, "data" => array_map([$this, 'formatBatimento'], $rows)];
    }

    public function getBpmRealtime($userId) {
        $stmt = $this->db->prepare("SELECT bpm, saturacao, timestamp FROM batimentos WHERE usuario_id = :uid ORDER BY timestamp DESC LIMIT 1");
        $stmt->execute(['uid' => $userId]);
        $row = $stmt->fetch();
        
        if ($row) {
            return ["status" => 200, "data" => [
                "bpm" => (float)$row['bpm'],
                "timestamp" => $row['timestamp'],
                "saturacao" => (float)$row['saturacao']
            ]];
        }
        
        // Simulação caso não haja dados
        return ["status" => 200, "data" => [
            "bpm" => 72,
            "timestamp" => date('Y-m-d H:i:s'),
            "saturacao" => 98
        ]];
    }
}
