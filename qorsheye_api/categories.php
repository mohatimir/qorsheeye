<?php
require_once 'cors.php';
require_once 'db.php';

$action = $_GET['action'] ?? '';

if ($action == 'get_categories') {
    $result = $conn->query("SELECT * FROM categories ORDER BY name ASC");
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
    echo json_encode(["status" => "success", "data" => $categories]);
} 
elseif ($action == 'add_category') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['name']) || !isset($data['color'])) {
        echo json_encode(["status" => "error", "message" => "Name and color required"]);
        exit;
    }
    $icon_code = $data['icon_code'] ?? 57672;
    $stmt = $conn->prepare("INSERT INTO categories (name, color, icon_code) VALUES (?, ?, ?)");
    $stmt->bind_param("ssi", $data['name'], $data['color'], $icon_code);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Category added", "id" => $conn->insert_id]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
elseif ($action == 'update_category') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['id']) || !isset($data['name']) || !isset($data['color'])) {
        echo json_encode(["status" => "error", "message" => "ID, name, and color required"]);
        exit;
    }
    $icon_code = $data['icon_code'] ?? 57672;
    $stmt = $conn->prepare("UPDATE categories SET name=?, color=?, icon_code=? WHERE id=?");
    $stmt->bind_param("ssii", $data['name'], $data['color'], $icon_code, $data['id']);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Category updated"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
elseif ($action == 'delete_category') {
    $data = json_decode(file_get_contents("php://input"), true);
    if (!isset($data['id'])) {
        echo json_encode(["status" => "error", "message" => "ID is required"]);
        exit;
    }
    $stmt = $conn->prepare("DELETE FROM categories WHERE id=?");
    $stmt->bind_param("i", $data['id']);
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Category deleted"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid action"]);
}

$conn->close();
