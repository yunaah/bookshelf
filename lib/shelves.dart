import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShelvesPage extends StatelessWidget {
  const ShelvesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data Rak
    final List<Map<String, dynamic>> shelves = [
      {"name": "Fiction", "count": 12},
      {"name": "Science", "count": 5},
      {"name": "History", "count": 3},
      {"name": "Romance", "count": 8},
      {"name": "Self-Improvement", "count": 10},
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text("Rak Buku", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 24),
          // List Rak
          ...shelves.map((shelf) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.library, color: Colors.orange.shade700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shelf['name'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      Text("${shelf['count']} Buku", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey[400]),
              ],
            ),
          )),
          // Tombol Tambah Rak
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.plus, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text("Buat Rak Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[400])),
              ],
            ),
          )
        ],
      ),
    );
  }
}