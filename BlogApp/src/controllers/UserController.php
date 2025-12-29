<?php
require __DIR__ . '/../service/UserService.php';

class UserController {
    private $userService;

    public function __construct() {
        $this->userService = new UserService();
    }

    public function get($id = null) {
        if ($id) {
            $user = $this->userService->getUser($id);
            if ($user) {
                echo json_encode([
                    'success' => true,
                    'data' => $user
                ]);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'User not found']);
            }
        } else {
            http_response_code(400);
            echo json_encode(['error' => 'User ID is required']);
        }
    }

    public function getAll() {
        $users = $this->userService->getAllUsers();
        echo json_encode([
            'success' => true,
            'data' => $users
        ]);
    }

    public function store() {
        $input = json_decode(file_get_contents('php://input'), true);

        // Log the input for debugging
        error_log('UserController::store - Input: ' . print_r($input, true));

        if (!$input || !isset($input['email'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data. Email is required.']);
            return;
        }

        // Validate required fields
        if (!isset($input['id']) || !isset($input['name'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data. ID and name are required.']);
            return;
        }

        $result = $this->userService->createUser($input);

        // Log the result for debugging
        error_log('UserController::store - Result: ' . print_r($result, true));

        if ($result === false) {
            http_response_code(500);
            echo json_encode([
                'error' => 'Create user failed',
                'details' => 'Check server logs for more information'
            ]);
            return;
        }

        http_response_code(201);
        echo json_encode([
            'success' => true,
            'data' => [
                'id' => $input['id'],
                'name' => $input['name'],
                'email' => $input['email'],
                'role' => $input['role'] ?? 'user',
            ]
        ]);
    }

    public function update($id) {
        $input = json_decode(file_get_contents('php://input'), true);

        if (!$input) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid data']);
            return;
        }

        $result = $this->userService->updateUser($id, $input);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Update failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }

    public function delete($id) {
        $result = $this->userService->deleteUser($id);

        if ($result === false) {
            http_response_code(500);
            echo json_encode(['error' => 'Delete failed']);
            return;
        }

        echo json_encode(['success' => true]);
    }
}
?>

