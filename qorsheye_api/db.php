<?php
$host = "localhost";
$user = "u949732407_zakarie";
$password = "Sakariye_123";
$dbname = "u949732407_qorsheeye";

$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

$conn->set_charset("utf8mb4");
header('Content-Type: application/json');
