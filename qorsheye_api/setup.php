<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE, PUT");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = "localhost";
$user = "root";
$password = ""; 

$conn = new mysqli($host, $user, $password);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "CREATE DATABASE IF NOT EXISTS qorsheye_db";
if ($conn->query($sql) === TRUE) {
    echo "<p>Database 'qorsheye_db' created or already exists.</p>";
} else {
    die("Error creating database: " . $conn->error);
}

$conn->select_db("qorsheye_db");

$sql_categories = "CREATE TABLE IF NOT EXISTS categories (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(50) NOT NULL,
    icon_code INT(11) DEFAULT 57672,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($conn->query($sql_categories) === TRUE) {
    echo "<p>Table 'categories' ready.</p>";
} else {
    echo "<p>Error creating categories: " . $conn->error . "</p>";
}

$sql_tasks = "CREATE TABLE IF NOT EXISTS tasks (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    status ENUM('Pending', 'In Progress', 'Completed', 'Overdue') DEFAULT 'Pending',
    due_date DATETIME,
    category_id INT(11),
    `repeat` VARCHAR(50) DEFAULT 'None',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
)";

if ($conn->query($sql_tasks) === TRUE) {
    echo "<p>Table 'tasks' ready.</p>";
} else {
    echo "<p>Error creating tasks: " . $conn->error . "</p>";
}

echo "<h3>Setup Completed! Database and Tables are ready.</h3>";
$conn->close();
?>
