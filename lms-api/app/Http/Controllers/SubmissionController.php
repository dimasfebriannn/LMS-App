<?php

namespace App\Http\Controllers;

use App\Models\Submission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class SubmissionController extends Controller
{
    public function store(Request $request)
    {
        // DEBUG: Catat request ke log untuk memastikan ID tidak 0
        Log::info("Request Data: ", $request->all());

        // Konversi manual input string dari Flutter menjadi Integer
        $request->merge([
            'user_id' => (int) $request->user_id,
            'assignment_id' => (int) $request->assignment_id,
        ]);

        // Cek jika user_id masih 0 setelah konversi
        if ($request->user_id === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Integrity Error: User ID tidak terbaca dari Flutter (Bernilai 0)'
            ], 422);
        }

        // Validasi
        $request->validate([
            'user_id' => 'required|numeric|exists:users,id',
            'assignment_id' => 'required|numeric|exists:assignments,id',
            'file' => 'required|file|mimes:pdf,doc,docx,zip|max:5120',
        ]);

        try {
            if ($request->hasFile('file')) {
                $file = $request->file('file');
                $filename = time() . '_' . $file->getClientOriginalName();

                // Simpan ke storage/app/public/submissions
                $file->storeAs('public/submissions', $filename);

                // Simpan ke DB
                $submission = Submission::create([
                    'user_id' => $request->user_id,
                    'assignment_id' => $request->assignment_id,
                    'file_path' => $filename,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Tugas berhasil disimpan',
                    'data' => $submission
                ], 201);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal simpan ke DB: ' . $e->getMessage()
            ], 500);
        }
    }

    public function checkStatus($user_id, $assignment_id)
    {
        $submitted = Submission::where('user_id', $user_id)
            ->where('assignment_id', $assignment_id)
            ->exists();

        return response()->json(['submitted' => $submitted]);
    }
}
