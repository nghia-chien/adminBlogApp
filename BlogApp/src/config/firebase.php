<?php
if (!defined('FIREBASE_PROJECT_ID')){
define('FIREBASE_PROJECT_ID', 'blogapp-cadca');
}
if (!defined('FIRESTORE_BASE_URL')){
define(
    'FIRESTORE_BASE_URL',
    'https://firestore.googleapis.com/v1/projects/' . FIREBASE_PROJECT_ID . '/databases/(default)/documents'
);
}