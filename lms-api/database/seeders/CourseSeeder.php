<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Course;

class CourseSeeder extends Seeder
{
    public function run(): void
    {
        // Menghapus data lama agar tidak duplikat
        Course::truncate();

        $courses = [
            [
                'title' => 'Literasi Digital',
                'lecturer' => 'Dosen Literasi, M.Kom.',
                'progress' => 0.45,
            ],
            [
                'title' => 'Kewirausahaan',
                'lecturer' => 'Dosen Entrepreneur, MBA.',
                'progress' => 0.30,
            ],
            [
                'title' => 'Manajemen Kualitas Perangkat Lunak',
                'lecturer' => 'Dosen QA, M.T.',
                'progress' => 0.60,
            ],
            [
                'title' => 'Perawatan Perangkat Lunak',
                'lecturer' => 'Dosen Maintenance, S.T.',
                'progress' => 0.25,
            ],
            [
                'title' => 'Workshop SI Berbasis Web Framework',
                'lecturer' => 'Dosen Web, M.Cs.',
                'progress' => 0.75,
            ],
            [
                'title' => 'Workshop Mobile Applications Framework',
                'lecturer' => 'Dosen Mobile, M.T.',
                'progress' => 0.50,
            ],
        ];

        foreach ($courses as $course) {
            Course::create($course);
        }
    }
}