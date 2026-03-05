<?php

namespace App\Http\Controllers\Api\Lecturer;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CourseController extends Controller
{
    public function index()
    {
        // Gunakan Auth::user() yang lebih jelas referensinya
        $user = Auth::user();

        // Paksa type hinting agar VS Code tidak protes
        if ($user instanceof \App\Models\User) {
            $courses = $user->courses;

            return response()->json([
                'success' => true,
                'data' => $courses
            ]);
        }

        return response()->json(['success' => false, 'message' => 'User tidak ditemukan'], 404);
    }
}
