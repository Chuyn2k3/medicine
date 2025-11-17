import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../cubits/medicine_cubit.dart';
import '../widgets/medicine_detail_card.dart';
import '../widgets/medicine_list_item.dart';
import 'medicine_list_page.dart';

class MedicineScanPage extends StatefulWidget {
  const MedicineScanPage({Key? key}) : super(key: key);

  @override
  State<MedicineScanPage> createState() => _MedicineScanPageState();
}

class _MedicineScanPageState extends State<MedicineScanPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  String _scannedBarcode = '';
  bool _showScanner = false;
  List<String> _scannedBarcodes = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

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

  void _handleBarcodeDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first.rawValue;
      if (barcode != null && !_scannedBarcodes.contains(barcode)) {
        setState(() {
          _scannedBarcodes.add(barcode);
          _scannedBarcode = barcode;
        });
        //context.read<MedicineCubit>().getMedicineByBarcode(barcode);
        _showSnackBar('Đã quét: $barcode');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _closeScanner() {
    setState(() => _showScanner = false);
  }

  void _manualSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập mã vạch hoặc tên thuốc'),
        content: TextField(
          controller: _searchController,
          decoration:
              const InputDecoration(hintText: 'Ví dụ: Paracetamol 500mg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_searchController.text.isNotEmpty) {
                final query = _searchController.text;
                setState(() => _isSearching = true);
                context.read<MedicineCubit>().searchMedicineByName(query);
                _searchController.clear();
              }
            },
            child: const Text('Tìm'),
          ),
        ],
      ),
    );
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
            icon: const Icon(Icons.close),
            onPressed: _closeScanner,
          ),
        ),
        body: MobileScanner(
          onDetect: _handleBarcodeDetect,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Thuốc'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _manualSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Tìm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      minimumSize: const Size(120, 50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicineListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Xem Danh Sách'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 20),
              if (_scannedBarcodes.isNotEmpty) ...[
                Text(
                  'Đã quét gần đây',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _scannedBarcodes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_scannedBarcodes[index]),
                          onDeleted: () {
                            setState(() {
                              _scannedBarcodes.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_scannedBarcode.isNotEmpty)
                BlocBuilder<MedicineCubit, MedicineState>(
                  builder: (context, state) {
                    if (state is MedicineLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is MedicineDetailLoaded) {
                      return MedicineDetailCard(medicine: state.medicine);
                    }
                    if (state is MedicineError) {
                      return Center(
                        child: Text(
                          'Lỗi: ${state.message}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh sách thuốc gần đây',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<MedicineCubit, MedicineState>(
                      builder: (context, state) {
                        if (state is MedicineLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is MedicineListLoaded) {
                          final medicines = state.medicines;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                medicines.length > 5 ? 5 : medicines.length,
                            itemBuilder: (context, index) {
                              return MedicineListItem(
                                medicine: medicines[index],
                                onTap: () {
                                  context
                                      .read<MedicineCubit>()
                                      .getMedicineById(medicines[index].id);
                                  setState(() =>
                                      _scannedBarcode = medicines[index].id);
                                },
                              );
                            },
                          );
                        }
                        if (state is MedicineError) {
                          return Center(
                            child: Text('Lỗi: ${state.message}'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
            ],
          ),
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
