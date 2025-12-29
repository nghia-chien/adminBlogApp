<?php
require_once __DIR__ . '/../service/FireStoreService.php';

class CommentController {
    private $firestore;

    public function __construct() {
        $this->firestore = new FireStoreService();
    }

    public function get($articleId) {
        $comments = $this->firestore->getComments($articleId);
        echo json_encode([
            'success' => true,
            'data' => $comments
        ]);
    }

    public function store($articleId) {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['userId']) || !isset($input['content'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        // Get userName from input or use userId as fallback
        $userName = $input['userName'] ?? $input['userId'];

        $data = [
            'userId' => $input['userId'],
            'userName' => $userName,
            'content' => $input['content']
        ];

        $result = $this->firestore->createComment($articleId, $data);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Create comment failed']);
            return;
        }

        http_response_code(201);
        echo json_encode(['success' => true, 'data' => $result]);
    }

    public function delete($commentId, $articleId) {
        $result = $this->firestore->deleteComment($commentId, $articleId);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Delete comment failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }
}
?>

