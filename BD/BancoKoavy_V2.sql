-- KOAVY DATABASE - ESTRUTURA PROFISSIONAL COMPLETA

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS tokens;
DROP TABLE IF EXISTS sessoes;
DROP TABLE IF EXISTS auditoria;
DROP TABLE IF EXISTS logs;
DROP TABLE IF EXISTS notificacoes;
DROP TABLE IF EXISTS alertas;
DROP TABLE IF EXISTS configuracoes_cardiacas;
DROP TABLE IF EXISTS batimentos;
DROP TABLE IF EXISTS dispositivos;
DROP TABLE IF EXISTS tutor_paciente;
DROP TABLE IF EXISTS usuarios;
DROP TABLE IF EXISTS perfis;
DROP TABLE IF EXISTS emergencia;
DROP TABLE IF EXISTS relatorios;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Perfis de Acesso
CREATE TABLE perfis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(20) NOT NULL UNIQUE -- 'PACIENTE', 'TUTOR', 'ADMIN'
);

-- 2. Usuários
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    perfil_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL, -- Hash Argon2id ou Bcrypt
    data_nascimento DATE,
    sexo ENUM('M','F','O'),
    telefone VARCHAR(20),
    tipo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    peso DECIMAL(5,2),
    altura DECIMAL(4,2),
    marcapasso BOOLEAN DEFAULT FALSE,
    obs_med TEXT,
    cep VARCHAR(10), 
    avatar_url VARCHAR(255),
    fcm_token VARCHAR(255), -- Para Push Notifications
    cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_usuario_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id)
);

-- 3. Vínculo Tutor-Paciente
CREATE TABLE tutor_paciente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    tutor_id INT NOT NULL,
    principal BOOLEAN DEFAULT FALSE,
    data_vinculo DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vinculo_paciente FOREIGN KEY (paciente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_vinculo_tutor FOREIGN KEY (tutor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE(paciente_id, tutor_id)
);

-- 4. Dispositivos (Pulseiras/Sensores)
CREATE TABLE dispositivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    codigo_identificador VARCHAR(50) UNIQUE NOT NULL, -- MAC Address ou UUID
    nome VARCHAR(50), -- Ex: 'Pulseira do João'
    modelo VARCHAR(50),
    versão_firmware VARCHAR(20),
    status ENUM('ATIVO', 'INATIVO', 'MANUTENCAO') DEFAULT 'ATIVO',
    ultima_comunicacao DATETIME,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dispositivo_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- 5. Leituras Cardíacas (Batimentos)
CREATE TABLE batimentos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    dispositivo_id INT,
    bpm DECIMAL(5,2) NOT NULL,
    saturacao DECIMAL(5,2),
    pressao_sistolica SMALLINT,
    pressao_diastolica SMALLINT,
    temperatura DECIMAL(4,1),
    classificacao ENUM('NORMAL', 'ATENCAO', 'MODERADO', 'ALTO_RISCO', 'EMERGENCIA') DEFAULT 'NORMAL',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX (usuario_id, timestamp),
    CONSTRAINT fk_batimento_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_batimento_dispositivo FOREIGN KEY (dispositivo_id) REFERENCES dispositivos(id) ON DELETE SET NULL
);

-- 6. Configurações Cardíacas Personalizadas
CREATE TABLE configuracoes_cardiacas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNIQUE NOT NULL,
    bpm_minimo TINYINT DEFAULT 60,
    bpm_maximo TINYINT DEFAULT 100,
    bpm_critico_baixo TINYINT DEFAULT 40,
    bpm_critico_alto TINYINT DEFAULT 140,
    notificar_tutor BOOLEAN DEFAULT TRUE,
    intervalo_leitura INT DEFAULT 5, -- segundos
    CONSTRAINT fk_config_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 7. Alertas e Ocorrências
CREATE TABLE alertas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo ENUM('TAQUICARDIA', 'BRADICARDIA', 'QUEDA_SATURACAO', 'DESCONECTADO') NOT NULL,
    bpm_momento DECIMAL(5,2),
    descricao TEXT,
    visto BOOLEAN DEFAULT FALSE,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alerta_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 8. Emergências (Atendimentos Críticos)
CREATE TABLE emergencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    alerta_id INT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    status ENUM('PENDENTE', 'EM_CURSO', 'RESOLVIDO', 'FALSO_ALERTA') DEFAULT 'PENDENTE',
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_resolucao DATETIME,
    CONSTRAINT fk_emergencia_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_emergencia_alerta FOREIGN KEY (alerta_id) REFERENCES alertas(id) ON DELETE SET NULL
);

-- 9. Notificações Enviadas
CREATE TABLE notificacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL, -- Destinatário
    titulo VARCHAR(100),
    mensagem TEXT,
    lida BOOLEAN DEFAULT FALSE,
    tipo VARCHAR(30), -- 'SISTEMA', 'ALERTA', 'MENSAGEM'
    data_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notificacao_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 10. Relatórios Consolidados
CREATE TABLE relatorios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo ENUM('DIARIO', 'SEMANAL', 'MENSAL', 'ANUAL'),
    data_inicio DATE,
    data_fim DATE,
    media_bpm DECIMAL(5,2),
    bpm_max DECIMAL(5,2),
    bpm_min DECIMAL(5,2),
    total_alertas INT,
    obs_ia TEXT, -- Campo para IA Preditiva deixar observações
    file_path VARCHAR(255), -- Link para PDF gerado
    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rel_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 11. Logs e Auditoria
CREATE TABLE auditoria (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    acao VARCHAR(100), -- Ex: 'LOGIN', 'UPDATE_CONFIG', 'DELETE_USER'
    tabela_afetada VARCHAR(50),
    registro_id INT,
    dados_anteriores JSON,
    dados_novos JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- 12. Gestão de Sessões e Tokens JWT
CREATE TABLE tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    refresh_token VARCHAR(255) UNIQUE NOT NULL,
    expira_em DATETIME NOT NULL,
    revogado BOOLEAN DEFAULT FALSE,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_token_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- INSERÇÃO DE DADOS INICIAIS
INSERT INTO perfis (id, nome) VALUES (1, 'PACIENTE'), (2, 'TUTOR'), (3, 'ADMIN');

-- Senha padrão 'admin123' em hash fictício (será corrigido na implementação da API)
INSERT INTO usuarios (perfil_id, nome, email, senha, ativo) 
VALUES (3, 'Administrador Koavy', 'admin@koavy.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);
