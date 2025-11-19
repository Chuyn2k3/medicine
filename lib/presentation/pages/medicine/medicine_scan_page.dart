import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../cubits/medicine_cubit.dart';
import '../../cubits/medicine_scan_cubit.dart';
import '../../cubits/medicine_scan_state.dart';
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
  bool _isSearching = false;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 90,
      );

      if (xFile == null) return;

      final file = File(xFile.path);
      context.read<MedicineScanCubit>().scanFromImage(file);
    } catch (e) {
      _showSnackBar('Không thể chọn ảnh. Vui lòng thử lại.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chọn nguồn ảnh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp từ camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Parse chuỗi kiểu:
  /// "{'Tên thuốc': 'Cotrimoxazol', 'Số lượng viên': 10, 'Thành phần chính': [...]}"
  /// -> Map<String, dynamic>?
  Map<String, dynamic>? _parseOcrResponse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // 1. Thử parse trực tiếp (phòng khi backend sau này trả JSON chuẩn)
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // ignore
    }

    // 2. Backend hiện tại dùng dấu nháy đơn, convert ' -> "
    try {
      final normalized = trimmed.replaceAll("'", '"');
      final decoded = jsonDecode(normalized);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // ignore
    }

    return null;
  }

  void _showOcrDetailDialog(String raw) {
    final data = _parseOcrResponse(raw);

    String? tenThuoc;
    int? soLuongVien;
    List<Map<String, String>> thanhPhan = [];

    if (data != null) {
      tenThuoc = data['Tên thuốc']?.toString();

      final dynamic sl = data['Số lượng viên'];
      if (sl is num) {
        soLuongVien = sl.toInt();
      } else if (sl is String) {
        soLuongVien = int.tryParse(sl);
      }

      final dynamic list = data['Thành phần chính'];
      if (list is List) {
        thanhPhan = list.whereType<Map>().map((e) {
          final map = Map<String, dynamic>.from(e);
          return {
            'name': (map['Thành phần'] ?? '').toString(),
            'dosage': (map['Hàm lượng'] ?? '').toString(),
          };
        }).toList();
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kết quả nhận diện'),
        content: SingleChildScrollView(
          child: data == null
              ? Text(raw)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tenThuoc != null && tenThuoc.isNotEmpty) ...[
                      const Text(
                        'Tên thuốc',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(tenThuoc),
                      const SizedBox(height: 8),
                    ],
                    if (soLuongVien != null) ...[
                      const Text(
                        'Số lượng viên',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('$soLuongVien viên'),
                      const SizedBox(height: 8),
                    ],
                    if (thanhPhan.isNotEmpty) ...[
                      const Text(
                        'Thành phần chính',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      ...thanhPhan.map(
                        (tp) {
                          final label =
                              tp['name']!.isNotEmpty ? '${tp['name']}: ' : '';
                          return Text('- $label${tp['dosage']}');
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    if ((tenThuoc == null || tenThuoc.isEmpty) &&
                        soLuongVien == null &&
                        thanhPhan.isEmpty) ...[
                      const Text(
                        'Dữ liệu gốc',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(raw),
                    ],
                  ],
                ),
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

  @override
  Widget build(BuildContext context) {
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

            // Nút mở camera / gallery
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceSheet,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Quét từ ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hiển thị trạng thái nhận diện ảnh
            BlocBuilder<MedicineScanCubit, MedicineScanState>(
              builder: (context, state) {
                if (state is MedicineScanLoading) {
                  return const LinearProgressIndicator();
                }

                if (state is MedicineScanSuccess) {
                  final raw = state.result.rawResponse;
                  final data = _parseOcrResponse(raw);

                  String? tenThuoc;
                  int? soLuongVien;
                  List<Map<String, String>> thanhPhan = [];

                  if (data != null) {
                    tenThuoc = data['Tên thuốc']?.toString();

                    final dynamic sl = data['Số lượng viên'];
                    if (sl is num) {
                      soLuongVien = sl.toInt();
                    } else if (sl is String) {
                      soLuongVien = int.tryParse(sl);
                    }

                    final dynamic list = data['Thành phần chính'];
                    if (list is List) {
                      thanhPhan = list.whereType<Map>().map((e) {
                        final map = Map<String, dynamic>.from(e);
                        return {
                          'name': (map['Thành phần'] ?? '').toString(),
                          'dosage': (map['Hàm lượng'] ?? '').toString(),
                        };
                      }).toList();
                    }
                  }

                  final subtitleWidgets = <Widget>[];

                  if (data == null) {
                    subtitleWidgets.add(
                      Text(
                        raw,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  } else {
                    if (tenThuoc != null && tenThuoc.isNotEmpty) {
                      subtitleWidgets.add(
                        Text(
                          'Tên thuốc: $tenThuoc',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }
                    if (soLuongVien != null) {
                      subtitleWidgets.add(
                        Text('Số lượng viên: $soLuongVien'),
                      );
                    }
                    if (thanhPhan.isNotEmpty) {
                      subtitleWidgets.add(const SizedBox(height: 4));
                      subtitleWidgets.add(
                        const Text(
                          'Thành phần chính:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                      for (final tp in thanhPhan) {
                        final label =
                            tp['name']!.isNotEmpty ? '${tp['name']}: ' : '';
                        subtitleWidgets.add(
                          Text('- $label${tp['dosage']}'),
                        );
                      }
                    }
                    if (subtitleWidgets.isEmpty) {
                      subtitleWidgets.add(
                        Text(
                          raw,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                  }

                  return Card(
                    elevation: 0,
                    color: Colors.green[50],
                    child: ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text(
                        'Đã nhận diện thuốc',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: subtitleWidgets,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showOcrDetailDialog(raw),
                      ),
                    ),
                  );
                }

                if (state is MedicineScanFailure) {
                  return Card(
                    elevation: 0,
                    color: Colors.red[50],
                    child: ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: const Text(
                        'Nhận diện thất bại',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(state.message),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _showImageSourceSheet,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 8),

            // Danh sách thuốc + RefreshIndicator
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

                      // Nếu danh sách rỗng → vẫn cần widget scroll được
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
                            const AlwaysScrollableScrollPhysics(), // để refresh khi danh sách ngắn
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
