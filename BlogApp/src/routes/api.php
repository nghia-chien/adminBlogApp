<?php
require __DIR__ . '/../config/firebase.php';
require_once __DIR__ . '/../controllers/ArticleController.php';

$method = $_SERVER['REQUEST_METHOD'];
$path = $_GET['path'] ?? '';
$id = $_GET['id'] ?? '';

$controller = new ArticleController();

if ($path === 'articles') {
    if ($method === 'GET') {
        $controller->get();
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