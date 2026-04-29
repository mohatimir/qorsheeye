<?php
/**
 * Category Controller
 * CRUD for categories — scoped per authenticated user.
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/../helpers/auth.php';
require_once __DIR__ . '/../models/CategoryModel.php';

class CategoryController {

    public static function getCategories(): void {
        $userId     = requireAuth();
        $categories = CategoryModel::getAllForUser($userId);
        success($categories, 'Categories retrieved.');
    }

    public static function addCategory(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['name', 'color']);
        if ($missing) error('name and color are required.', 422);

        $catId    = CategoryModel::create($userId, $data);
        $category = CategoryModel::findByIdAndUser($catId, $userId);
        success($category, 'Category created.', 201);
    }

    public static function updateCategory(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $missing = validateRequired($data, ['id', 'name', 'color']);
        if ($missing) error('id, name, and color are required.', 422);

        $id = (int) $data['id'];
        if (!CategoryModel::findByIdAndUser($id, $userId)) {
            error('Category not found or access denied.', 404);
        }

        CategoryModel::update($id, $userId, $data);
        $category = CategoryModel::findByIdAndUser($id, $userId);
        success($category, 'Category updated.');
    }

    public static function deleteCategory(): void {
        $userId  = requireAuth();
        $data    = getBody();
        $id      = (int) ($data['id'] ?? 0);
        if (!$id) error('Category ID is required.', 422);

        if (!CategoryModel::findByIdAndUser($id, $userId)) {
            error('Category not found or access denied.', 404);
        }

        CategoryModel::delete($id, $userId);
        success(null, 'Category deleted.');
    }
}

// ================================================================
// Route dispatcher
// ================================================================
$action = $_GET['action'] ?? '';
$method = $_SERVER['REQUEST_METHOD'];

switch (true) {
    case ($action === 'get_categories' && $method === 'GET'):    CategoryController::getCategories(); break;
    case ($action === 'add_category'   && $method === 'POST'):   CategoryController::addCategory(); break;
    case ($action === 'update_category'&& $method === 'PUT'):    CategoryController::updateCategory(); break;
    case ($action === 'delete_category'&& $method === 'DELETE'): CategoryController::deleteCategory(); break;
    default: error("Unknown action: $action", 404);
}
