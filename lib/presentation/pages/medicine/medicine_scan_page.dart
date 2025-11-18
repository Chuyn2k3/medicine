// medicine_scan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/medicine_cubit.dart';
import '../../widgets/medicine_list_item.dart';
import 'medicine_detail_page.dart';

class MedicineScanPage extends StatefulWidget {
  const MedicineScanPage({Key? key}) : super(key: key);

  @override
  State<MedicineScanPage> createState() => _MedicineScanPageState();
}

class _MedicineScanPageState extends State<MedicineScanPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  bool _showScanner = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    // Load initial data
    Future.microtask(
      () => context.read<MedicineCubit>().getMedicineList(isRefresh: true),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isSearching) {
        context.read<MedicineCubit>().getMedicineList();
      }
    }
  }

  void _openScanner() {
    setState(() => _showScanner = true);
  }

  void _closeScanner() {
    setState(() => _showScanner = false);
  }

  void _handleBarcodeDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first.rawValue;
      if (barcode != null) {
        _showSnackBar('Đã quét: $barcode');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineDetailPage(id: barcode),
          ),
        );
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      context.read<MedicineCubit>().getMedicineList(isRefresh: true);
    } else {
      setState(() => _isSearching = true);
      context.read<MedicineCubit>().searchMedicineByName(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quét Mã Vạch'),
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          leading: IconButton(
              icon: const Icon(Icons.close), onPressed: _closeScanner),
        ),
        body: MobileScanner(onDetect: _handleBarcodeDetect),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thuốc'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TextField tìm kiếm
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thuốc hoặc mã vạch...',
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Nút mở camera
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Quét Mã'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Danh sách thuốc + RefreshIndicator hoạt động mọi lúc
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Nếu đang tìm kiếm → refresh lại kết quả tìm kiếm
                  if (_isSearching && _searchController.text.isNotEmpty) {
                    context
                        .read<MedicineCubit>()
                        .searchMedicineByName(_searchController.text);
                  } else {
                    // Nếu không tìm kiếm → refresh danh sách gốc
                    context
                        .read<MedicineCubit>()
                        .getMedicineList(isRefresh: true);
                  }
                },
                child: BlocBuilder<MedicineCubit, MedicineState>(
                  builder: (context, state) {
                    // 1. Đang loading lần đầu
                    if (state is MedicineLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // 2. Có dữ liệu
                    if (state is MedicineListLoaded) {
                      final medicines = state.medicines;

                      // Nếu danh sách rỗng → vẫn cần một widget có thể scroll để RefreshIndicator hoạt động
                      if (medicines.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: const Center(
                                  child: Text('Không có dữ liệu'),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics:
                            const AlwaysScrollableScrollPhysics(), // quan trọng để refresh khi danh sách ngắn
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          // Load more khi scroll gần cuối (chỉ khi KHÔNG đang tìm kiếm)
                          if (index == medicines.length - 1 && !_isSearching) {
                            context.read<MedicineCubit>().getMedicineList();
                          }

                          return MedicineListItem(
                            medicine: medicines[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MedicineDetailPage(
                                    id: medicines[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    // 3. Lỗi
                    if (state is MedicineError) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: const Center(
                                child: Text("Lỗi lấy danh sách thuốc"),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    // Trường hợp mặc định
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
