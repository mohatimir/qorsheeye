<?php
require_once 'db.php';

echo "Checking database schema...<br>";

// Add icon_code to categories if it doesn't exist
$check_sql = "SHOW COLUMNS FROM categories LIKE 'icon_code'";
$result = $conn->query($check_sql);

if ($result->num_rows == 0) {
    echo "Adding 'icon_code' column to 'categories' table...<br>";
    $alter_sql = "ALTER TABLE categories ADD COLUMN icon_code INT(11) DEFAULT 57672 AFTER color";
    if ($conn->query($alter_sql)) {
        echo "'icon_code' column added successfully.<br>";
    } else {
        echo "Error adding column: " . $conn->error . "<br>";
    }
} else {
    echo "'icon_code' column already exists in 'categories'.<br>";
}

// Add repeat to tasks if it doesn't exist
$check_tasks_sql = "SHOW COLUMNS FROM tasks LIKE 'repeat'";
$result_tasks = $conn->query($check_tasks_sql);

if ($result_tasks->num_rows == 0) {
    echo "Adding 'repeat' column to 'tasks' table...<br>";
    $alter_tasks_sql = "ALTER TABLE tasks ADD COLUMN `repeat` VARCHAR(50) DEFAULT 'None' AFTER category_id";
    if ($conn->query($alter_tasks_sql)) {
        echo "'repeat' column added successfully.<br>";
    } else {
        echo "Error adding column to tasks: " . $conn->error . "<br>";
    }
} else {
    echo "'repeat' column already exists in 'tasks'.<br>";
}

echo "Database fix complete.";
$conn->close();
?>
