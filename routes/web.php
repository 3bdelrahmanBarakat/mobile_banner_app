<?php

use Illuminate\Support\Facades\Route;
use Osiset\ShopifyApp\Http\Controllers\AuthController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/shopify/auth', [AuthController::class, 'index'])->name('shopify.auth');
Route::get('/shopify/auth/callback', [AuthController::class, 'callback'])->name('shopify.auth.callback');
