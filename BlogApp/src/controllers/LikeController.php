<?php
require_once __DIR__ . '/../service/FireStoreService.php';

class LikeController {
    private $firestore;

    public function __construct() {
        $this->firestore = new FireStoreService();
    }

    public function get($articleId) {
        $likes = $this->firestore->getArticleLikes($articleId);
        echo json_encode([
            'success' => true,
            'data' => $likes,
            'count' => count($likes)
        ]);
    }

    public function check($userId, $articleId) {
        $likeId = $this->firestore->isLiked($userId, $articleId);
        echo json_encode([
            'success' => true,
            'isLiked' => $likeId !== false,
            'likeId' => $likeId !== false ? $likeId : null
        ]);
    }

    public function store($articleId) {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['userId'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        // Check if already liked
        $existingLikeId = $this->firestore->isLiked($input['userId'], $articleId);
        if ($existingLikeId !== false) {
            http_response_code(200);
            echo json_encode(['success' => true, 'message' => 'Already liked']);
            return;
        }

        $result = $this->firestore->createLike($input['userId'], $articleId);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Create like failed']);
            return;
        }

        http_response_code(201);
        echo json_encode(['success' => true, 'data' => $result]);
    }

    public function delete($likeId, $articleId) {
        if (empty($likeId) || empty($articleId)) {
            http_response_code(400);
            echo json_encode([
                'error' => 'Like ID and Article ID are required',
                'likeId' => $likeId,
                'articleId' => $articleId
            ]);
            return;
        }

        error_log("Deleting like with ID: $likeId for article: $articleId");
        $result = $this->firestore->deleteLike($likeId, $articleId);

        if ($result === false) {
            http_response_code(500);
            echo json_encode([
                'error' => 'Delete like failed',
                'likeId' => $likeId,
                'articleId' => $articleId
            ]);
            return;
        }

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Like deleted successfully'
        ]);
    }
}
?>

