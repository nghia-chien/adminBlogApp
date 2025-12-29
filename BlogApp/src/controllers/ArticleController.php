<?php
require_once __DIR__ . '/../service/FireStoreService.php';

class ArticleController {
    private $firestore;

    public function __construct() {
        $this->firestore = new FireStoreService();
    }

    public function get() {
        $articles = $this->firestore->getArticles();
        echo json_encode([
            'success' => true,
            'data' => $articles
        ]);
    }

    public function store() {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['title'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        $result = $this->firestore->createArticle($input);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Create article failed']);
            return;
        }

        http_response_code(201);
        echo json_encode(['success' => true]);
    }

    public function update($id) {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        $result = $this->firestore->updateArticle($id, $input);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Update failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }

    public function delete($id) {
        $result = $this->firestore->deleteArticle($id);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Delete failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }

    public function incrementViews($id) {
        $result = $this->firestore->incrementArticleViews($id);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Increment views failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }
}
?>