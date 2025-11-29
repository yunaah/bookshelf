import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data History
    final List<Map<String, dynamic>> historyBooks = [
      {
        "title": "Bumi Manusia",
        "author": "Pramoedya A. Toer",
        "rating": 5.0,
        "finished": "15 Okt 2023",
        "review": "Masterpiece! Wajib baca seumur hidup sekali.",
        "cover": "https://upload.wikimedia.org/wikipedia/id/4/44/Bumi_Manusia.jpg"
      },
      {
        "title": "The Psychology of Money",
        "author": "Morgan Housel",
        "rating": 4.5,
        "finished": "2 Sept 2023",
        "review": "Membuka mata banget soal keuangan.",
        "cover": "https://m.media-amazon.com/images/I/71TRUbcF48L._AC_UF1000,1000_QL80_.jpg"
      },
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text("Riwayat Baca", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          const SizedBox(height: 24),
          ...historyBooks.map((book) => Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: book['cover'],
                    width: 70, height: 100, fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(book['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                                const SizedBox(width: 4),
                                Text("${book['rating']}", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(book['author'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text("Selesai: ${book['finished']}", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Text('"${book['review']}"', style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }
}