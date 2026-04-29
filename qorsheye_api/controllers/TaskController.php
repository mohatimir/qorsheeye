<?php
/**
 * Task Controller
 * CRUD + status change + search/filter/pagination.
 * Every endpoint is protected by requireAuth().
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../models/TaskModel.php';

class TaskController {

    // ----------------------------------------------------------------
    // GET /api/tasks.php?action=get_tasks  [+ filters]
    // ----------------------------------------------------------------
    public static function getTasks(): void {
        $userId  = requireAuth();
        $filters = [
            'status'      => $_GET['status']      ?? '',
            'priority'    => $_GET['priority']    ?? '',
            'category_id' => $_GET['category_id'] ?? '',
            'search'      => $_GET['search']      ?? '',
            'sort'        => $_GET['sort']        ?? 'due_date',
            'page'        => $_GET['page']        ?? 1,
            'per_page'    => $_GET['per_page']    ?? 20,
        ];
        $result = TaskModel::getAllForUser($userId, $filters);
        success($result, 'Tasks retrieved.');
    }

    // ----------------------------------------------------------------
    // GET /api/tasks.php?action=get_task&id=X
    // ----------------------------------------------------------------
    public static function getTask(): void {
        $userId = requireAuth();
        $id     = (int) ($_GET['id'] ?? 0);
        if (!$id) error('Task ID is required.', 422);

        $task = TaskModel::findByIdAndUser($id, $userId);
        if (!$task) error('Task not found.', 404);

        success($task, 'Task retrieved.');
    }

    // ----------------------------------------------------------------
    // POST /api/tasks.php?action=add_task
    // ----------------------------------------------------------------
    public static function addTask(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['title']);
        if ($missing) error('Title is required.', 422);

        // Validate enums
        self::validateEnums($data);

        $taskId = TaskModel::create($userId, $data);
        $task   = TaskModel::findByIdAndUser($taskId, $userId);
        success($task, 'Task created.', 201);
    }

    // ----------------------------------------------------------------
    // PUT /api/tasks.php?action=update_task
    // ----------------------------------------------------------------
    public static function updateTask(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['id', 'title']);
        if ($missing) error('id and title are required.', 422);

        $id = (int) $data['id'];
        if (!TaskModel::findByIdAndUser($id, $userId)) {
            error('Task not found or access denied.', 404);
        }

        self::validateEnums($data);
        TaskModel::update($id, $userId, $data);
        $task = TaskModel::findByIdAndUser($id, $userId);
        success($task, 'Task updated.');
    }

    // ----------------------------------------------------------------
    // PATCH /api/tasks.php?action=change_status
    // ----------------------------------------------------------------
    public static function changeStatus(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['id', 'status']);
        if ($missing) error('id and status are required.', 422);

        $allowed = ['Pending', 'In Progress', 'Completed', 'Overdue'];
        if (!in_array($data['status'], $allowed, true)) {
            error('Invalid status. Allowed: ' . implode(', ', $allowed), 422);
        }

        $id = (int) $data['id'];
        if (!TaskModel::findByIdAndUser($id, $userId)) {
            error('Task not found or access denied.', 404);
        }

        TaskModel::updateStatus($id, $userId, $data['status']);
        success(null, 'Status updated.');
    }

    // ----------------------------------------------------------------
    // DELETE /api/tasks.php?action=delete_task
    // ----------------------------------------------------------------
    public static function deleteTask(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $id      = (int) ($data['id'] ?? 0);
        if (!$id) error('Task ID is required.', 422);

        if (!TaskModel::findByIdAndUser($id, $userId)) {
            error('Task not found or access denied.', 404);
        }

        TaskModel::delete($id, $userId);
        success(null, 'Task deleted.');
    }

    // ----------------------------------------------------------------
    // GET /api/tasks.php?action=stats
    // ----------------------------------------------------------------
    public static function stats(): void {
        $userId = requireAuth();
        $stats  = TaskModel::getStatsByUser($userId);
        success($stats, 'Stats retrieved.');
    }

    // ----------------------------------------------------------------
    // Private helpers
    // ----------------------------------------------------------------
    private static function validateEnums(array $data): void {
        $priorities = ['Low', 'Medium', 'High'];
        $statuses   = ['Pending', 'In Progress', 'Completed', 'Overdue'];
        $repeats    = ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

        if (!empty($data['priority']) && !in_array($data['priority'], $priorities, true)) {
            error('Invalid priority. Allowed: ' . implode(', ', $priorities), 422);
        }
        if (!empty($data['status']) && !in_array($data['status'], $statuses, true)) {
            error('Invalid status. Allowed: ' . implode(', ', $statuses), 422);
        }
        if (!empty($data['repeat']) && !in_array($data['repeat'], $repeats, true)) {
            error('Invalid repeat value. Allowed: ' . implode(', ', $repeats), 422);
        }
        if (!empty($data['due_date']) && !strtotime($data['due_date'])) {
            error('Invalid due_date format. Use ISO 8601.', 422);
        }
    }
}

// ================================================================
// Route dispatcher
// ================================================================
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

switch (true) {
    case ($action === 'get_tasks'     && $method === 'GET'):    TaskController::getTasks(); break;
    case ($action === 'get_task'      && $method === 'GET'):    TaskController::getTask(); break;
    case ($action === 'add_task'      && $method === 'POST'):   TaskController::addTask(); break;
    case ($action === 'update_task'   && $method === 'PUT'):    TaskController::updateTask(); break;
    case ($action === 'change_status' && $method === 'PATCH'):  TaskController::changeStatus(); break;
    case ($action === 'delete_task'   && $method === 'DELETE'): TaskController::deleteTask(); break;
    case ($action === 'stats'         && $method === 'GET'):    TaskController::stats(); break;
    default: error("Unknown action: $action", 404);
}
