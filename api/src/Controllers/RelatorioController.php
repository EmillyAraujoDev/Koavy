<?php
// api/src/Controllers/RelatorioController.php

namespace App\Controllers;

use App\Database;
use PDO;

class RelatorioController {
    private $db;

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function gerar($userId, $tipo = 'DIARIO') {
        // Garantir que a tabela relatorios existe no SQLite/MySQL
        try {
            $config = require __DIR__ . '/../../config/database.php';
            $isSqlite = isset($config['driver']) && $config['driver'] === 'sqlite';

            if ($isSqlite) {
                $this->db->exec("CREATE TABLE IF NOT EXISTS relatorios (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    usuario_id INTEGER NOT NULL,
                    tipo TEXT NOT NULL,
                    media_bpm REAL,
                    bpm_max REAL,
                    bpm_min REAL,
                    obs_ia TEXT,
                    data_geracao TEXT DEFAULT CURRENT_TIMESTAMP
                )");
            } else {
                $this->db->exec("CREATE TABLE IF NOT EXISTS relatorios (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    usuario_id INT NOT NULL,
                    tipo VARCHAR(20) NOT NULL,
                    media_bpm DECIMAL(5,2),
                    bpm_max DECIMAL(5,2),
                    bpm_min DECIMAL(5,2),
                    obs_ia TEXT,
                    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP
                )");
            }
        } catch (\Exception $e) {}

        // 1. Coletar dados baseados no tipo
        $dias = ($tipo === 'SEMANAL') ? 7 : (($tipo === 'MENSAL') ? 30 : 1);
        
        $config = require __DIR__ . '/../../config/database.php';
        $isSqlite = isset($config['driver']) && $config['driver'] === 'sqlite';

        if ($isSqlite) {
            $sql = "SELECT AVG(bpm) as media_bpm, MAX(bpm) as max_bpm, MIN(bpm) as min_bpm, 
                           AVG(saturacao) as media_sat, COUNT(*) as total_leituras
                    FROM batimentos 
                    WHERE usuario_id = :uid AND timestamp >= datetime('now', '-' || :dias || ' day')";
        } else {
            $sql = "SELECT AVG(bpm) as media_bpm, MAX(bpm) as max_bpm, MIN(bpm) as min_bpm, 
                           AVG(saturacao) as media_sat, COUNT(*) as total_leituras
                    FROM batimentos 
                    WHERE usuario_id = :uid AND timestamp >= DATE_SUB(NOW(), INTERVAL :dias DAY)";
        }
        
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':dias', $dias, PDO::PARAM_INT);
        $stmt->execute();
        $stats = $stmt->fetch();

        if (!$stats['total_leituras']) {
            return ["status" => 404, "data" => ["message" => "Sem dados para o período selecionado"]];
        }

        // 2. Calcular Score Cardíaco Simples (IA)
        $score = 100;
        if ($stats['media_bpm'] > 100 || $stats['media_bpm'] < 60) $score -= 20;
        if ($stats['max_bpm'] > 140) $score -= 15;
        if ($stats['media_sat'] < 95) $score -= 25;
        $score = max(0, $score);

        // 3. Gerar "Insights"
        $insight = "Seu padrão cardíaco está estável.";
        if ($score < 70) $insight = "Atenção: Foram detectadas variações fora do padrão ideal nesta semana.";
        if ($score < 50) $insight = "Risco: Procure um médico para avaliação detalhada dos alertas registrados.";

        // 4. Salvar na tabela de relatórios
        $sqlInsert = "INSERT INTO relatorios (usuario_id, tipo, media_bpm, bpm_max, bpm_min, obs_ia) 
                      VALUES (:uid, :tipo, :media, :max, :min, :obs)";
        $stmtInsert = $this->db->prepare($sqlInsert);
        $stmtInsert->execute([
            'uid' => $userId,
            'tipo' => $tipo,
            'media' => $stats['media_bpm'],
            'max' => $stats['max_bpm'],
            'min' => $stats['min_bpm'],
            'obs' => $insight
        ]);

        return ["status" => 200, "data" => [
            "periodo" => $tipo,
            "stats" => $stats,
            "score" => $score,
            "insight" => $insight,
            "data_geracao" => date('Y-m-d H:i:s')
        ]];
    }

    public function getLista($userId) {
        try {
            $config = require __DIR__ . '/../../config/database.php';
            $isSqlite = isset($config['driver']) && $config['driver'] === 'sqlite';

            if ($isSqlite) {
                $this->db->exec("CREATE TABLE IF NOT EXISTS relatorios (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    usuario_id INTEGER NOT NULL,
                    tipo TEXT NOT NULL,
                    media_bpm REAL,
                    bpm_max REAL,
                    bpm_min REAL,
                    obs_ia TEXT,
                    data_geracao TEXT DEFAULT CURRENT_TIMESTAMP
                )");
            } else {
                $this->db->exec("CREATE TABLE IF NOT EXISTS relatorios (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    usuario_id INT NOT NULL,
                    tipo VARCHAR(20) NOT NULL,
                    media_bpm DECIMAL(5,2),
                    bpm_max DECIMAL(5,2),
                    bpm_min DECIMAL(5,2),
                    obs_ia TEXT,
                    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP
                )");
            }
        } catch (\Exception $e) {}

        $stmt = $this->db->prepare("SELECT * FROM relatorios WHERE usuario_id = :uid ORDER BY data_geracao DESC");
        $stmt->execute(['uid' => $userId]);
        return ["status" => 200, "data" => $stmt->fetchAll()];
    }
}
