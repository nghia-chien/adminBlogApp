<?php
require __DIR__ . '/../config/firebase.php';

class FireStoreService {
    private $base_url;

    public function __construct() {
        $this->base_url = FIRESTORE_BASE_URL;
    }

    public function getArticles() {
        $url = $this->base_url . '/articles';
        $response = file_get_contents($url);

        if ($response === false) {
            http_response_code(404);
            echo json_decode(['error' => 'firestore not connect']);
            exit;
        } 

        $data = json_decode($response, true);

        if (!isset($data['documents']) === true) {
            return [];
        }

        $articles = [];

        foreach ($data['documents'] as $doc) {
            $field = $doc['fields'];

            $articles[] = [
                'id' => basename($doc['name']),
                'title' => $field['title']['stringValue'] ?? '',
                'content' => $field['content']['stringValue'] ?? '',
                'summary' => $field['summary']['stringValue'] ?? '',
                'category' => $field['category']['stringValue'] ?? '',
                'views' => $field['views']['integerValue'] ?? '',   
                'author' => $field['author']['stringValue'] ?? '',
                'imageUrl' => $field['imageUrl']['stringValue'] ?? null,
                'created_at' => $field['created_at']['timestampValue'] ?? '',
            ];
        }

        return $articles;
    }

    public function createArticle($data) {
    $url = $this->base_url . '/articles';

    // 1️⃣ KHAI BÁO FIELDS NGAY TỪ ĐẦU
    $fields = [
        'title' => ['stringValue' => $data['title']],
        'content' => ['stringValue' => $data['content'] ?? ''],
        'summary' => ['stringValue' => $data['summary'] ?? ''],
        'category' => ['stringValue' => $data['category'] ?? ''],
        'author' => ['stringValue' => $data['author'] ?? ''],
        'views' => ['integerValue' => 0],
        'created_at' => ['timestampValue' => date('c')],
    ];

    // 2️⃣ THÊM IMAGE URL (NẾU CÓ)
    if (!empty($data['imageUrl'])) {
        $fields['imageUrl'] = ['stringValue' => $data['imageUrl']];
    }

    // 3️⃣ TẠO PAYLOAD DUY NHẤT
    $payload = ['fields' => $fields];

    $options = [
        'http' => [
            'method'  => 'POST',
            'header'  => "Content-Type: application/json\r\n",
            'content' => json_encode($payload)
        ]
    ];

    $context = stream_context_create($options);
    $response = file_get_contents($url, false, $context);

    return $response !== false;
}


    public function updateArticle($id, $data) {
        $url = $this->base_url . '/articles/' . $id;

        $fields = [];
        foreach ($data as $key => $value) {
            // Loại bỏ views khỏi update - views không được phép sửa
            if ($key === 'views') {
                continue;
            }
            $fields[$key] = ['stringValue' => (string)$value];
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

    public function deleteArticle($id) {
        $url = $this->base_url . '/articles/' . $id;

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