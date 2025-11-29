import 'package:flutter/material.dart';

// Class ini pura-pura jadi Database kita
class Data {
  // Data Buku yang lagi dibaca (Atomic Habits)
  static int currentPage = 208;
  static int totalPage = 320;
  static double get progress => currentPage / totalPage;
  
  // Data Tanggal Baca & Buku apa yang dibaca
  // Format: Tanggal -> URL Cover Buku
  static Map<DateTime, String> readingHistory = {
    DateTime.now().subtract(const Duration(days: 1)): "https://m.media-amazon.com/images/I/81wgcld4wxL._AC_UF1000,1000_QL80_.jpg",
    DateTime.now().subtract(const Duration(days: 3)): "https://m.media-amazon.com/images/I/81wgcld4wxL._AC_UF1000,1000_QL80_.jpg",
    DateTime.now().subtract(const Duration(days: 4)): "https://upload.wikimedia.org/wikipedia/id/6/67/Laut_Bercerita.jpeg",
  };

  // Fungsi untuk update progress & catat hari ini sudah baca
  static void updateProgress(int newPage) {
    currentPage = newPage;
    
    // Catat hari ini (biar jam-nya 00:00:00 agar cocok sama kalender)
    DateTime today = DateTime.now();
    DateTime dateOnly = DateTime(today.year, today.month, today.day);
    
    // Simpan cover buku Atomic Habit ke tanggal hari ini
    readingHistory[dateOnly] = "https://m.media-amazon.com/images/I/81wgcld4wxL._AC_UF1000,1000_QL80_.jpg";
  }
}