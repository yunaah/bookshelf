import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'data.dart'; // Import Data Service

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. FILTER DATA BERDASARKAN STATUS
    // Kita ambil dari Data.homeBookList yang sudah ditarik dari Laravel
    final wishlistBooks = Data.homeBookList.where((b) => b['status'] == 'wishlist').toList();
    final readingBooks = Data.homeBookList.where((b) => b['status'] == 'reading').toList();
    final finishedBooks = Data.homeBookList.where((b) => b['status'] == 'completed').toList();

    return DefaultTabController(
      length: 3, // Ada 3 Tab
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                "Status", 
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])
              ),
            ),
            
            // Tab Bar Navigation
            TabBar(
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: Colors.blue[600],
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: "To be Read"),
                Tab(text: "Current Read"),
                Tab(text: "Finised"),
              ],
            ),
            
            // Isi Konten Tab
            Expanded(
              child: TabBarView(
                children: [
                  _buildBookList(wishlistBooks, "Belum ada buku yang ingin dibaca", Colors.orange),
                  _buildBookList(readingBooks, "Tidak ada buku yang sedang dibaca", Colors.blue),
                  _buildBookList(finishedBooks, "Belum ada buku yang tamat", Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk membuat List Buku
  Widget _buildBookList(List<Map<String, dynamic>> books, String emptyMsg, Color badgeColor) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.library, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(emptyMsg, style: GoogleFonts.poppins(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Cover Buku
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book['cover'],
                  width: 50, height: 75, fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info Buku
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'], 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])
                    ),
                    Text(
                      book['author'], 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])
                    ),
                    const SizedBox(height: 8),
                    
                    // Info Rak & Halaman
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Text(
                            book['shelf'], // Menampilkan Genre Rak
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (book['status'] == 'reading')
                          Text(
                            "${((book['current_page'] / book['total_pages']) * 100).toInt()}%",
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)
                          ),
                      ],
                    )
                  ],
                ),
              ),
              
              // Indikator Status
              Icon(
                book['status'] == 'completed' ? LucideIcons.checkCircle : (book['status'] == 'reading' ? LucideIcons.bookOpen : LucideIcons.bookmark),
                color: badgeColor,
                size: 20,
              )
            ],
          ),
        );
      },
    );
  }
}