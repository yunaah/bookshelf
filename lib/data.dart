import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // <--- WAJIB ADA UNTUK NOTIFIER
import 'package:http/http.dart' as http;

class Data {
  // KHUSUS EMULATOR: 10.0.2.2
  // KALAU HP ASLI: Ganti pakai IP Laptop (misal: 192.168.1.XX)
  static const String baseUrl = "http://10.0.2.2:8000/api"; 
  
  // --- SINYAL OTOMATIS (NOTIFIER) ---
  // UI akan mendengarkan perubahan pada variabel ini
  static ValueNotifier<List<Map<String, dynamic>>> bookListNotifier = ValueNotifier([]);
  static ValueNotifier<List<Map<String, dynamic>>> readingListNotifier = ValueNotifier([]);

  // Data Penampung
  static List<Map<String, dynamic>> readingList = [];
  static List<Map<String, dynamic>> homeBookList = [];
  static Map<DateTime, String> readingHistory = {};
  static List<Map<String, dynamic>> historyList = [];
  static List<String> shelfOptions = []; 
  
  // Data Legacy (Single - Jaga jaga)
  static int readingId = 0; 
  static String readingTitle = "Tidak ada buku aktif";
  static String readingAuthor = "Pilih buku dari koleksi";
  static String readingCover = ""; 
  static int currentPage = 0;
  static int totalPage = 100;
  static double get progress => totalPage == 0 ? 0 : currentPage / totalPage;

  // 1. AMBIL SEMUA DATA DARI SERVER
  static Future<void> fetchData() async {
    try {
      print("Menghubungi server...");

      // A. FETCH BUKU
      final responseBooks = await http.get(Uri.parse('$baseUrl/books'));
      if (responseBooks.statusCode == 200) {
        final data = json.decode(responseBooks.body)['data'] as List;
        
        homeBookList.clear();
        readingList.clear(); 

        // Reset Data Legacy
        readingId = 0; readingTitle = "Tidak ada buku aktif"; readingAuthor = "Pilih buku dari koleksi"; readingCover = ""; currentPage = 0; totalPage = 100;

        if (data.isNotEmpty) {
          // Cari active book (untuk legacy/single view)
          var activeBook = data.firstWhere((book) => book['status'] == 'reading', orElse: () => null);
          if (activeBook != null) {
             readingId = activeBook['id']; readingTitle = activeBook['title']; readingAuthor = activeBook['author'];
             readingCover = activeBook['cover_url'] ?? ""; currentPage = activeBook['current_page']; totalPage = activeBook['total_pages'];
          }

          for (var item in data) {
            // Hitung progress di sini biar aman dari null error
            double progressVal = (item['total_pages'] == 0) ? 0.0 : (item['current_page'] / item['total_pages']).toDouble();

            var bookMap = {
              "id": item['id'], "title": item['title'], "author": item['author'], "shelf": item['shelf'], "status": item['status'],
              "cover": item['cover_url'] ?? "https://via.placeholder.com/150", "total_pages": item['total_pages'], "current_page": item['current_page'], "progress": progressVal,
            };
            homeBookList.add(bookMap);
            if (item['status'] == 'reading') readingList.add(bookMap);
          }
        }
        // JANGAN UPDATE SINYAL DI SINI! TUNGGU RAK & HISTORY SELESAI.
      }

      // B. FETCH HISTORY (STATUS BACAAN)
      final responseHistory = await http.get(Uri.parse('$baseUrl/history'));
      if (responseHistory.statusCode == 200) {
        final data = json.decode(responseHistory.body)['data'] as List;
        readingHistory.clear(); historyList.clear();
        for (var item in data) { 
           DateTime date = DateTime.parse(item['read_date']); 
           readingHistory[date] = item['book']['cover_url'] ?? ""; 
           historyList.add({"title": item['book']['title'], "date": item['read_date'], "pages": item['pages_read'], "cover": item['book']['cover_url'] ?? ""}); 
        }
      }

      // C. FETCH RAK (GENRE)
      final responseShelves = await http.get(Uri.parse('$baseUrl/shelves'));
      if (responseShelves.statusCode == 200) {
        final data = json.decode(responseShelves.body)['data'] as List;
        shelfOptions.clear(); 
        for (var item in data) { shelfOptions.add(item['name']); }
        print("Rak berhasil dimuat: ${shelfOptions.length}");
      }

      // --- D. UPDATE SINYAL DI SINI (GARIS FINISH) ---
      // Baru kabari UI setelah SEMUA data (Buku + History + Rak) lengkap.
      bookListNotifier.value = List.from(homeBookList);
      readingListNotifier.value = List.from(readingList);

    } catch (e) { print("Error Fetching Data: $e"); }
  }

  // --- FUNGSI CRUD LAINNYA ---
  static Future<bool> addShelf(String n) async { final r = await http.post(Uri.parse('$baseUrl/shelves'), body: {'name': n}); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  static Future<bool> changeBookStatus(int id, String s) async { final r = await http.post(Uri.parse('$baseUrl/books/$id/status'), body: {'status': s}); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  static Future<bool> changeBookShelf(int id, String s) async { final r = await http.post(Uri.parse('$baseUrl/books/$id/shelf'), body: {'shelf': s}); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  static Future<bool> updateProgress(int id, int p) async { final r = await http.post(Uri.parse('$baseUrl/books/$id/progress'), body: {'current_page': p.toString()}); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  static Future<bool> deleteBook(int id) async { final r = await http.delete(Uri.parse('$baseUrl/books/$id')); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  static Future<bool> deleteShelf(String s) async { final r = await http.post(Uri.parse('$baseUrl/shelves/delete-by-name'), body: {'name': s}); if (r.statusCode==200) { await fetchData(); return true;} return false; }
  
  static Future<Map<String, dynamic>?> searchBookByIsbn(String isbn) async {
      try { final r = await http.get(Uri.parse("https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn")); if (r.statusCode == 200) { final d = json.decode(r.body); if (d['totalItems'] > 0) { final i = d['items'][0]['volumeInfo']; String c = "https://via.placeholder.com/150"; if (i['imageLinks'] != null) { c = i['imageLinks']['thumbnail'] ?? i['imageLinks']['smallThumbnail']; c = c.replaceAll('http://', 'https://'); } return { 'title': i['title'], 'author': i['authors']!=null?i['authors'][0]:'Unknown', 'cover_url': c, 'total_pages': i['pageCount']??200, 'shelf': 'Uncategorized' }; } } } catch (e) { print(e); } return null;
  }

  // Tambah Buku dengan Return Message (String) untuk Error Handling
  static Future<String> addBook(Map<String, dynamic> d, {File? imageFile}) async {
    try {
      var req = http.MultipartRequest('POST', Uri.parse('$baseUrl/books'));
      req.fields.addAll(d.map((k, v) => MapEntry(k, v.toString())));
      if (imageFile != null) req.files.add(await http.MultipartFile.fromPath("image", imageFile.path));
      
      var res = await req.send();
      var body = await res.stream.bytesToString(); 
      
      if (res.statusCode == 200 || res.statusCode == 201) { 
        await fetchData(); 
        return "success"; 
      } else if (res.statusCode == 422) { 
        var err = json.decode(body); 
        if (err['errors']?['isbn'] != null) return "ISBN sudah ada!"; 
        return "Data tidak valid"; 
      } 
      return "Gagal: ${res.statusCode}";
    } catch (e) { return "Koneksi error: $e"; }
  }
}