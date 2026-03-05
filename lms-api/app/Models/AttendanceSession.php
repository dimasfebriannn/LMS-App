<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AttendanceSession extends Model
{
    use HasFactory;

    protected $fillable = ['course_id', 'token', 'expires_at'];

    // Relasi ke Course: Sesi ini milik matkul apa?
    public function course()
    {
        return $this->belongsTo(Course::class);
    }
}