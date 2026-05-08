-- 1. Tabela de Perfis (Níveis de Acesso)
CREATE TABLE perfis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(20) NOT NULL -- Ex: 'PACIENTE', 'TUTOR', 'ADMIN'
);

-- 2. Tabela Unificada de Usuários
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    perfil_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Necessário para Login na API
    senha VARCHAR(255) NOT NULL,        -- Necessário para Login na API
    idade TINYINT,
    data_nascimento DATE,
    sexo ENUM('M','F','O'),
    telefone VARCHAR(20),
    tipo_sanguineo ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    peso DECIMAL(5,2),
    altura DECIMAL(4,2),
    marcapasso BOOLEAN DEFAULT FALSE,
    obs_med TEXT,
    cep VARCHAR(10), 
    cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_usuario_perfil FOREIGN KEY (perfil_id) REFERENCES perfis(id)
);

-- 3. Tabela de Vínculo (Quem cuida de quem)
CREATE TABLE tutor_paciente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    tutor_id INT NOT NULL,
    principal BOOLEAN DEFAULT FALSE,
    data_vinculo DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vinculo_paciente FOREIGN KEY (paciente_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_vinculo_tutor FOREIGN KEY (tutor_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 4. Tabela de Batimentos (Histórico)
CREATE TABLE batimentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    frequencia_card DECIMAL(5,2),
    saturacao DECIMAL(5,2),
    pressao_sistolica SMALLINT,
    pressao_diastolica SMALLINT,
    nivel_estresse TINYINT,
    movimento BOOLEAN,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX (usuario_id, data_hora),
    CONSTRAINT fk_batimento_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 5. Tabela de Emergência (Correção de tipagem de pressão)
CREATE TABLE emergencia (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    bat_momento DECIMAL(5,2),
    sat_momento DECIMAL(5,2),
    pre_sistolica_momento SMALLINT, -- Corrigido para SMALLINT
    pre_diastolica_momento SMALLINT, -- Adicionado para manter padrão
    tipo VARCHAR(50),
    descricao TEXT,
    local_referencia VARCHAR(150),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    notificacao_enviada TEXT,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_emergencia_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- 6. Tabela de Relatórios
CREATE TABLE relatorios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    data_ref DATE,
    media_bpm DECIMAL(5,2),
    bpm_max DECIMAL(5,2),
    bpm_min DECIMAL(5,2),
    media_saturacao DECIMAL(5,2),
    obs TEXT,
    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rel_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE (usuario_id, data_ref)
);

-- Inserção inicial de perfis para teste
INSERT INTO perfis (nome) VALUES ('PACIENTE'), ('TUTOR'), ('ADMIN');