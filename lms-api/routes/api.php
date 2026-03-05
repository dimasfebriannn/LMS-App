<?php

use App\Http\Controllers\Api\AuthController; // Pastikan import ini ada
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\Lecturer\QRGeneratorController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\Lecturer\CourseController;

// Route untuk login aplikasi Flutter kamu
Route::post('/login', [AuthController::class, 'login']);

// Route bawaan (biarkan saja)
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/courses', function () {
    return response()->json([
        'success' => true,
        'data' => \App\Models\Course::all()
    ]);
});

Route::post('/attendance', [AttendanceController::class, 'store']);
Route::get('/attendances/{user_id}', [AttendanceController::class, 'index']);

Route::get('/assignments', function () {
    return response()->json([
        'success' => true,
        'data' => \App\Models\Assignment::with('course')->get()
    ]);
});

Route::post('/submissions', [App\Http\Controllers\SubmissionController::class, 'store']);
Route::get('/submissions/check/{user_id}/{assignment_id}', [App\Http\Controllers\SubmissionController::class, 'checkStatus']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/lecturer/generate-qr', [QRGeneratorController::class, 'generate']);
});

Route::middleware('auth:sanctum')->group(function () {
    // Route untuk mahasiswa melakukan scan
    Route::post('/attend', [\App\Http\Controllers\Api\AttendanceController::class, 'attend']);
});

Route::middleware('auth:sanctum')->group(function () {
    // Route untuk mengambil daftar kelas dosen
    Route::get('/lecturer/courses', [CourseController::class, 'index']);
});