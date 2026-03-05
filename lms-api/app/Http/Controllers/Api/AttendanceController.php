<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\AttendanceSession;
use Carbon\Carbon;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'course_id' => 'required', // Kita asumsikan QR code isinya ID Matkul
        ]);

        // Cek apakah hari ini user sudah absen di matkul yang sama
        $alreadyAttended = Attendance::where('user_id', $request->user_id)
            ->where('course_id', $request->course_id)
            ->whereDate('created_at', Carbon::today())
            ->first();

        if ($alreadyAttended) {
            return response()->json([
                'success' => false,
                'message' => 'Kamu sudah absen di mata kuliah ini hari ini!'
            ], 400);
        }

        $attendance = Attendance::create([
            'user_id' => $request->user_id,
            'course_id' => $request->course_id,
            'status' => 'Hadir',
            'location' => $request->location ?? 'Kampus Utama',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Presensi berhasil dicatat!',
            'data' => $attendance
        ]);
    }

    public function index($user_id)
    {
        $history = Attendance::with('course')
            ->where('user_id', $user_id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $history
        ]);
    }

    public function attend(Request $request)
    {
        $request->validate([
            'course_id' => 'required',
            'token'     => 'required',
        ]);

        // 1. Cari sesi berdasarkan token
        $session = AttendanceSession::where('token', $request->token)
            ->where('course_id', $request->course_id)
            ->first();

        if (!$session) {
            return response()->json(['success' => false, 'message' => 'QR Code tidak valid!'], 404);
        }

        // 2. Cek apakah sudah expired (sekarang > expires_at)
        if (Carbon::now()->greaterThan($session->expires_at)) {
            return response()->json(['success' => false, 'message' => 'QR Code sudah kadaluarsa!'], 400);
        }

        // 3. Cek apakah user sudah absen di matkul ini hari ini
        $alreadyAttended = Attendance::where('user_id', $request->user_id)
            ->where('course_id', $request->course_id)
            ->whereDate('created_at', Carbon::today())
            ->first();

        if ($alreadyAttended) {
            return response()->json(['success' => false, 'message' => 'Kamu sudah absen hari ini!'], 400);
        }

        // 4. Catat kehadiran
        Attendance::create([
            'user_id'   => $request->user_id,
            'course_id' => $request->course_id,
            'status'    => 'Hadir',
            'location'  => 'Kampus Utama',
        ]);

        return response()->json(['success' => true, 'message' => 'Presensi berhasil dicatat!']);
    }
}
