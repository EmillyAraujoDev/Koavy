<?php
// api/src/JWTHelper.php

namespace App;

class JWTHelper {
    private static function getSecret() {
        $envSecret = getenv('KOAVY_JWT_SECRET');
        if ($envSecret) {
            return $envSecret;
        }

        $config = require __DIR__ . '/../config/database.php';
        return $config['jwt_secret'] ?? 'FALLBACK_SECRET_DO_NOT_USE_IN_PROD';
    }

    public static function generate($payload) {
        $secret = self::getSecret();
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode(array_merge($payload, ['iat' => time(), 'exp' => time() + (3600 * 24)]));

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, $secret, true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function validate($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return false;

        list($header, $payload, $signature) = $parts;

        $secret = self::getSecret();
        $validSignature = hash_hmac('sha256', $header . "." . $payload, $secret, true);
        $validBase64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($validSignature));

        if ($signature !== $validBase64UrlSignature) return false;

        $payloadData = json_decode(base64_decode($payload), true);
        if ($payloadData['exp'] < time()) return false;

        return $payloadData;
    }
}
