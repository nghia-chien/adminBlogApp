<?php
require_once __DIR__ . '/../service/FireStoreService.php';

class BookmarkController {
    private $firestore;

    public function __construct() {
        $this->firestore = new FireStoreService();
    }

    public function get($userId) {
        $bookmarks = $this->firestore->getUserBookmarks($userId);
        echo json_encode([
            'success' => true,
            'data' => $bookmarks
        ]);
    }

    public function check($userId, $articleId) {
        $bookmarkId = $this->firestore->isBookmarked($userId, $articleId);
        echo json_encode([
            'success' => true,
            'isBookmarked' => $bookmarkId !== false,
            'bookmarkId' => $bookmarkId !== false ? $bookmarkId : null
        ]);
    }

    public function store() {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input || !isset($input['userId']) || !isset($input['articleId'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        // Check if already bookmarked
        $existingBookmarkId = $this->firestore->isBookmarked($input['userId'], $input['articleId']);
        if ($existingBookmarkId !== false) {
            http_response_code(200);
            echo json_encode(['success' => true, 'message' => 'Already bookmarked']);
            return;
        }

        $result = $this->firestore->createBookmark($input['userId'], $input['articleId']);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Create bookmark failed']);
            return;
        }

        http_response_code(201);
        echo json_encode(['success' => true, 'data' => $result]);
    }

    public function delete($bookmarkId) {
        if (empty($bookmarkId)) {
            http_response_code(400);
            echo json_encode(['error' => 'Bookmark ID is required']);
            return;
        }

        error_log("Deleting bookmark with ID: $bookmarkId");
        $result = $this->firestore->deleteBookmark($bookmarkId);

        if ($result === false) {
            http_response_code(500);
            echo json_encode([
                'error' => 'Delete bookmark failed',
                'bookmarkId' => $bookmarkId
            ]);
            return;
        }

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Bookmark deleted successfully'
        ]);
    }
}
?>

