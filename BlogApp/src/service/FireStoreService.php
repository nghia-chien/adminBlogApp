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
            $fields[$key] = ['stringValue' => $value];
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

    // Increment article views
    public function incrementArticleViews($id) {
        // First get current article to preserve all fields
        $url = $this->base_url . '/articles/' . $id;
        $response = file_get_contents($url);
        
        if ($response === false) {
            return false;
        }
        
        $data = json_decode($response, true);
        if (!isset($data['fields']['views']['integerValue'])) {
            return false;
        }
        
        $currentViews = (int)$data['fields']['views']['integerValue'];
        $newViews = $currentViews + 1;
        
        // Get all existing fields to preserve them
        $existingFields = $data['fields'];
        
        // Update only the views field
        $existingFields['views'] = ['integerValue' => (string)$newViews];
        
        // Update with all fields preserved, only views changed
        $payload = [
            'fields' => $existingFields
        ];
        
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

    // Comments
    public function getComments($articleId) {
        $url = $this->base_url . '/articles/' . $articleId . '/comments';
        $response = file_get_contents($url);
        
        if ($response === false) {
            return [];
        }
        
        $data = json_decode($response, true);
        if (!isset($data['documents'])) {
            return [];
        }
        
        $comments = [];
        foreach ($data['documents'] as $doc) {
            $field = $doc['fields'];
            $comments[] = [
                'id' => basename($doc['name']),
                'articleId' => $articleId,
                'userId' => $field['userId']['stringValue'] ?? '',
                'userName' => $field['userName']['stringValue'] ?? '',
                'content' => $field['content']['stringValue'] ?? '',
                'created_at' => $field['created_at']['timestampValue'] ?? '',
            ];
        }
        
        // Sort by created_at descending
        usort($comments, function($a, $b) {
            return strcmp($b['created_at'], $a['created_at']);
        });
        
        return $comments;
    }

    public function createComment($articleId, $data) {
        $url = $this->base_url . '/articles/' . $articleId . '/comments';
        
        $timestamp = date('c'); // ISO 8601 format
        
        $payload = [
            'fields' => [
                'userId' => ['stringValue' => $data['userId']],
                'userName' => ['stringValue' => $data['userName']],
                'content' => ['stringValue' => $data['content']],
                'created_at' => ['timestampValue' => $timestamp]
            ]
        ];
        
        $options = [
            'http' => [
                'method'  => 'POST',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload)
            ]
        ];
        
        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);
        
        if ($response === false) {
            return false;
        }
        
        return json_decode($response, true);
    }

    public function deleteComment($commentId, $articleId) {
        $url = $this->base_url . '/articles/' . $articleId . '/comments/' . $commentId;
        
        // Use cURL for better DELETE request handling
        if (function_exists('curl_init')) {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json'
            ]);
            curl_setopt($ch, CURLOPT_FAILONERROR, false);
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);
            
            if ($error) {
                error_log("Firestore deleteComment cURL error: $error");
                return false;
            }
            
            // Firestore DELETE returns 200 or 204 on success
            if ($httpCode >= 200 && $httpCode < 300) {
                return true;
            } else {
                error_log("Firestore deleteComment failed: HTTP $httpCode, Response: $response");
                return false;
            }
        } else {
            // Fallback to file_get_contents if cURL is not available
            $options = [
                'http' => [
                    'method' => 'DELETE',
                    'header' => "Content-Type: application/json\r\n",
                    'ignore_errors' => true
                ]
            ];
            
            $context = stream_context_create($options);
            $response = @file_get_contents($url, false, $context);
            
            // Check HTTP response code
            if (isset($http_response_header)) {
                $statusLine = $http_response_header[0];
                preg_match('/\d{3}/', $statusLine, $matches);
                $statusCode = isset($matches[0]) ? (int)$matches[0] : 500;
                
                if ($statusCode >= 200 && $statusCode < 300) {
                    return true;
                }
            }
            
            return false;
        }
    }

    // Bookmarks
    public function getUserBookmarks($userId) {
        // Query bookmarks collection where userId matches
        $url = $this->base_url . '/bookmarks';
        $response = file_get_contents($url);
        
        if ($response === false) {
            return [];
        }
        
        $data = json_decode($response, true);
        if (!isset($data['documents'])) {
            return [];
        }
        
        $bookmarks = [];
        foreach ($data['documents'] as $doc) {
            $field = $doc['fields'];
            if (($field['userId']['stringValue'] ?? '') === $userId) {
                $bookmarks[] = [
                    'id' => basename($doc['name']),
                    'userId' => $field['userId']['stringValue'] ?? '',
                    'articleId' => $field['articleId']['stringValue'] ?? '',
                    'created_at' => $field['created_at']['timestampValue'] ?? '',
                ];
            }
        }
        
        return $bookmarks;
    }

    public function isBookmarked($userId, $articleId) {
        $bookmarks = $this->getUserBookmarks($userId);
        foreach ($bookmarks as $bookmark) {
            if ($bookmark['articleId'] === $articleId) {
                return $bookmark['id'];
            }
        }
        return false;
    }

    public function createBookmark($userId, $articleId) {
        $url = $this->base_url . '/bookmarks';
        
        $timestamp = date('c');
        
        $payload = [
            'fields' => [
                'userId' => ['stringValue' => $userId],
                'articleId' => ['stringValue' => $articleId],
                'created_at' => ['timestampValue' => $timestamp]
            ]
        ];
        
        $options = [
            'http' => [
                'method'  => 'POST',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload)
            ]
        ];
        
        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);
        
        if ($response === false) {
            return false;
        }
        
        return json_decode($response, true);
    }

    public function deleteBookmark($bookmarkId) {
        $url = $this->base_url . '/bookmarks/' . $bookmarkId;
        
        // Use cURL for better DELETE request handling
        if (function_exists('curl_init')) {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json'
            ]);
            curl_setopt($ch, CURLOPT_FAILONERROR, false);
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);
            
            if ($error) {
                error_log("Firestore deleteBookmark cURL error: $error");
                return false;
            }
            
            // Firestore DELETE returns 200 or 204 on success
            if ($httpCode >= 200 && $httpCode < 300) {
                return true;
            } else {
                error_log("Firestore deleteBookmark failed: HTTP $httpCode, Response: $response");
                return false;
            }
        } else {
            // Fallback to file_get_contents if cURL is not available
            $options = [
                'http' => [
                    'method' => 'DELETE',
                    'header' => "Content-Type: application/json\r\n",
                    'ignore_errors' => true
                ]
            ];
            
            $context = stream_context_create($options);
            
            $oldErrorReporting = error_reporting(E_ALL & ~E_WARNING);
            $response = @file_get_contents($url, false, $context);
            error_reporting($oldErrorReporting);
            
            // Check HTTP response headers
            if (isset($http_response_header) && is_array($http_response_header) && count($http_response_header) > 0) {
                $statusLine = $http_response_header[0];
                if (preg_match('/HTTP\/\d\.\d\s+(\d+)/', $statusLine, $matches)) {
                    $statusCode = (int)$matches[1];
                    if ($statusCode >= 200 && $statusCode < 300) {
                        return true;
                    } else {
                        error_log("Firestore deleteBookmark failed: HTTP $statusCode");
                        return false;
                    }
                }
            }
            
            return $response !== false;
        }
    }

    // Likes
    public function getArticleLikes($articleId) {
        $url = $this->base_url . '/articles/' . $articleId . '/likes';
        $response = file_get_contents($url);
        
        if ($response === false) {
            return [];
        }
        
        $data = json_decode($response, true);
        if (!isset($data['documents'])) {
            return [];
        }
        
        $likes = [];
        foreach ($data['documents'] as $doc) {
            $field = $doc['fields'];
            $likes[] = [
                'id' => basename($doc['name']),
                'userId' => $field['userId']['stringValue'] ?? '',
                'created_at' => $field['created_at']['timestampValue'] ?? '',
            ];
        }
        
        return $likes;
    }

    public function isLiked($userId, $articleId) {
        $likes = $this->getArticleLikes($articleId);
        foreach ($likes as $like) {
            if ($like['userId'] === $userId) {
                return $like['id'];
            }
        }
        return false;
    }

    public function createLike($userId, $articleId) {
        $url = $this->base_url . '/articles/' . $articleId . '/likes';
        
        $timestamp = date('c');
        
        $payload = [
            'fields' => [
                'userId' => ['stringValue' => $userId],
                'created_at' => ['timestampValue' => $timestamp]
            ]
        ];
        
        $options = [
            'http' => [
                'method'  => 'POST',
                'header'  => "Content-Type: application/json\r\n",
                'content' => json_encode($payload)
            ]
        ];
        
        $context = stream_context_create($options);
        $response = file_get_contents($url, false, $context);
        
        if ($response === false) {
            return false;
        }
        
        return json_decode($response, true);
    }

    public function deleteLike($likeId, $articleId) {
        $url = $this->base_url . '/articles/' . $articleId . '/likes/' . $likeId;
        
        // Use cURL for better DELETE request handling
        if (function_exists('curl_init')) {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json'
            ]);
            curl_setopt($ch, CURLOPT_FAILONERROR, false);
            
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);
            
            if ($error) {
                error_log("Firestore deleteLike cURL error: $error");
                return false;
            }
            
            // Firestore DELETE returns 200 or 204 on success
            if ($httpCode >= 200 && $httpCode < 300) {
                return true;
            } else {
                error_log("Firestore deleteLike failed: HTTP $httpCode, Response: $response");
                return false;
            }
        } else {
            // Fallback to file_get_contents if cURL is not available
            $options = [
                'http' => [
                    'method' => 'DELETE',
                    'header' => "Content-Type: application/json\r\n",
                    'ignore_errors' => true
                ]
            ];
            
            $context = stream_context_create($options);
            
            $oldErrorReporting = error_reporting(E_ALL & ~E_WARNING);
            $response = @file_get_contents($url, false, $context);
            error_reporting($oldErrorReporting);
            
            // Check HTTP response headers
            if (isset($http_response_header) && is_array($http_response_header) && count($http_response_header) > 0) {
                $statusLine = $http_response_header[0];
                if (preg_match('/HTTP\/\d\.\d\s+(\d+)/', $statusLine, $matches)) {
                    $statusCode = (int)$matches[1];
                    if ($statusCode >= 200 && $statusCode < 300) {
                        return true;
                    } else {
                        error_log("Firestore deleteLike failed: HTTP $statusCode");
                        return false;
                    }
                }
            }
            
            return $response !== false;
        }
    }

}
?>