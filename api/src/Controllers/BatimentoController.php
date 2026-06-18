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
        $bpm = $row['bpm'] ?? $row['frequenciaCard'] ?? 0;
        $row['frequenciaCard'] = (float)$bpm;
        $row['dataHora'] = $row['timestamp'];
        $row['bpm'] = (float)$bpm;
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
        $saturacao = isset($data['saturacao']) ? (float)$data['saturacao'] : null;
        $dispositivoId = $data['dispositivo_id'] ?? $data['dispositivoId'] ?? null;
        $origem = htmlspecialchars(strip_tags($data['origem'] ?? 'MANUAL'));

        if ($bpm < 20 || $bpm > 240) {
            return ["status" => 400, "data" => ["message" => "BPM fora da faixa esperada para leitura cardÃ­aca"]];
        }

        if ($saturacao !== null && ($saturacao < 50 || $saturacao > 100)) {
            return ["status" => 400, "data" => ["message" => "SaturaÃ§Ã£o fora da faixa esperada"]];
        }

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
        $sql = "INSERT INTO batimentos (usuario_id, dispositivo_id, bpm, saturacao, classificacao, origem) 
                VALUES (:uid, :did, :bpm, :sat, :class, :origem)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            'uid' => $userId,
            'did' => $dispositivoId,
            'bpm' => $bpm,
            'sat' => $saturacao,
            'class' => $classificacao,
            'origem' => $origem
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
            "saturacao" => $saturacao,
            "origem" => $origem
        ]];
    }

    private function criarAlerta($userId, $bpm, $class) {
        $tipo = ($class === 'FALHA_SENSOR') ? 'DESCONECTADO' : (($bpm < 60) ? 'BRADICARDIA' : 'TAQUICARDIA');
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
        $stmt = $this->db->prepare("SELECT id, usuario_id, dispositivo_id, bpm, saturacao, classificacao, timestamp
                                   FROM batimentos WHERE usuario_id = :uid ORDER BY timestamp DESC LIMIT :limit");
        $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll();
        return ["status" => 200, "data" => array_map([$this, 'formatBatimento'], $rows)];
    }

    public function simular($tipo, $userId) {
        $cenarios = [
            'normal' => ['bpm' => 74, 'saturacao' => 98],
            'atencao' => ['bpm' => 108, 'saturacao' => 96],
            'taquicardia' => ['bpm' => 128, 'saturacao' => 94],
            'emergencia' => ['bpm' => 152, 'saturacao' => 90],
            'falha-sensor' => ['bpm' => 0, 'saturacao' => null],
            'falha_sensor' => ['bpm' => 0, 'saturacao' => null],
        ];

        $tipo = strtolower($tipo ?: 'normal');
        if (!isset($cenarios[$tipo])) {
            return ["status" => 400, "data" => ["message" => "Tipo de simulaÃ§Ã£o invÃ¡lido"]];
        }

        if ($tipo === 'falha-sensor' || $tipo === 'falha_sensor') {
            $this->criarAlerta($userId, 0, 'FALHA_SENSOR');
            return ["status" => 201, "data" => [
                "message" => "Falha de sensor simulada e alerta registrado",
                "classificacao" => "DESCONECTADO",
                "frequenciaCard" => null,
                "saturacao" => null,
                "origem" => "SIMULACAO"
            ]];
        }

        return $this->registrar([
            'bpm' => $cenarios[$tipo]['bpm'],
            'saturacao' => $cenarios[$tipo]['saturacao'],
            'origem' => 'SIMULACAO'
        ], $userId);
    }

    public function getResumo($userId) {
        $config = require __DIR__ . '/../../config/database.php';
        $isSqlite = isset($config['driver']) && $config['driver'] === 'sqlite';
        $periods = [
            'diaria' => 1,
            'semanal' => 7,
            'mensal' => 30
        ];

        $stats = [];
        foreach ($periods as $label => $days) {
            if ($isSqlite) {
                $sql = "SELECT AVG(bpm) media, MIN(bpm) minimo, MAX(bpm) maximo, COUNT(*) total
                        FROM batimentos
                        WHERE usuario_id = :uid AND timestamp >= datetime('now', '-' || :dias || ' day') AND bpm > 0";
            } else {
                $sql = "SELECT AVG(bpm) media, MIN(bpm) minimo, MAX(bpm) maximo, COUNT(*) total
                        FROM batimentos
                        WHERE usuario_id = :uid AND timestamp >= DATE_SUB(NOW(), INTERVAL :dias DAY) AND bpm > 0";
            }
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
            $stmt->bindValue(':dias', $days, PDO::PARAM_INT);
            $stmt->execute();
            $row = $stmt->fetch();
            $stats[$label] = [
                'media' => $row['media'] !== null ? round((float)$row['media'], 1) : null,
                'minimo' => $row['minimo'] !== null ? (float)$row['minimo'] : null,
                'maximo' => $row['maximo'] !== null ? (float)$row['maximo'] : null,
                'total' => (int)($row['total'] ?? 0)
            ];
        }

        $stmtLast = $this->db->prepare("SELECT * FROM batimentos WHERE usuario_id = :uid ORDER BY timestamp DESC LIMIT 1");
        $stmtLast->execute(['uid' => $userId]);
        $last = $stmtLast->fetch();

        $stmtAlerts = $this->db->prepare("SELECT * FROM alertas WHERE usuario_id = :uid ORDER BY data_hora DESC LIMIT 5");
        $stmtAlerts->execute(['uid' => $userId]);

        $insight = "Sem leituras suficientes para gerar tendÃªncia.";
        if (($stats['semanal']['total'] ?? 0) >= 7) {
            $avg = $stats['semanal']['media'];
            if ($avg >= 60 && $avg <= 100) {
                $insight = "MÃ©dia semanal dentro da faixa esperada.";
            } elseif ($avg > 100) {
                $insight = "MÃ©dia semanal elevada. Acompanhe sintomas e procure orientaÃ§Ã£o profissional se persistir.";
            } else {
                $insight = "MÃ©dia semanal abaixo da faixa comum. Verifique repouso, medicaÃ§Ã£o e orientaÃ§Ã£o mÃ©dica.";
            }
        }

        return ["status" => 200, "data" => [
            'atual' => $this->formatBatimento($last),
            'medias' => $stats,
            'alertasRecentes' => $stmtAlerts->fetchAll(),
            'statusPulseira' => $last ? 'CONECTADA' : 'SEM_LEITURAS',
            'statusConexao' => 'ONLINE',
            'insight' => $insight
        ]];
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
