<?php
require_once __DIR__ . '/../config/firebase.php';
require_once __DIR__ . '/../controllers/ArticleController.php';
require_once __DIR__ . '/../controllers/UserController.php';
require_once __DIR__ . '/../controllers/CommentController.php';
require_once __DIR__ . '/../controllers/BookmarkController.php';
require_once __DIR__ . '/../controllers/LikeController.php';

$method = $_SERVER['REQUEST_METHOD'];
$path = $_GET['path'] ?? '';
$id = $_GET['id'] ?? '';
$articleId = $_GET['articleId'] ?? '';
$userId = $_GET['userId'] ?? '';
$action = $_GET['action'] ?? '';

if ($path === 'articles') {
    $controller = new ArticleController();
    if ($method === 'GET') {
        $controller->get();
    } elseif ($method === 'POST') {
        $controller->store();
    } elseif ($method === 'PATCH' && $id) {
        if ($action === 'incrementViews') {
            $controller->incrementViews($id);
        } else {
            $controller->update($id);
        }
    } elseif ($method === 'DELETE' && $id) {
        $controller->delete($id);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not Allowed']);
    }
} elseif ($path === 'comments') {
    $controller = new CommentController();
    if ($method === 'GET' && $articleId) {
        $controller->get($articleId);
    } elseif ($method === 'POST' && $articleId) {
        $controller->store($articleId);
    } elseif ($method === 'DELETE' && $id && $articleId) {
        $controller->delete($id, $articleId);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not Allowed']);
    }
} elseif ($path === 'bookmarks') {
    $controller = new BookmarkController();
    // Ưu tiên kiểm tra trạng thái bookmark (action=check) trước
    if ($method === 'GET' && $action === 'check' && $userId && $articleId) {
        $controller->check($userId, $articleId);
    } elseif ($method === 'GET' && $userId) {
        $controller->get($userId);
    } elseif ($method === 'POST') {
        $controller->store();
    } elseif ($method === 'DELETE' && $id) {
        $controller->delete($id);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not Allowed']);
    }
} elseif ($path === 'likes') {
    $controller = new LikeController();
    // Ưu tiên kiểm tra trạng thái like (action=check) trước
    if ($method === 'GET' && $action === 'check' && $userId && $articleId) {
        $controller->check($userId, $articleId);
    } elseif ($method === 'GET' && $articleId) {
        $controller->get($articleId);
    } elseif ($method === 'POST' && $articleId) {
        $controller->store($articleId);
    } elseif ($method === 'DELETE' && $id && $articleId) {
        $controller->delete($id, $articleId);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not Allowed']);
    }
} elseif ($path === 'users') {
    $controller = new UserController();
    if ($method === 'GET' && $id) {
        $controller->get($id);
    } elseif ($method === 'GET' && !$id && $action === 'all') {
        // Admin: Lấy tất cả users
        $controller->getAll();
    } elseif ($method === 'POST') {
        $controller->store();
    } elseif ($method === 'PATCH' && $id) {
        $controller->update($id);
    } elseif ($method === 'DELETE' && $id) {
        $controller->delete($id);
    } else {
        http_response_code(405);
        echo json_encode(['error' => 'Method not Allowed']);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Route not founded']);
}