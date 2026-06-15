<?php
// api/config/database.php

/**
 * Configuração do Banco de Dados Koavy
 * 
 * ATENÇÃO: Nunca compartilhe sua senha publicamente.
 * Em produção, recomenda-se o uso de variáveis de ambiente.
 */

return [
    'host'    => '143.106.241.4', // IP do servidor remoto
    'dbname'  => 'cl204068',      // Nome do banco de dados
    'user'    => 'cl204068',      // Usuário do banco
    'pass'    => 'cl*204068', // <- INSIRA SUA SENHA AQUI
    'charset' => 'utf8mb4',
    'jwt_secret' => 'algoaleatorioelongo' // Mude para algo aleatório e longo
];
