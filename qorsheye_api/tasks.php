<?php
require_once 'cors.php';
require_once 'db.php';

$action = $_GET['action'] ?? '';

if ($action == 'get_tasks') {
    $sql = "SELECT tasks.*, categories.name as category_name, categories.color as category_color, categories.icon_code as category_icon_code 
            FROM tasks 
            LEFT JOIN categories ON tasks.category_id = categories.id 
            ORDER BY tasks.due_date ASC";
    $result = $conn->query($sql);
    $tasks = [];
    while ($row = $result->fetch_assoc()) {
        $tasks[] = $row;
    }
    echo json_encode(["status" => "success", "data" => $tasks]);
}
elseif ($action == 'task_details') {
    $id = $_GET['id'] ?? 0;
    $stmt = $conn->prepare("SELECT tasks.*, categories.name as category_name, categories.color as category_color 
                            FROM tasks 
                            LEFT JOIN categories ON tasks.category_id = categories.id 
                            WHERE tasks.id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($row = $result->fetch_assoc()) {
        echo json_encode(["status" => "success", "data" => $row]);
    } else {
        echo json_encode(["status" => "error", "message" => "Task not found"]);
    }
}
elseif ($action == 'add_task') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['title'])) {
        echo json_encode(["status" => "error", "message" => "Title is required"]);
        exit;
    }
    
    $title = $data['title'];
    $description = $data['description'] ?? '';
    $priority = $data['priority'] ?? 'Medium';
    $status = $data['status'] ?? 'Pending';
    $due_date = empty($data['due_date']) ? null : $data['due_date'];
    $category_id = empty($data['category_id']) ? null : $data['category_id'];
    $repeat = $data['repeat'] ?? 'None';

    $stmt = $conn->prepare("INSERT INTO tasks (title, description, priority, status, due_date, category_id, `repeat`) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("sssssis", $title, $description, $priority, $status, $due_date, $category_id, $repeat);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Task added", "id" => $conn->insert_id]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
elseif ($action == 'update_task') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['id']) || !isset($data['title'])) {
        echo json_encode(["status" => "error", "message" => "ID and Title are required"]);
        exit;
    }
    
    $id = $data['id'];
    $title = $data['title'];
    $description = $data['description'] ?? '';
    $priority = $data['priority'] ?? 'Medium';
    $due_date = empty($data['due_date']) ? null : $data['due_date'];
    $category_id = empty($data['category_id']) ? null : $data['category_id'];
    $repeat = $data['repeat'] ?? 'None';

    $stmt = $conn->prepare("UPDATE tasks SET title=?, description=?, priority=?, due_date=?, category_id=?, `repeat`=? WHERE id=?");
    $stmt->bind_param("ssssisi", $title, $description, $priority, $due_date, $category_id, $repeat, $id);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Task updated"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
elseif ($action == 'change_status') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['id']) || !isset($data['status'])) {
        echo json_encode(["status" => "error", "message" => "ID and status are required"]);
        exit;
    }
    $stmt = $conn->prepare("UPDATE tasks SET status=? WHERE id=?");
    $stmt->bind_param("si", $data['status'], $data['id']);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Status updated"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
elseif ($action == 'delete_task') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['id'])) {
        echo json_encode(["status" => "error", "message" => "ID is required"]);
        exit;
    }
    $stmt = $conn->prepare("DELETE FROM tasks WHERE id=?");
    $stmt->bind_param("i", $data['id']);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Task deleted"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid action"]);
}

$conn->close();
