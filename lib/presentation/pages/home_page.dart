import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/home_card.dart';
import 'chat/chat_page.dart';
import 'iot/medicine_control_page.dart';
import 'medicine/medicine_scan_page.dart';
import 'prescription/prescription_scan_page.dart';
import 'schedule/schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Medicine App'),
          elevation: 2,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthCubit>().logout();
                    } else if (value == 'profile' &&
                        state is AuthAuthenticated) {
                      _showUserProfile(context, state.user);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 12),
                          Text('Hồ sơ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 12),
                          Text('Đăng xuất'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(),
                const SizedBox(height: 28),
                Text(
                  'Chức năng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                HomeCard(
                  icon: Icons.barcode_reader,
                  title: 'Xem thuốc',
                  description: 'Xem danh sách thuốc',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MedicineScanPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                HomeCard(
                  icon: Icons.receipt_long,
                  title: 'Xem đơn Thuốc',
                  description: 'Xem danh sách đơn thuốc',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrescriptionScanPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                HomeCard(
                  icon: Icons.schedule,
                  title: 'Lịch Uống Thuốc',
                  description: 'Quản lý lịch trình uống thuốc hàng ngày',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SchedulePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                HomeCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat AI',
                  description: 'Tư vấn y tế với trợ lý AI',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                HomeCard(
                  icon: Icons.wifi_tethering,
                  title: 'Điều khiển thuốc (MQTT)',
                  description: 'Gửi số lượng thuốc lên thiết bị IoT',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MedicineControlPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Quản lý thuốc của bạn một cách thông minh và hiệu quả',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhấn back lần nữa để thoát ứng dụng'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // không thoát app
    }
    return true; // thoát app
  }

  void _showUserProfile(BuildContext context, dynamic user) {
    final createdAtFormatted = user.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt)
        : "-";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hồ sơ người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField('ID', user.id),
            _buildProfileField('Số điện thoại', user.phone),
            _buildProfileField('Tạo ngày', createdAtFormatted),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(value),
        ],
      ),
    );
  }
}
