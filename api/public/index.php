<?php
// api/public/index.php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

require_once __DIR__ . '/../src/Database.php';
require_once __DIR__ . '/../src/JWTHelper.php';
require_once __DIR__ . '/../src/Controllers/UsuarioController.php';
require_once __DIR__ . '/../src/Controllers/BatimentoController.php';

use App\Controllers\UsuarioController;
use App\Controllers\BatimentoController;
use App\JWTHelper;

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);

// Router simples
// /api/login -> [ "api", "login" ]
$resource = $uri[2] ?? null;
$action = $uri[3] ?? null;

$input = json_decode(file_get_contents("php://input"), true);

$usuarioController = new UsuarioController();
$batimentoController = new BatimentoController();

// Middleware de Autenticação para rotas protegidas
$auth = null;
if (!in_array($resource, ['login', 'cadastro'])) {
    $headers = getallheaders();
    $token = $headers['Authorization'] ?? $headers['authorization'] ?? null;
    if ($token) {
        $token = str_replace('Bearer ', '', $token);
        $auth = JWTHelper::validate($token);
    }

    if (!$auth && $resource !== 'public') {
        http_response_code(401);
        echo json_encode(["message" => "Não autorizado"]);
        exit;
    }
}

// Rotas
switch ($resource) {
    case 'login':
        $res = $usuarioController->login($input);
        http_response_code($res['status']);
        echo json_encode($res['data']);
        break;

    case 'cadastro':
        $res = $usuarioController->cadastrar($input);
        http_response_code($res['status']);
        echo json_encode($res['data']);
        break;

    case 'batimentos':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $res = $batimentoController->registrar($input, $auth['id']);
        } else {
            $res = $batimentoController->getHistorico($auth['id']);
        }
        http_response_code($res['status']);
        echo json_encode($res['data']);
        break;

    default:
        http_response_code(404);
        echo json_encode(["message" => "Endpoint não encontrado"]);
        break;
}
