<?php
require __DIR__ . '/../config/firebase.php';

class UserService {
    private $base_url;

    public function __construct() {
        $this->base_url = FIRESTORE_BASE_URL;
    }

    public function getUser($id) {
        $url = $this->base_url . '/users/' . $id;
        $response = file_get_contents($url);

        if ($response === false) {
            return null;
        }

        $data = json_decode($response, true);

        if (!isset($data['fields'])) {
            return null;
        }

        $fields = $data['fields'];

        return [
            'id' => basename($data['name']),
            'name' => $fields['name']['stringValue'] ?? '',
            'email' => $fields['email']['stringValue'] ?? '',
            'role' => $fields['role']['stringValue'] ?? 'user',
        ];
    }

    public function getAllUsers() {
        $url = $this->base_url . '/users';
        $response = file_get_contents($url);

        if ($response === false) {
            return [];
        }

        $data = json_decode($response, true);

        if (!isset($data['documents'])) {
            return [];
        }

        $users = [];
        foreach ($data['documents'] as $doc) {
            $fields = $doc['fields'];
            $users[] = [
                'id' => basename($doc['name']),
                'name' => $fields['name']['stringValue'] ?? '',
                'email' => $fields['email']['stringValue'] ?? '',
                'role' => $fields['role']['stringValue'] ?? 'user',
            ];
        }

        return $users;
    }

    public function createUser($data) {
        // Firestore REST API: To create document with specific ID, use POST with document ID in path
        // and add ?currentDocument.exists=false query parameter
        if (isset($data['id'])) {
            // Create document with specific ID
            $url = $this->base_url . '/users/' . $data['id'] . '?currentDocument.exists=false';
        } else {
            // Let Firestore generate ID
            $url = $this->base_url . '/users';
        }

        $payload = [
            'fields' => [
                'name' => ['stringValue' => $data['name'] ?? ''],
                'email' => ['stringValue' => $data['email'] ?? ''],
                'role' => ['stringValue' => $data['role'] ?? 'user'],
            ]
        ];

        $options = [
            'http' => [
                'method'  => 'POST',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload),
                'ignore_errors' => true
            ]
        ];

        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);

        if ($response === false) {
            // Get more error details
            $error = error_get_last();
            error_log('Firestore API Error: ' . print_r($error, true));
            return false;
        }

        $decoded = json_decode($response, true);
        
        // Check if response contains error
        if (isset($decoded['error'])) {
            error_log('Firestore API Error Response: ' . $response);
            // Try alternative method: use PATCH if POST fails
            if (isset($data['id'])) {
                return $this->createUserWithPatch($data);
            }
            return false;
        }

        return $decoded;
    }

    // Alternative method using PATCH (for creating new document)
    private function createUserWithPatch($data) {
        $url = $this->base_url . '/users/' . $data['id'];

        $payload = [
            'fields' => [
                'name' => ['stringValue' => $data['name'] ?? ''],
                'email' => ['stringValue' => $data['email'] ?? ''],
                'role' => ['stringValue' => $data['role'] ?? 'user'],
            ]
        ];

        $options = [
            'http' => [
                'method'  => 'PATCH',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload),
                'ignore_errors' => true
            ]
        ];

        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);

        if ($response === false) {
            return false;
        }

        $decoded = json_decode($response, true);
        
        if (isset($decoded['error'])) {
            return false;
        }

        return $decoded;
    }

    public function updateUser($id, $data) {
        $url = $this->base_url . '/users/' . $id;

        $fields = [];
        if (isset($data['name'])) {
            $fields['name'] = ['stringValue' => $data['name']];
        }
        if (isset($data['email'])) {
            $fields['email'] = ['stringValue' => $data['email']];
        }
        if (isset($data['role'])) {
            $fields['role'] = ['stringValue' => $data['role']];
        }

        if (empty($fields)) {
            return false;
        }

        $payload = ['fields' => $fields];

        $options = [
            'http' => [
                'method'  => 'PATCH',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload)
            ]
        ];

        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);

        return $response !== false;
    }

    public function deleteUser($id) {
        $url = $this->base_url . '/users/' . $id;

        $options = [
            'http' => [
                'method' => 'DELETE'
            ]
        ];

        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);

        return $response !== false;
    }
}
?>

