import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/presentation/pages/prescription/prescription_detail_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/prescription_cubit.dart';
import '../../widgets/prescription_list_item.dart';

class PrescriptionScanPage extends StatefulWidget {
  const PrescriptionScanPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionScanPage> createState() => _PrescriptionScanPageState();
}

class _PrescriptionScanPageState extends State<PrescriptionScanPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  bool _showScanner = false;
  bool _isSearching = false; // để biết đang search hay không

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty && _isSearching) {
        setState(() => _isSearching = false);
        context.read<PrescriptionCubit>().getPrescriptionList(isRefresh: true);
      }
    });

    // Load lần đầu
    Future.microtask(() =>
        context.read<PrescriptionCubit>().getPrescriptionList(isRefresh: true));
  }

  void _openScanner() => setState(() => _showScanner = true);
  void _closeScanner() => setState(() => _showScanner = false);

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      if (_isSearching) {
        setState(() => _isSearching = false);
        context.read<PrescriptionCubit>().getPrescriptionList(isRefresh: true);
      }
    } else {
      setState(() => _isSearching = true);
      // context.read<PrescriptionCubit>().searchPrescription(query); // giả sử cubit có hàm này
    }
  }

  void _handleQRDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final qrCode = capture.barcodes.first.rawValue;
      if (qrCode != null && qrCode.isNotEmpty) {
        _closeScanner();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrescriptionDetailPage(prescriptionId: qrCode),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quét Mã QR Đơn Thuốc'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeScanner,
          ),
        ),
        body: MobileScanner(onDetect: _handleQRDetect),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Đơn Thuốc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đơn thuốc hoặc mã QR...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 16),

            // Nút quét mã QR
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner, size: 28),
                    label: const Text('Quét Mã QR',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Danh sách + Refresh luôn hoạt động
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_isSearching && _searchController.text.isNotEmpty) {
                  } else {
                    context
                        .read<PrescriptionCubit>()
                        .getPrescriptionList(isRefresh: true);
                  }
                },
                child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
                  builder: (context, state) {
                    // Loading lần đầu
                    if (state is PrescriptionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is PrescriptionListLoaded) {
                      final items = state.prescriptions;

                      if (items.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight),
                                child: Center(
                                  child: Text(
                                    _isSearching
                                        ? 'Không tìm thấy đơn thuốc'
                                        : 'Chưa có đơn thuốc nào',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          // Load more khi gần cuối (chỉ khi không search)
                          if (index == items.length - 3 && !_isSearching) {
                            context
                                .read<PrescriptionCubit>()
                                .getPrescriptionList();
                          }

                          final prescription = items[index];
                          return PrescriptionListItem(
                            prescription: prescription,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PrescriptionDetailPage(
                                    prescriptionId: prescription.id!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    // Lỗi
                    if (state is PrescriptionError) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: const Center(
                                child: Text(
                                  "Lỗi lấy danh sách đơn thuốc",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
