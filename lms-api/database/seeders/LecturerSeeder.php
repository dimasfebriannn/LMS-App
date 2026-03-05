<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class LecturerSeeder extends Seeder
{
    public function run()
    {
        User::create([
            'name' => 'Dosen Samid, M.T.',
            'email' => 'dosen@lms.com',
            'password' => Hash::make('password123'), // Jangan lupa di-hash!
            'role' => 'lecturer', // Kunci utamanya ada di sini
        ]);
    }
}