import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../cubits/prescription_cubit.dart';
import '../widgets/prescription_detail_card.dart';
import '../widgets/prescription_list_item.dart';

class PrescriptionScanPage extends StatefulWidget {
  const PrescriptionScanPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionScanPage> createState() => _PrescriptionScanPageState();
}

class _PrescriptionScanPageState extends State<PrescriptionScanPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  String _scannedCode = '';
  bool _showScanner = false;
  List<String> _scannedCodes = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();

    Future.microtask(
      () => context
          .read<PrescriptionCubit>()
          .getPrescriptionList(isRefresh: true),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<PrescriptionCubit>().getPrescriptionList();
    }
  }

  void _openScanner() {
    setState(() => _showScanner = true);
  }

  void _handleQRDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final qrCode = capture.barcodes.first.rawValue;
      if (qrCode != null && !_scannedCodes.contains(qrCode)) {
        setState(() {
          _scannedCodes.add(qrCode);
          _scannedCode = qrCode;
        });
        // context.read<PrescriptionCubit>().getPrescriptionByCode(qrCode);
        _showSnackBar('Đã quét: $qrCode');
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
        title: const Text('Nhập mã đơn thuốc'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Ví dụ: RX001'),
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
                final code = _searchController.text;
                //context.read<PrescriptionCubit>().getPrescriptionByCode(code);
                setState(() {
                  _scannedCodes.add(code);
                  _scannedCode = code;
                });
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
          title: const Text('Quét Mã QR'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeScanner,
          ),
        ),
        body: MobileScanner(
          onDetect: _handleQRDetect,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Đơn Thuốc'),
        backgroundColor: AppColors.primary,
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
                      label: const Text('Quét Mã QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
              const SizedBox(height: 20),
              if (_scannedCodes.isNotEmpty) ...[
                Text(
                  'Đã quét gần đây',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _scannedCodes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_scannedCodes[index]),
                          onDeleted: () {
                            setState(() {
                              _scannedCodes.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_scannedCode.isNotEmpty)
                BlocBuilder<PrescriptionCubit, PrescriptionState>(
                  builder: (context, state) {
                    if (state is PrescriptionLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is PrescriptionDetailLoaded) {
                      return PrescriptionDetailCard(
                          prescription: state.prescription);
                    }
                    if (state is PrescriptionError) {
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
                      'Danh sách đơn thuốc gần đây',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<PrescriptionCubit, PrescriptionState>(
                      builder: (context, state) {
                        if (state is PrescriptionLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is PrescriptionListLoaded) {
                          final prescriptions = state.prescriptions;
                          return ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: prescriptions.length > 5
                                ? 5
                                : prescriptions.length,
                            itemBuilder: (context, index) {
                              return PrescriptionListItem(
                                prescription: prescriptions[index],
                                onTap: () {
                                  context
                                      .read<PrescriptionCubit>()
                                      .getPrescriptionById(
                                          prescriptions[index].id);
                                  setState(() =>
                                      _scannedCode = prescriptions[index].id);
                                },
                              );
                            },
                          );
                        }
                        if (state is PrescriptionError) {
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
