import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/presentation/pages/prescription_scan_page.dart';
import 'package:medical_drug/presentation/pages/schedule_page.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/auth_cubit.dart';
import '../widgets/home_card.dart';
import 'chat_page.dart';
import 'medicine_scan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine App'),
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 12),
                        Text('Hồ sơ'),
                      ],
                    ),
                    onTap: () {
                      if (state is AuthAuthenticated) {
                        _showUserProfile(context, state.user);
                      }
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 12),
                        Text('Đăng xuất'),
                      ],
                    ),
                    onTap: () {
                      context.read<AuthCubit>().logout();
                    },
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8)
                    ],
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
                      child: const Icon(Icons.favorite,
                          color: AppColors.white, size: 28),
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
              ),
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
                title: 'Scan Thuốc',
                description: 'Quét mã vạch để xem thông tin thuốc',
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
                title: 'Scan Đơn Thuốc',
                description: 'Quét đơn thuốc để xem chi tiết',
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
            ],
          ),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context, dynamic user) {
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
            _buildProfileField('Tạo ngày', user.createdAt.toString()),
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
