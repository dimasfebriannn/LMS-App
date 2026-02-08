<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User; // Import model User
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash; // Import untuk cek password

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // 1. Validasi input
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // 2. Cari user berdasarkan email di database lms_db
        $user = User::where('email', $request->email)->first();

        // 3. Cek apakah user ditemukan dan passwordnya cocok
        // Hash::check akan membandingkan password input dengan password terenkripsi di DB
        if ($user && Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => true,
                'message' => 'Login Berhasil!',
                'user' => [
                    'name' => $user->name, // Mengambil nama asli dari DB (misal: Dimas Febrian)
                    'email' => $user->email
                ]
            ], 200);
        }

        // 4. Jika gagal
        return response()->json([
            'success' => false,
            'message' => 'Email atau Password salah!'
        ], 401);
    }
}