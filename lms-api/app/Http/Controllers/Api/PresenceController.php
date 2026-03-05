<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Presence;
use Illuminate\Http\Request;

class PresenceController extends Controller
{
    public function index($user_id)
    {
        $history = Presence::with('course')
            ->where('user_id', $user_id)
            ->orderBy('check_in', 'desc')
            ->get();

        return response()->json(['success' => true, 'data' => $history]);
    }
}
