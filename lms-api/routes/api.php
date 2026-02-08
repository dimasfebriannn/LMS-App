<?php

use App\Http\Controllers\Api\AuthController; // Pastikan import ini ada
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Course;
use App\Http\Controllers\Api\AttendanceController;

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