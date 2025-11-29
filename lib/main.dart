import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import file-file kita
import 'shelves.dart';
import 'history.dart';
import 'profile.dart';
import 'data.dart'; // Import Data Service agar bisa baca progress

void main() {
  runApp(const BookshelfApp());
}

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookshelf App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Supaya UI ter-update saat pindah tab (misal dari Home ke Profile), kita pakai logic ini
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita bangun list halaman di sini agar saat Data berubah, halaman ikut ter-refresh
    final List<Widget> pages = [
      const HomePage(),
      const ShelvesPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Modal Tambah Buku (Placeholder)
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddBookModal(),
          );
        },
        backgroundColor: Colors.blue[600],
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.shade50,
          elevation: 0,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(LucideIcons.book), selectedIcon: Icon(LucideIcons.book, color: Colors.blue), label: 'Home'),
            NavigationDestination(icon: Icon(LucideIcons.library), selectedIcon: Icon(LucideIcons.library, color: Colors.blue), label: 'Rak'),
            NavigationDestination(icon: Icon(LucideIcons.star), selectedIcon: Icon(LucideIcons.star, color: Colors.blue), label: 'History'),
            NavigationDestination(icon: Icon(LucideIcons.user), selectedIcon: Icon(LucideIcons.user, color: Colors.blue), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN HOME (Di-update jadi Stateful agar bisa rebuild saat update progress) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Fungsi Memunculkan Modal Update
  void _showUpdateModal(BuildContext context) {
    // Controller untuk input text, default-nya angka halaman saat ini
    TextEditingController pageController = TextEditingController(text: Data.currentPage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Biar modalnya bisa naik kalau keyboard muncul
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              
              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Update Progress", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("${Data.totalPage} Pages", style: GoogleFonts.poppins(color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 24),

              // Input Page & Cover
              Row(
                children: [
                  // Gambar Buku Kecil
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: "https://m.media-amazon.com/images/I/81wgcld4wxL._AC_UF1000,1000_QL80_.jpg",
                      width: 60, height: 90, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Input Field
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Halaman saat ini", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: pageController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              ),
                            ),
                            Text("/ ${Data.totalPage}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400])),
                          ],
                        ),
                        Container(height: 2, color: Colors.blue[100]),
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Tombol Action Update
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // LOGIC UPDATE DATA DI SINI
                    int? newPage = int.tryParse(pageController.text);
                    if (newPage != null && newPage <= Data.totalPage) {
                      setState(() {
                        Data.updateProgress(newPage); // Panggil fungsi di data.dart
                      });
                      Navigator.pop(context); // Tutup modal
                      
                      // Refresh tampilan HomePage ini
                      // (Kita panggil setState kosong agar build() jalan ulang dan progress bar berubah)
                      setState(() {}); 
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress disimpan! Kalender diupdate.")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Update", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context), // Tombol 'Finished' (Dummy logic: tutup aja)
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Text("Selesai", style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data Dummy Koleksi (Statis)
    final List<Map<String, dynamic>> books = [
      {"title": "Laut Bercerita", "author": "Leila S. Chudori", "shelf": "Fiction", "cover": "https://upload.wikimedia.org/wikipedia/id/6/67/Laut_Bercerita.jpeg"},
      {"title": "Sapiens", "author": "Yuval Noah Harari", "shelf": "Science", "cover": "https://m.media-amazon.com/images/I/713jIoMO3UL._AC_UF1000,1000_QL80_.jpg"},
      {"title": "Bumi Manusia", "author": "Pramoedya A. Toer", "shelf": "History", "cover": "https://upload.wikimedia.org/wikipedia/id/4/44/Bumi_Manusia.jpg"},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi, Reader! 👋", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  Text("Mau baca apa hari ini?", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // HEADER SEDANG DIBACA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Sedang Dibaca", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      
                      // TOMBOL UPDATE
                      GestureDetector(
                        onTap: () => _showUpdateModal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Text("Update", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue[600])),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // KARTU BUKU UTAMA (DINAMIS DARI DATA.DART)
                  GestureDetector(
                    onTap: () => _showUpdateModal(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4338CA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: "https://m.media-amazon.com/images/I/81wgcld4wxL._AC_UF1000,1000_QL80_.jpg",
                              width: 80, height: 110, fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[300]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Atomic Habits", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text("James Clear", style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue[100])),
                                const SizedBox(height: 12),
                                // Progress Bar Dinamis
                                LinearPercentIndicator(
                                  padding: EdgeInsets.zero, lineHeight: 8.0, 
                                  percent: Data.progress, // DARI DATA.DART
                                  backgroundColor: Colors.blue[900]!.withOpacity(0.3), progressColor: Colors.blue[200], barRadius: const Radius.circular(10),
                                ),
                                const SizedBox(height: 8),
                                Align(alignment: Alignment.centerRight, child: Text("${(Data.progress * 100).toInt()}% Selesai", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[100]))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Koleksi Buku", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: Icon(LucideIcons.search, size: 18, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: book['cover'], width: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.grey[200]))),
                                  Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)), child: Text(book['shelf'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(book['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800])),
                            Text(book['author'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal Tambah Buku (Placeholder Code dari sebelumnya)
class AddBookModal extends StatelessWidget {
  const AddBookModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Tambah Buku Baru",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildOptionCard(
                  icon: LucideIcons.scanLine,
                  title: "Scan ISBN",
                  subtitle: "Otomatis via Kamera",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Scan akan segera hadir!")),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOptionCard(
                  icon: LucideIcons.bookOpen,
                  title: "Manual",
                  subtitle: "Ketik Judul",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    // Nanti kita buka form manual di sini
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}