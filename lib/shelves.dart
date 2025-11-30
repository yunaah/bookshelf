import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'data.dart'; 

class ShelvesPage extends StatefulWidget {
  const ShelvesPage({super.key});

  @override
  State<ShelvesPage> createState() => _ShelvesPageState();
}

class _ShelvesPageState extends State<ShelvesPage> {
  
  void _showAddShelfDialog() {
    TextEditingController shelfController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Buat Rak Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: shelfController,
            decoration: InputDecoration(
              hintText: "Nama Rak (misal: Komik)",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey))
            ),
            ElevatedButton(
              onPressed: () async {
                if (shelfController.text.isNotEmpty) {
                  Navigator.pop(context); 
                  bool success = await Data.addShelf(shelfController.text);
                  if (success) {
                    setState(() {}); 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rak berhasil dibuat!"), backgroundColor: Colors.green));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: Text("Simpan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))
            ),
          ],
        );
      },
    );
  }

  void _deleteShelf(String shelfName) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Rak '$shelfName'?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("Buku di dalam rak ini TIDAK akan terhapus, tapi akan dipindahkan ke kategori 'Uncategorized'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              bool success = await Data.deleteShelf(shelfName);
              if (success) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rak berhasil dihapus"), backgroundColor: Colors.red));
              }
            }, 
            child: const Text("Hapus Rak", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- INI ANTENANYA ---
    // Kita pasang ValueListenableBuilder di sini
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: Data.bookListNotifier, // Mendengarkan perubahan data buku
      builder: (context, bookList, _) {
        
        // Ambil daftar rak terbaru
        List<String> shelves = Data.shelfOptions;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Koleksi Rak", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  InkWell(
                    onTap: _showAddShelfDialog,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.plus, color: Colors.blue, size: 24),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              if (shelves.isEmpty)
                 Center(
                   child: Padding(
                     padding: const EdgeInsets.only(top: 50),
                     child: Column(
                       children: [
                         Icon(LucideIcons.library, size: 48, color: Colors.grey[300]),
                         const SizedBox(height: 16),
                         Text("Belum ada rak", style: GoogleFonts.poppins(color: Colors.grey[400])),
                       ],
                       ),
                   ),
                 ),

              ...shelves.map((shelfName) {
                // Hitung jumlah buku langsung dari 'bookList' yang baru
                int count = bookList.where((b) => b['shelf'] == shelfName).length;
                
                bool isProtected = shelfName == 'Uncategorized';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isProtected ? Colors.grey.withOpacity(0.1) : Colors.purple.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Icon(LucideIcons.library, color: isProtected ? Colors.grey : Colors.purple),
                      ),
                      title: Text(shelfName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      subtitle: Text("$count Buku", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                      
                      trailing: isProtected 
                        ? null 
                        : IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                            onPressed: () => _deleteShelf(shelfName), 
                          ),

                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      
                      // Isi Rak diambil dari bookList yang dinamis
                      children: bookList.where((b) => b['shelf'] == shelfName).map((book) => Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.book, size: 16, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(book['title'], style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ],
          ),
        );
      }
    );
  }
}