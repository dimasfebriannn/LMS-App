<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attendance_sessions', function (Blueprint $table) {
            $table->id();
            // Menghubungkan ke tabel courses (pastikan nama tabelnya 'courses')
            $table->foreignId('course_id')->constrained('courses')->onDelete('cascade');

            // Token unik untuk QR, agar tidak mudah ditebak
            $table->string('token')->unique();

            // Waktu expired QR Code agar tidak bisa dipakai selamanya
            $table->timestamp('expires_at');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendance_sessions');
    }
};
