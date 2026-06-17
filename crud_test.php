<?php
// crud_test.php
ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/api/src/Database.php';
require_once __DIR__ . '/api/src/JWTHelper.php';
require_once __DIR__ . '/api/src/Controllers/UsuarioController.php';

use App\Controllers\UsuarioController;

echo "--- KOAVY LOGIC VALIDATION ---\n";

$uc = new UsuarioController();

echo "1. Attempting Login (CRUD: READ)...\n";
$loginResult = $uc->login([
    'email' => 'paciente@koavy.com',
    'senha' => 'paciente123'
]);

if ($loginResult['status'] === 200) {
    echo "SUCCESS: User authenticated.\n";
    echo "Token: " . substr($loginResult['data']['token'], 0, 20) . "...\n";
} else {
    echo "ERROR: Login failed: " . json_encode($loginResult['data']) . "\n";
}

echo "2. Attempting registration of new user (CRUD: CREATE)...\n";
$newEmail = "test_".time()."@koavy.com";
$regResult = $uc->cadastrar([
    'nome' => 'Usuário de Teste',
    'email' => $newEmail,
    'senha' => 'senha12345'
]);

if ($regResult['status'] === 201) {
    echo "SUCCESS: New user created with ID: " . $regResult['data']['id'] . "\n";
} else {
    echo "ERROR: Registration failed: " . json_encode($regResult['data']) . "\n";
}

echo "3. Updating profile (CRUD: UPDATE)...\n";
if (isset($regResult['data']['id'])) {
    $upResult = $uc->atualizar($regResult['data']['id'], [
        'nome' => 'Usuário Atualizado',
        'peso' => 75.5
    ]);
    if ($upResult['status'] === 200) {
        echo "SUCCESS: Profile updated. New name: " . $upResult['data']['nome'] . "\n";
    } else {
        echo "ERROR: Update failed: " . json_encode($upResult['data']) . "\n";
    }
}

echo "--- VALIDATION COMPLETE ---\n";
