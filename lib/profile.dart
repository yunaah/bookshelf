import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'data.dart'; // Import Data

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // PASANG ANTENA DISINI
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: Data.bookListNotifier, // Mendengarkan perubahan data buku
      builder: (context, bookList, _) {
        
        // Hitung statistik langsung dari data terbaru (bookList)
        int totalBooks = bookList.length;
        int finishedBooks = bookList.where((b) => b['status'] == 'completed').length;
        int readingBooks = bookList.where((b) => b['status'] == 'reading').length;

        return SingleChildScrollView(
          child: Column(
            children: [
              // HEADER PROFIL
              Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64, height: 64, 
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), 
                          child: const Center(child: Text("JD", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("John Doe", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text("Bergabung sejak 2023", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade100)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // STATISTIK SEDERHANA (ANGKANYA SEKARANG DINAMIS)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(totalBooks.toString(), "Total Buku"),
                          Container(width: 1, height: 30, color: Colors.blue.shade400),
                          _buildStat(finishedBooks.toString(), "Selesai"),
                          Container(width: 1, height: 30, color: Colors.blue.shade400),
                          _buildStat(readingBooks.toString(), "Sedang Baca"),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // MENU OPSI
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pengaturan Akun", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 16),
                    
                    _buildMenuButton("Edit Profil", LucideIcons.userCog),
                    const SizedBox(height: 12),
                    _buildMenuButton("Notifikasi", LucideIcons.bell),
                    const SizedBox(height: 12),
                    _buildMenuButton("Bahasa", LucideIcons.languages),
                    const SizedBox(height: 12),
                    _buildMenuButton("Tentang Aplikasi", LucideIcons.info),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue.shade100)),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}