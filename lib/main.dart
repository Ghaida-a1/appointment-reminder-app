import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AppointmentReminderApp());
}

// ================================================
//  MODEL
// ================================================
class Appointment {
  final String title;
  final String date;
  final String time;
  final String notes;

  Appointment({
    required this.title,
    required this.date,
    required this.time,
    required this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

// ================================================
//  APP
// ================================================
class AppointmentReminderApp extends StatelessWidget {
  const AppointmentReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD8B4FE)),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ================================================
//  COLORS
// ================================================
const Color kAccentPurple = Color(0xFFC084FC);
const Color kDarkPurple = Color(0xFF7C3AED);
const Color kDeepText = Color(0xFF4C1D95);
const Color kSubText = Color(0xFF6D28D9);
const Color kWhite = Colors.white;

const BoxDecoration kBgGradient = BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE), Color(0xFFC4B5FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

BoxDecoration get kCardDecor => BoxDecoration(
      color: kWhite.withAlpha(153),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kAccentPurple.withAlpha(100), width: 1.2),
      boxShadow: [
        BoxShadow(
            color: kAccentPurple.withAlpha(46),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ],
    );

// ================================================
//  SHARED WIDGETS
// ================================================
class PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PurpleButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
        decoration: BoxDecoration(
          color: kDarkPurple,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: kDarkPurple.withAlpha(90),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                color: kWhite,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4)),
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  const AppHeader({super.key, required this.title, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: kDeepText),
            )
          else
            const SizedBox(width: 24),
          Expanded(
            child: Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDeepText)),
          ),
          const Icon(Icons.alarm, color: kDarkPurple, size: 28),
        ],
      ),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(color: kAccentPurple.withAlpha(77), thickness: 1);
}

// ================================================
//  SCREEN 1 — Welcome
// ================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBgGradient,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kWhite.withAlpha(128),
                      border: Border.all(color: kAccentPurple, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: kDarkPurple.withAlpha(51),
                            blurRadius: 20,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child:
                        const Icon(Icons.alarm, size: 60, color: kDarkPurple),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Welcome to\nAppointment Reminder',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: kDeepText,
                        height: 1.3),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Manage your daily appointments more easily',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: kSubText.withAlpha(204),
                        height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  PurpleButton(
                    label: 'Get Started',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyAppointmentsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================
//  SCREEN 2 — My Appointments
// ================================================
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJson();
  }

  // ── تحميل JSON ──
  Future<void> _loadJson() async {
    try {
      final String data =
          await rootBundle.loadString('assets/appointments.json');
      final List<dynamic> list = jsonDecode(data);
      setState(() {
        _appointments = list.map((e) => Appointment.fromJson(e)).toList();
        _isLoading = false;
      });
      // بعد التحميل تحقق من مواعيد اليوم
      _checkTodayAppointments();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // ── تحقق من مواعيد اليوم وأرسل إشعار داخلي ──
  void _checkTodayAppointments() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final todayList = _appointments.where((a) => a.date == todayStr).toList();

    if (todayList.isNotEmpty) {
      // تأخير بسيط حتى تظهر الشاشة أولاً
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showNotificationDialog(todayList);
      });
    }
  }

  // ── نافذة الإشعار ──
  void _showNotificationDialog(List<Appointment> todayList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة الإشعار
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kDarkPurple.withAlpha(30),
                ),
                child: const Icon(Icons.notifications_active,
                    color: kDarkPurple, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                '🔔 Reminder!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kDeepText),
              ),
              const SizedBox(height: 8),
              Text(
                'You have ${todayList.length} appointment${todayList.length > 1 ? 's' : ''} today:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kSubText.withAlpha(200)),
              ),
              const SizedBox(height: 16),
              // قائمة مواعيد اليوم
              ...todayList.map((appt) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kWhite.withAlpha(180),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kAccentPurple.withAlpha(100)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: kDarkPurple, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appt.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kDeepText,
                                      fontSize: 15)),
                              Text('🕐 ${appt.time}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: kSubText.withAlpha(180))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkPurple,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('OK, Got it!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delete(int index) {
    setState(() => _appointments.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment deleted'),
        backgroundColor: kDarkPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBgGradient,
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: 'My Appointments'),
              const AppDivider(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: kDarkPurple))
                    : _appointments.isEmpty
                        ? Center(
                            child: Text(
                              'No appointments yet.\nTap + to add one!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kSubText.withAlpha(179), fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appt = _appointments[index];

                              // تحديد لون الكارد — أحمر فاتح إذا اليوم
                              final now = DateTime.now();
                              final todayStr =
                                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                              final isToday = appt.date == todayStr;

                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(38),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                                onDismissed: (_) => _delete(index),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AppointmentDetailScreen(
                                          appointment: appt),
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? const Color(0xFFFDE8FF)
                                              .withAlpha(220)
                                          : kWhite.withAlpha(153),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isToday
                                            ? kDarkPurple.withAlpha(180)
                                            : kAccentPurple.withAlpha(100),
                                        width: isToday ? 2 : 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: kAccentPurple.withAlpha(46),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? kDarkPurple.withAlpha(40)
                                                : kAccentPurple.withAlpha(51),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isToday
                                                ? Icons.notifications_active
                                                : Icons.calendar_today,
                                            color: kDarkPurple,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(appt.title,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: kDeepText)),
                                                  ),
                                                  if (isToday)
                                                    Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: kDarkPurple,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: const Text('Today',
                                                          style: TextStyle(
                                                              color: kWhite,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                  '${appt.date}  •  ${appt.time}',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: kSubText
                                                          .withAlpha(191))),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: kDarkPurple),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kDarkPurple,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
          );
          if (result != null && result is Appointment) {
            setState(() => _appointments.add(result));
          }
        },
        child: const Icon(Icons.add, color: kWhite, size: 28),
      ),
    );
  }
}

// ================================================
//  SCREEN 3 — Add Appointment
// ================================================
class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kDarkPurple.withAlpha(128)),
        filled: true,
        fillColor: kWhite.withAlpha(153),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kAccentPurple.withAlpha(128))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: kAccentPurple.withAlpha(100))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDarkPurple, width: 1.8)),
      );

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          backgroundColor: kDarkPurple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.pop(
        context,
        Appointment(
          title: _titleController.text.trim(),
          date: _dateController.text.isEmpty ? 'No date' : _dateController.text,
          time: _timeController.text.isEmpty ? 'No time' : _timeController.text,
          notes: _notesController.text.trim(),
        ));
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: kDeepText)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBgGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(title: 'Add Appointment'),
                const SizedBox(height: 24),
                _label('Title'),
                TextField(
                    controller: _titleController,
                    decoration: _fieldDecor('add text'),
                    style: const TextStyle(color: kDeepText)),
                const SizedBox(height: 18),
                _label('Date'),
                TextField(
                  controller: _dateController,
                  decoration: _fieldDecor('add text'),
                  style: const TextStyle(color: kDeepText),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                            colorScheme:
                                const ColorScheme.light(primary: kDarkPurple)),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      _dateController.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                ),
                const SizedBox(height: 18),
                _label('Time'),
                TextField(
                  controller: _timeController,
                  decoration: _fieldDecor('add text'),
                  style: const TextStyle(color: kDeepText),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                            colorScheme:
                                const ColorScheme.light(primary: kDarkPurple)),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      _timeController.text = picked.format(context);
                    }
                  },
                ),
                const SizedBox(height: 18),
                _label('Notes'),
                TextField(
                    controller: _notesController,
                    decoration: _fieldDecor('add text'),
                    style: const TextStyle(color: kDeepText),
                    maxLines: 3),
                const SizedBox(height: 36),
                Center(
                    child:
                        PurpleButton(label: 'Save Appointment', onTap: _save)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================
//  SCREEN 4 — Appointment Details
// ================================================
class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: kAccentPurple.withAlpha(46), shape: BoxShape.circle),
            child: Icon(icon, color: kDarkPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: kSubText.withAlpha(179),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '—' : value,
                    style: const TextStyle(
                        fontSize: 16,
                        color: kDeepText,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBgGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const AppHeader(title: 'Appointment Details'),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kWhite.withAlpha(140),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: kAccentPurple.withAlpha(100), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                          color: kAccentPurple.withAlpha(51),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    children: [
                      _row(Icons.title, 'Title', appointment.title),
                      const AppDivider(),
                      _row(Icons.calendar_today, 'Date', appointment.date),
                      const AppDivider(),
                      _row(Icons.access_time, 'Time', appointment.time),
                      const AppDivider(),
                      _row(Icons.note, 'Notes', appointment.notes),
                    ],
                  ),
                ),
                const Spacer(),
                PurpleButton(label: 'Ok', onTap: () => Navigator.pop(context)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
