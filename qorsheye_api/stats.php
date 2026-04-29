<?php
require_once 'cors.php';
require_once 'db.php';

$action = $_GET['action'] ?? '';

if ($action == 'get_stats') {
    $stats = [
        "total" => 0,
        "completed" => 0,
        "pending" => 0,
        "in_progress" => 0,
        "overdue" => 0
    ];

    // Total tasks
    $res = $conn->query("SELECT COUNT(*) as count FROM tasks");
    if ($row = $res->fetch_assoc()) $stats['total'] = (int)$row['count'];

    // Group by status
    $res = $conn->query("SELECT status, COUNT(*) as count FROM tasks GROUP BY status");
    while ($row = $res->fetch_assoc()) {
        $status = strtolower(str_replace(' ', '_', $row['status']));
        if (array_key_exists($status, $stats)) {
            $stats[$status] = (int)$row['count'];
        }
    }

    echo json_encode(["status" => "success", "data" => $stats]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid action"]);
}

$conn->close();
?>
