import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 

import 'shelves.dart';
import 'status.dart';
import 'profile.dart';
import 'data.dart'; 

void main() {
  runApp(const BookshelfApp());
}

// 1. KUNCI MASTER (GLOBAL KEY)
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// --- HELPER: NOTIFIKASI DI ATAS ---
void showTopSnackBar(String message, {Color color = Colors.green}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  final context = rootScaffoldMessengerKey.currentContext;

  if (messenger == null || context == null) return;

  messenger.removeCurrentSnackBar();
  
  final screenHeight = MediaQuery.of(context).size.height;

  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(color == Colors.green ? LucideIcons.checkCircle : LucideIcons.alertCircle, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(
        bottom: screenHeight - 150, 
        left: 20, 
        right: 20
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

// --- HELPER: DIALOG ERROR ---
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [const Icon(LucideIcons.alertTriangle, color: Colors.red), const SizedBox(width: 10), Text("Gagal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red))]),
      content: Text(message, style: GoogleFonts.poppins()),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
    ),
  );
}

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookshelf App',
      scaffoldMessengerKey: rootScaffoldMessengerKey, // Pasang Kunci Master
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const ShelvesPage(),
      const StatusPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      // --- PERBAIKAN UTAMA: ValueListenableBuilder + IndexedStack ---
      // Kita bungkus IndexedStack dengan Listener. 
      // Jadi ketika data.dart selesai loading (bookListNotifier berubah), 
      // seluruh halaman akan direfresh otomatis. Rak & Status PASTI muncul.
      body: ValueListenableBuilder(
        valueListenable: Data.bookListNotifier,
        builder: (context, _, __) {
          return IndexedStack(
            index: _selectedIndex,
            children: pages, // Pake 'pages' bukan 'pagbodyes' (Typo Fixed)
          );
        }
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddBookModal(),
          );
          // Fetch data lagi untuk memastikan sinkronisasi
          await Data.fetchData();
        },
        backgroundColor: Colors.blue[600],
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.shade50,
          elevation: 0,
          destinations: const <Widget>[
            NavigationDestination(icon: Icon(LucideIcons.book), selectedIcon: Icon(LucideIcons.book, color: Colors.blue), label: 'Home'),
            NavigationDestination(icon: Icon(LucideIcons.library), selectedIcon: Icon(LucideIcons.library, color: Colors.blue), label: 'Rak'),
            NavigationDestination(icon: Icon(LucideIcons.star), selectedIcon: Icon(LucideIcons.star, color: Colors.blue), label: 'Status'),
            NavigationDestination(icon: Icon(LucideIcons.user), selectedIcon: Icon(LucideIcons.user, color: Colors.blue), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _loadDataFromServer();
  }

  Future<void> _loadDataFromServer() async {
    await Data.fetchData(); 
    if (mounted) { setState(() { isLoading = false; }); }
  }

  // MODAL UPDATE PROGRESS
  void _showUpdateModal(BuildContext context, Map<String, dynamic> book) {
    TextEditingController pageController = TextEditingController(text: book['current_page'].toString());
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), backgroundColor: Colors.white, builder: (context) {
        return Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))), const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Update Progress", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)), Text("${book['total_pages']} Pages", style: GoogleFonts.poppins(color: Colors.grey[500]))]), const SizedBox(height: 24),
              Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: book['cover'], width: 60, height: 90, fit: BoxFit.cover, errorWidget: (context, url, error) => const Icon(Icons.book, color: Colors.grey))), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(book['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text("Halaman saat ini", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])), Row(children: [SizedBox(width: 80, child: TextField(controller: pageController, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]), decoration: const InputDecoration(border: InputBorder.none, isDense: true))), Text("/ ${book['total_pages']}", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]))]), Container(height: 2, color: Colors.blue[100])]))]), const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { int? newPage = int.tryParse(pageController.text); if (newPage != null && newPage <= book['total_pages']) { Navigator.pop(context); bool success = await Data.updateProgress(book['id'], newPage); if (success) { showTopSnackBar("Progress berhasil diupdate!"); } else { showTopSnackBar("Gagal konek ke server", color: Colors.red); }}}, style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Update", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 12), Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey[600]))))
            ]));
      });
  }

  // MODAL MENU OPSI
  void _showBookOptions(BuildContext context, Map<String, dynamic> book) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) {
        return Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Atur Buku: ${book['title']}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 20),
              Text("Ganti Status Baca", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatusButton(context, book, "Wishlist", "wishlist", LucideIcons.bookmark, Colors.orange), _buildStatusButton(context, book, "Reading", "reading", LucideIcons.bookOpen, Colors.blue), _buildStatusButton(context, book, "Finished", "completed", LucideIcons.checkCircle, Colors.green)]), const SizedBox(height: 24),
              Text("Pindah Rak (Genre)", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8),
              Data.shelfOptions.isEmpty ? const Text("Belum ada rak.", style: TextStyle(color: Colors.red, fontSize: 12)) : Wrap(spacing: 8, runSpacing: 8, children: Data.shelfOptions.map((shelf) => _buildShelfChip(context, book, shelf)).toList()), const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () { showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Hapus Buku?"), content: const Text("Buku ini akan dihapus permanen."), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")), TextButton(onPressed: () async { Navigator.pop(ctx); Navigator.pop(context); bool success = await Data.deleteBook(book['id']); if(success) { showTopSnackBar("Buku berhasil dihapus", color: Colors.red); }}, child: const Text("Hapus", style: TextStyle(color: Colors.red)))])); }, icon: const Icon(LucideIcons.trash2, color: Colors.red), label: Text("Hapus Buku Ini", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))
            ])));
      });
  }
  Widget _buildStatusButton(BuildContext context, Map book, String label, String statusKey, IconData icon, Color color) { bool isSelected = book['status'] == statusKey; return GestureDetector(onTap: () async { Navigator.pop(context); if (!isSelected) { await Data.changeBookStatus(book['id'], statusKey); showTopSnackBar("Status diperbarui menjadi $label"); } }, child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isSelected ? color : color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: isSelected ? Colors.white : color)), const SizedBox(height: 4), Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])); }
  Widget _buildShelfChip(BuildContext context, Map book, String shelfName) { bool isSelected = book['shelf'] == shelfName; return ActionChip(label: Text(shelfName), backgroundColor: isSelected ? Colors.black87 : Colors.grey[100], labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black), onPressed: () async { Navigator.pop(context); if (!isSelected) { await Data.changeBookShelf(book['id'], shelfName); showTopSnackBar("Dipindah ke rak $shelfName"); }}); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading 
      ? const Center(child: CircularProgressIndicator()) 
      : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(24.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Hi, Reader! 👋", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])), Text("Mau baca apa hari ini?", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]))])),
            
            // --- CAROUSEL REAKTIF (SLIDER) ---
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: Data.readingListNotifier, // Mendengarkan perubahan data reading
              builder: (context, readingList, _) {
                if (readingList.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: Text("Sedang Dibaca (${readingList.length})", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]))),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180, 
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: readingList.length,
                        itemBuilder: (context, index) {
                          final book = readingList[index];
                          return GestureDetector(
                            onTap: () => _showUpdateModal(context, book),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4338CA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: book['cover'], 
                                      width: 80, height: 110, fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => const Icon(Icons.book, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(book['title'],
                                            maxLines: 2, overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                        Text(book['author'],
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue[100])),
                                        const SizedBox(height: 12),
                                        LinearPercentIndicator(
                                          padding: EdgeInsets.zero, lineHeight: 6.0, 
                                          percent: book['progress'] ?? 0.0, 
                                          backgroundColor: Colors.blue[900]!.withOpacity(0.3), progressColor: Colors.blue[200], barRadius: const Radius.circular(10),
                                        ),
                                        const SizedBox(height: 4),
                                        Align(alignment: Alignment.centerRight, child: Text("${((book['progress'] ?? 0.0) * 100).toInt()}% Selesai", style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue[100]))),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }
            ),
            
            // --- GRID KOLEKSI REAKTIF ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Koleksi Buku", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: Icon(LucideIcons.search, size: 18, color: Colors.grey[600]))]),
                  const SizedBox(height: 16),
                  
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: Data.bookListNotifier,
                    builder: (context, bookList, _) {
                      if (bookList.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Belum ada koleksi buku")));
                      }
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
                        itemCount: bookList.length, 
                        itemBuilder: (context, index) {
                          final book = bookList[index]; 
                          return GestureDetector(
                            onTap: () => _showBookOptions(context, book),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: book['cover'], width: double.infinity, fit: BoxFit.cover, placeholder: (context, url) => Container(color: Colors.grey[200]), errorWidget: (context, url, error) => const Icon(Icons.broken_image))), Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: book['status'] == 'reading' ? Colors.blue : (book['status'] == 'completed' ? Colors.green : Colors.orange), borderRadius: BorderRadius.circular(12)), child: Icon(book['status'] == 'reading' ? LucideIcons.bookOpen : (book['status'] == 'completed' ? LucideIcons.check : LucideIcons.bookmark), size: 12, color: Colors.white)))])),
                                  const SizedBox(height: 8),
                                  Text(book['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800])),
                                  Text(book['author'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
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

// --- ADD BOOK MODAL ---
class AddBookModal extends StatefulWidget {
  const AddBookModal({super.key});
  @override
  State<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends State<AddBookModal> {
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  String _coverUrl = ""; File? _imageFile; bool _isLoading = false; bool _isManual = false; String? _selectedShelf; final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async { try { final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery); if (pickedFile != null) setState(() { _imageFile = File(pickedFile.path); }); } catch (e) { showTopSnackBar("Gagal buka galeri: $e", color: Colors.red); } }
  Future<void> _searchIsbn() async { if (_isbnController.text.isEmpty) return; setState(() => _isLoading = true); final bookData = await Data.searchBookByIsbn(_isbnController.text); setState(() => _isLoading = false); if (bookData != null) { _titleController.text = bookData['title']; _authorController.text = bookData['author']; _pagesController.text = bookData['total_pages'].toString(); setState(() { _coverUrl = bookData['cover_url']; _isManual = true; _selectedShelf = Data.shelfOptions.isNotEmpty ? Data.shelfOptions[0] : null; }); showTopSnackBar("Buku Ditemukan!"); } else { showTopSnackBar("Buku tidak ditemukan", color: Colors.red); } }
  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    String result = await Data.addBook({ 'isbn': _isbnController.text, 'title': _titleController.text, 'author': _authorController.text, 'cover_url': _coverUrl.isEmpty ? "" : _coverUrl, 'total_pages': int.tryParse(_pagesController.text) ?? 100, 'shelf': _selectedShelf ?? 'Uncategorized' }, imageFile: _imageFile);
    if (mounted) {
      setState(() => _isLoading = false);
      if (result == "success") { Navigator.pop(context); showTopSnackBar("Buku Berhasil Disimpan!", color: Colors.green); } 
      else { showErrorDialog(context, result); }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))), const SizedBox(height: 24),
          Text(_isManual ? "Simpan Buku" : "Scan / Input ISBN", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])), const SizedBox(height: 24),
          if (!_isManual) ...[
             TextField(controller: _isbnController, decoration: InputDecoration(labelText: "Masukkan ISBN Buku", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _searchIsbn)), keyboardType: TextInputType.number),
             const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isLoading ? null : _searchIsbn, icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(LucideIcons.scanLine, color: Colors.white), label: Text(_isLoading ? "Mencari..." : "Cari Data Buku", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
             const SizedBox(height: 12), Center(child: TextButton(onPressed: () => setState(() { _isManual = true; _selectedShelf = Data.shelfOptions.isNotEmpty ? Data.shelfOptions[0] : null; }), child: const Text("Input Manual Saja")))
          ] else ...[
             Row(children: [GestureDetector(onTap: _pickImage, child: Container(width: 80, height: 120, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : (_coverUrl.isNotEmpty ? DecorationImage(image: NetworkImage(_coverUrl), fit: BoxFit.cover) : null)), child: (_imageFile == null && _coverUrl.isEmpty) ? const Icon(Icons.add_a_photo, color: Colors.grey) : null)), const SizedBox(width: 16), Expanded(child: Column(children: [
                       TextField(controller: _isbnController, decoration: const InputDecoration(labelText: "ISBN", isDense: true), keyboardType: TextInputType.number),
                       TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Buku", isDense: true)), TextField(controller: _authorController, decoration: const InputDecoration(labelText: "Penulis", isDense: true)), TextField(controller: _pagesController, decoration: const InputDecoration(labelText: "Total Halaman", isDense: true), keyboardType: TextInputType.number)]))]), const SizedBox(height: 16),
             Data.shelfOptions.isEmpty ? const Text("Belum ada rak.", style: TextStyle(color: Colors.red)) : DropdownButtonFormField<String>(value: _selectedShelf, decoration: const InputDecoration(labelText: "Pilih Rak", isDense: true, border: OutlineInputBorder()), items: Data.shelfOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: GoogleFonts.poppins()))).toList(), onChanged: (newValue) => setState(() => _selectedShelf = newValue)), const SizedBox(height: 24),
             SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _saveBook, style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text("Simpan ke Rak", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white))))
          ]
        ]));
  }
}