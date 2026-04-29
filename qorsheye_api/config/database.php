<?php
/**
 * Database Configuration
 * Qorsheye API v2.0
 */

define('DB_HOST',    'localhost');
define('DB_USER',    'u949732407_zakarie');
define('DB_PASS',    'Sakariye_123');
define('DB_NAME',    'u949732407_qorsheeye');
define('DB_CHARSET', 'utf8mb4');

define('TOKEN_EXPIRY_HOURS', 72);   // Auth token lifetime
define('APP_ENV', 'development');    // For debugging Hostinger error

/**
 * Returns a singleton PDO connection.
 */
function getDB(): PDO {
    static $pdo = null;

    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;dbname=%s;charset=%s',
            DB_HOST, DB_NAME, DB_CHARSET
        );
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode([
                'status'  => 'error',
                'message' => 'Database connection failed.',
                'detail'  => APP_ENV === 'development' ? $e->getMessage() : null,
            ]);
            exit;
        }
    }

    return $pdo;
}
