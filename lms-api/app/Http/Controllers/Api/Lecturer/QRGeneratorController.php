<?php

namespace App\Http\Controllers\Api\Lecturer;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use App\Models\AttendanceSession;
use Carbon\Carbon;

class QRGeneratorController extends Controller
{
    public function generate(Request $request)
    {
        $request->validate([
            'course_id' => 'required|exists:courses,id',
        ]);

        // 1. Buat token unik (contoh: "ABS-Dimas-1234")
        $token = 'ABS-' . strtoupper(Str::random(6));

        // 2. Simpan sesi ke database
        // QR aktif selama 10 menit
        $session = AttendanceSession::create([
            'course_id'  => $request->course_id,
            'token'      => $token,
            'expires_at' => Carbon::now()->addMinutes(10),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'QR Code berhasil dibuat!',
            'data' => [
                'token' => $token,
                'expires_at' => $session->expires_at,
                // Data ini yang nanti di-encode ke QR Code
                'qr_payload' => json_encode([
                    'course_id' => $request->course_id,
                    'token'     => $token
                ])
            ]
        ]);
    }
}