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

    public function registrar($data, $userId) {
        if (!isset($data['bpm'])) {
            return ["status" => 400, "data" => ["message" => "BPM é obrigatório"]];
        }

        $bpm = $data['bpm'];
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
            "classificacao" => $classificacao
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
        // Busca o último alerta criado acima
        $alertaId = $this->db->lastInsertId();
        
        $stmt = $this->db->prepare("INSERT INTO emergencia (usuario_id, alerta_id, status) VALUES (:uid, :aid, 'PENDENTE')");
        $stmt->execute([
            'uid' => $userId,
            'aid' => $alertaId
        ]);

        // TODO: Disparar Push Notification via FCM aqui
    }

    public function getHistorico($userId, $limit = 50) {
        $stmt = $this->db->prepare("SELECT id, usuario_id, dispositivo_id, bpm as frequenciaCard, saturacao, classificacao, timestamp as dataHora 
                                   FROM batimentos WHERE usuario_id = :uid ORDER BY timestamp DESC LIMIT :limit");
        $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();
        return ["status" => 200, "data" => $stmt->fetchAll()];
    }
}
