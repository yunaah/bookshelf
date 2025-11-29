import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart'; // Import Calendar
import 'package:cached_network_image/cached_network_image.dart';
import 'data.dart'; // Import Data untuk akses history

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
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
                    Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Center(child: Text("JD", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
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
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("${(Data.progress * 100).toInt()}%", "Progress"), // Realtime
                      Container(width: 1, height: 30, color: Colors.blue.shade400),
                      _buildStat("5", "Rak"),
                      Container(width: 1, height: 30, color: Colors.blue.shade400),
                      _buildStat("${Data.readingHistory.length}", "Hari Baca"), // Realtime
                    ],
                  ),
                )
              ],
            ),
          ),

          // --- KALENDER READING TRACKER ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reading Calendar", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.5), shape: BoxShape.circle),
                      selectedDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    ),
                    
                    // --- MAGIC NYA DI SINI (Custom Builder) ---
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        // Kita cek apakah hari ini ada di daftar history bacaan di data.dart?
                        // Kita normalisasi tanggalnya biar jam-nya gak ngaruh (cuma cek tanggal)
                        DateTime dateOnly = DateTime(day.year, day.month, day.day);
                        
                        if (Data.readingHistory.containsKey(dateOnly)) {
                          // Kalau ada, tampilkan gambar buku
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                image: DecorationImage(
                                  image: NetworkImage(Data.readingHistory[dateOnly]!), // Ambil URL cover dari map
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)]
                              ),
                              width: 30, // Ukuran cover di kalender
                              height: 45,
                            ),
                          );
                        }
                        return null; // Kalau gak ada bacaan, pakai tampilan default tanggal biasa
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Lainnya
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildMenuButton("Pengaturan"),
                const SizedBox(height: 12),
                _buildMenuButton("Tentang Aplikasi"),
                const SizedBox(height: 24),
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

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue.shade100)),
      ],
    );
  }

  Widget _buildMenuButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}