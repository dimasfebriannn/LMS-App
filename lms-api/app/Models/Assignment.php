<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    protected $fillable = [
        'course_id',
        'title',
        'description',
        'deadline'
    ];

    public function course()
    {
        return $this->belongsTo(Course::class);
    }
}
