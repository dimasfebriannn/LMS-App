<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Attendance;
use Carbon\Carbon;

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
}