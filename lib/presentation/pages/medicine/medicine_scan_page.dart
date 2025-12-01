// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../../cubits/medicine_cubit.dart';
// import '../../cubits/medicine_scan_cubit.dart';
// import '../../cubits/medicine_scan_state.dart';
// import '../../widgets/medicine_list_item.dart';
// import 'medicine_detail_page.dart';
//
// class MedicineScanPage extends StatefulWidget {
//   const MedicineScanPage({Key? key}) : super(key: key);
//
//   @override
//   State<MedicineScanPage> createState() => _MedicineScanPageState();
// }
//
// class _MedicineScanPageState extends State<MedicineScanPage> {
//   late TextEditingController _searchController;
//   late ScrollController _scrollController;
//   bool _isSearching = false;
//
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
//     _scrollController = ScrollController();
//
//     // Load initial data
//     Future.microtask(
//       () => context.read<MedicineCubit>().getMedicineList(isRefresh: true),
//     );
//
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       if (!_isSearching) {
//         context.read<MedicineCubit>().getMedicineList();
//       }
//     }
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }
//
//   void _onSearchChanged(String query) {
//     if (query.isEmpty) {
//       setState(() => _isSearching = false);
//       context.read<MedicineCubit>().getMedicineList(isRefresh: true);
//     } else {
//       setState(() => _isSearching = true);
//       context.read<MedicineCubit>().searchMedicineByName(query);
//     }
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? xFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1600,
//         imageQuality: 90,
//       );
//
//       if (xFile == null) return;
//
//       final file = File(xFile.path);
//       context.read<MedicineScanCubit>().scanFromImage(file);
//     } catch (e) {
//       _showSnackBar('Không thể chọn ảnh. Vui lòng thử lại.');
//     }
//   }
//
//   void _showImageSourceSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 8),
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Chọn nguồn ảnh',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Chụp từ camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Chọn từ thư viện'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// Parse chuỗi kiểu:
//   /// "{'Tên thuốc': 'Cotrimoxazol', 'Số lượng viên': 10, 'Thành phần chính': [...]}"
//   /// -> Map<String, dynamic>?
//   Map<String, dynamic>? _parseOcrResponse(String raw) {
//     final trimmed = raw.trim();
//     if (trimmed.isEmpty) return null;
//
//     // 1. Thử parse trực tiếp (phòng khi backend sau này trả JSON chuẩn)
//     try {
//       final decoded = jsonDecode(trimmed);
//       if (decoded is Map<String, dynamic>) return decoded;
//     } catch (_) {
//       // ignore
//     }
//
//     // 2. Backend hiện tại dùng dấu nháy đơn, convert ' -> "
//     try {
//       final normalized = trimmed.replaceAll("'", '"');
//       final decoded = jsonDecode(normalized);
//       if (decoded is Map<String, dynamic>) return decoded;
//     } catch (_) {
//       // ignore
//     }
//
//     return null;
//   }
//
//   void _showOcrDetailDialog(String raw) {
//     final data = _parseOcrResponse(raw);
//
//     String? tenThuoc;
//     int? soLuongVien;
//     List<Map<String, String>> thanhPhan = [];
//
//     if (data != null) {
//       tenThuoc = data['Tên thuốc']?.toString();
//
//       final dynamic sl = data['Số lượng viên'];
//       if (sl is num) {
//         soLuongVien = sl.toInt();
//       } else if (sl is String) {
//         soLuongVien = int.tryParse(sl);
//       }
//
//       final dynamic list = data['Thành phần chính'];
//       if (list is List) {
//         thanhPhan = list.whereType<Map>().map((e) {
//           final map = Map<String, dynamic>.from(e);
//           return {
//             'name': (map['Thành phần'] ?? '').toString(),
//             'dosage': (map['Hàm lượng'] ?? '').toString(),
//           };
//         }).toList();
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Kết quả nhận diện'),
//         content: SingleChildScrollView(
//           child: data == null
//               ? Text(raw)
//               : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (tenThuoc != null && tenThuoc.isNotEmpty) ...[
//                       const Text(
//                         'Tên thuốc',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text(tenThuoc),
//                       const SizedBox(height: 8),
//                     ],
//                     if (soLuongVien != null) ...[
//                       const Text(
//                         'Số lượng viên',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text('$soLuongVien viên'),
//                       const SizedBox(height: 8),
//                     ],
//                     if (thanhPhan.isNotEmpty) ...[
//                       const Text(
//                         'Thành phần chính',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(height: 4),
//                       ...thanhPhan.map(
//                         (tp) {
//                           final label =
//                               tp['name']!.isNotEmpty ? '${tp['name']}: ' : '';
//                           return Text('- $label${tp['dosage']}');
//                         },
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                     if ((tenThuoc == null || tenThuoc.isEmpty) &&
//                         soLuongVien == null &&
//                         thanhPhan.isEmpty) ...[
//                       const Text(
//                         'Dữ liệu gốc',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(raw),
//                     ],
//                   ],
//                 ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Quản lý Thuốc'),
//         backgroundColor: AppColors.secondary,
//         foregroundColor: AppColors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // TextField tìm kiếm
//             TextField(
//               controller: _searchController,
//               onChanged: _onSearchChanged,
//               decoration: InputDecoration(
//                 hintText: 'Tìm kiếm thuốc hoặc mã vạch...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _onSearchChanged('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // Nút mở camera / gallery
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _showImageSourceSheet,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Quét từ ảnh'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.secondary,
//                       minimumSize: const Size(double.infinity, 50),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Hiển thị trạng thái nhận diện ảnh
//             BlocBuilder<MedicineScanCubit, MedicineScanState>(
//               builder: (context, state) {
//                 if (state is MedicineScanLoading) {
//                   return const LinearProgressIndicator();
//                 }
//
//                 if (state is MedicineScanSuccess) {
//                   final raw = state.result.rawResponse;
//                   final data = _parseOcrResponse(raw);
//
//                   String? tenThuoc;
//                   int? soLuongVien;
//                   List<Map<String, String>> thanhPhan = [];
//
//                   if (data != null) {
//                     tenThuoc = data['Tên thuốc']?.toString();
//
//                     final dynamic sl = data['Số lượng viên'];
//                     if (sl is num) {
//                       soLuongVien = sl.toInt();
//                     } else if (sl is String) {
//                       soLuongVien = int.tryParse(sl);
//                     }
//
//                     final dynamic list = data['Thành phần chính'];
//                     if (list is List) {
//                       thanhPhan = list.whereType<Map>().map((e) {
//                         final map = Map<String, dynamic>.from(e);
//                         return {
//                           'name': (map['Thành phần'] ?? '').toString(),
//                           'dosage': (map['Hàm lượng'] ?? '').toString(),
//                         };
//                       }).toList();
//                     }
//                   }
//
//                   final subtitleWidgets = <Widget>[];
//
//                   if (data == null) {
//                     subtitleWidgets.add(
//                       Text(
//                         raw,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   } else {
//                     if (tenThuoc != null && tenThuoc.isNotEmpty) {
//                       subtitleWidgets.add(
//                         Text(
//                           'Tên thuốc: $tenThuoc',
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       );
//                     }
//                     if (soLuongVien != null) {
//                       subtitleWidgets.add(
//                         Text('Số lượng viên: $soLuongVien'),
//                       );
//                     }
//                     if (thanhPhan.isNotEmpty) {
//                       subtitleWidgets.add(const SizedBox(height: 4));
//                       subtitleWidgets.add(
//                         const Text(
//                           'Thành phần chính:',
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       );
//                       for (final tp in thanhPhan) {
//                         final label =
//                             tp['name']!.isNotEmpty ? '${tp['name']}: ' : '';
//                         subtitleWidgets.add(
//                           Text('- $label${tp['dosage']}'),
//                         );
//                       }
//                     }
//                     if (subtitleWidgets.isEmpty) {
//                       subtitleWidgets.add(
//                         Text(
//                           raw,
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }
//                   }
//
//                   return Card(
//                     elevation: 0,
//                     color: Colors.green[50],
//                     child: ListTile(
//                       leading:
//                           const Icon(Icons.check_circle, color: Colors.green),
//                       title: const Text(
//                         'Đã nhận diện thuốc',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: subtitleWidgets,
//                       ),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.info_outline),
//                         onPressed: () => _showOcrDetailDialog(raw),
//                       ),
//                     ),
//                   );
//                 }
//
//                 if (state is MedicineScanFailure) {
//                   return Card(
//                     elevation: 0,
//                     color: Colors.red[50],
//                     child: ListTile(
//                       leading: const Icon(Icons.error, color: Colors.red),
//                       title: const Text(
//                         'Nhận diện thất bại',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       subtitle: Text(state.message),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.refresh),
//                         onPressed: _showImageSourceSheet,
//                       ),
//                     ),
//                   );
//                 }
//
//                 return const SizedBox.shrink();
//               },
//             ),
//             const SizedBox(height: 8),
//
//             // Danh sách thuốc + RefreshIndicator
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   // Nếu đang tìm kiếm → refresh lại kết quả tìm kiếm
//                   if (_isSearching && _searchController.text.isNotEmpty) {
//                     context
//                         .read<MedicineCubit>()
//                         .searchMedicineByName(_searchController.text);
//                   } else {
//                     // Nếu không tìm kiếm → refresh danh sách gốc
//                     context
//                         .read<MedicineCubit>()
//                         .getMedicineList(isRefresh: true);
//                   }
//                 },
//                 child: BlocBuilder<MedicineCubit, MedicineState>(
//                   builder: (context, state) {
//                     // 1. Đang loading lần đầu
//                     if (state is MedicineLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     // 2. Có dữ liệu
//                     if (state is MedicineListLoaded) {
//                       final medicines = state.medicines;
//
//                       // Nếu danh sách rỗng → vẫn cần widget scroll được
//                       if (medicines.isEmpty) {
//                         return LayoutBuilder(
//                           builder: (context, constraints) {
//                             return SingleChildScrollView(
//                               physics: const AlwaysScrollableScrollPhysics(),
//                               child: ConstrainedBox(
//                                 constraints: BoxConstraints(
//                                   minHeight: constraints.maxHeight,
//                                 ),
//                                 child: const Center(
//                                   child: Text('Không có dữ liệu'),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }
//
//                       return ListView.builder(
//                         controller: _scrollController,
//                         physics:
//                             const AlwaysScrollableScrollPhysics(), // để refresh khi danh sách ngắn
//                         itemCount: medicines.length,
//                         itemBuilder: (context, index) {
//                           // Load more khi scroll gần cuối (chỉ khi KHÔNG đang tìm kiếm)
//                           if (index == medicines.length - 1 && !_isSearching) {
//                             context.read<MedicineCubit>().getMedicineList();
//                           }
//
//                           return MedicineListItem(
//                             medicine: medicines[index],
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => MedicineDetailPage(
//                                     id: medicines[index].id,
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       );
//                     }
//
//                     // 3. Lỗi
//                     if (state is MedicineError) {
//                       return LayoutBuilder(
//                         builder: (context, constraints) {
//                           return SingleChildScrollView(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             child: ConstrainedBox(
//                               constraints: BoxConstraints(
//                                 minHeight: constraints.maxHeight,
//                               ),
//                               child: const Center(
//                                 child: Text("Lỗi lấy danh sách thuốc"),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     }
//
//                     // Trường hợp mặc định
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

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
import '../../../data/models/medicine_ocr_result.dart';

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

    _searchController.addListener(() {
      final text = _searchController.text;
      if (text.isEmpty && _isSearching) {
        setState(() => _isSearching = false);
        context.read<MedicineCubit>().getMedicineList(isRefresh: true);
      }
    });
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
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _isSearching = false);
      context.read<MedicineCubit>().getMedicineList(isRefresh: true);
    } else {
      setState(() => _isSearching = true);
      context.read<MedicineCubit>().searchMedicineByName(trimmed);
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
    } catch (_) {
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
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Chụp từ camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanErrorCard(String message) {
    return Card(
      key: const ValueKey('scan-error'),
      elevation: 0,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red.withOpacity(0.08),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhận diện thất bại',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _showImageSourceSheet,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOcrDetailDialog(MedicineOcrResult result) {
    Widget content;

    switch (result.loaiDuLieu) {
      case OcrDataType.viThuoc:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((result.tenThuoc ?? '').isNotEmpty) ...[
              const Text(
                'Tên thuốc',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.tenThuoc!),
              const SizedBox(height: 8),
            ],
            if (result.soLuongVien != null) ...[
              const Text(
                'Số lượng viên',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('${result.soLuongVien} viên'),
              const SizedBox(height: 8),
            ],
            if (result.thanhPhan.isNotEmpty) ...[
              const Text(
                'Thành phần chính',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...result.thanhPhan.map(
                (tp) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('- ${tp.ten}: ${tp.hamLuong}'),
                ),
              ),
            ],
          ],
        );
        break;

      case OcrDataType.donThuoc:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((result.tenBenhNhan ?? '').isNotEmpty) ...[
              const Text(
                'Tên bệnh nhân',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.tenBenhNhan!),
              const SizedBox(height: 8),
            ],
            if ((result.ngaySinh ?? '').isNotEmpty) ...[
              const Text(
                'Ngày sinh',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.ngaySinh!),
              const SizedBox(height: 8),
            ],
            if ((result.gioiTinh ?? '').isNotEmpty) ...[
              const Text(
                'Giới tính',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.gioiTinh!),
              const SizedBox(height: 8),
            ],
            if ((result.diaChi ?? '').isNotEmpty) ...[
              const Text(
                'Địa chỉ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.diaChi!),
              const SizedBox(height: 8),
            ],
            if ((result.chanDoan ?? '').isNotEmpty) ...[
              const Text(
                'Chẩn đoán',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.chanDoan!),
              const SizedBox(height: 8),
            ],
            if (result.danhSachThuoc.isNotEmpty) ...[
              const Text(
                'Danh sách thuốc',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...result.danhSachThuoc.map((d) {
                final parts = <String>[];
                if (d.sang.isNotEmpty) parts.add('Sáng: ${d.sang}');
                if (d.trua.isNotEmpty) parts.add('Trưa: ${d.trua}');
                if (d.toi.isNotEmpty) parts.add('Tối: ${d.toi}');
                final lieuDung = parts.join(' | ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '- ${d.tenThuoc} (${d.soLuong})'
                    '${lieuDung.isNotEmpty ? ' – $lieuDung' : ''}',
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
            if ((result.bacSi ?? '').isNotEmpty) ...[
              const Text(
                'Bác sĩ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.bacSi!),
              const SizedBox(height: 8),
            ],
            if ((result.benhVien ?? '').isNotEmpty) ...[
              const Text(
                'Bệnh viện',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(result.benhVien!),
            ],
          ],
        );
        break;

      case OcrDataType.unknown:
        content = Text(result.rawJson.toString());
        break;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kết quả nhận diện'),
        content: SingleChildScrollView(child: content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrResultCard(MedicineOcrResult result) {
    final subtitleWidgets = <Widget>[];

    Color bgColor;
    Color accentColor;
    IconData icon;
    String title;
    String chipLabel;

    switch (result.loaiDuLieu) {
      case OcrDataType.viThuoc:
        bgColor = Colors.green[50]!;
        accentColor = Colors.green.shade700;
        icon = Icons.medication_outlined;
        title = 'Đã nhận diện vỉ thuốc';
        chipLabel = 'VỈ THUỐC';

        if ((result.tenThuoc ?? '').isNotEmpty) {
          subtitleWidgets.add(
            Text(
              'Tên thuốc: ${result.tenThuoc}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        }

        if (result.soLuongVien != null) {
          subtitleWidgets.add(
            Text(
              'Số lượng viên: ${result.soLuongVien}',
              style: const TextStyle(fontSize: 13),
            ),
          );
        }

        if (result.thanhPhan.isNotEmpty) {
          subtitleWidgets.add(const SizedBox(height: 4));
          subtitleWidgets.add(
            const Text(
              'Thành phần chính:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          );
          for (final tp in result.thanhPhan) {
            subtitleWidgets.add(
              Text(
                '- ${tp.ten}: ${tp.hamLuong}',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }
        }
        break;

      case OcrDataType.donThuoc:
        bgColor = Colors.blue[50]!;
        accentColor = Colors.blue.shade700;
        icon = Icons.receipt_long;
        title = 'Đã nhận diện đơn thuốc';
        chipLabel = 'ĐƠN THUỐC';

        if ((result.tenBenhNhan ?? '').isNotEmpty) {
          subtitleWidgets.add(
            Text(
              'Bệnh nhân: ${result.tenBenhNhan}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        }

        if ((result.chanDoan ?? '').isNotEmpty) {
          subtitleWidgets.add(
            Text(
              'Chẩn đoán: ${result.chanDoan}',
              style: const TextStyle(fontSize: 13),
            ),
          );
        }

        if (result.danhSachThuoc.isNotEmpty) {
          subtitleWidgets.add(const SizedBox(height: 4));
          subtitleWidgets.add(
            const Text(
              'Một số thuốc trong đơn:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          );

          for (final d in result.danhSachThuoc.take(3)) {
            subtitleWidgets.add(
              Text(
                '- ${d.tenThuoc} (${d.soLuong})',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }

          if (result.danhSachThuoc.length > 3) {
            subtitleWidgets.add(
              Text(
                '... +${result.danhSachThuoc.length - 3} thuốc khác',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }
        }
        break;

      case OcrDataType.unknown:
        bgColor = Colors.grey[100]!;
        accentColor = Colors.grey.shade700;
        icon = Icons.info_outline;
        title = 'Dữ liệu nhận diện';
        chipLabel = 'KHÔNG RÕ';

        subtitleWidgets.add(
          Text(
            result.rawJson.toString(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        );
        break;
    }

    if (subtitleWidgets.isEmpty) {
      subtitleWidgets.add(
        Text(
          result.rawJson.toString(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      );
    }

    return Card(
      key: const ValueKey('scan-success'),
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: accentColor.withOpacity(0.08),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          chipLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                        backgroundColor: accentColor.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...subtitleWidgets,
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showOcrDetailDialog(result),
                      icon: Icon(Icons.info_outline,
                          size: 18, color: accentColor),
                      label: Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 13,
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        elevation: 0,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),

            // Nút quét từ ảnh
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceSheet,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text(
                      'Quét từ ảnh',
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Trạng thái OCR
            BlocBuilder<MedicineScanCubit, MedicineScanState>(
              builder: (context, state) {
                Widget child;

                if (state is MedicineScanLoading) {
                  child = const LinearProgressIndicator(
                    key: ValueKey('scan-loading'),
                  );
                } else if (state is MedicineScanSuccess) {
                  child = _buildOcrResultCard(state.result);
                } else if (state is MedicineScanFailure) {
                  child = _buildScanErrorCard(state.message);
                } else {
                  child = const SizedBox.shrink();
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
              },
            ),
            const SizedBox(height: 8),

            // Danh sách thuốc
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_isSearching && _searchController.text.isNotEmpty) {
                    context
                        .read<MedicineCubit>()
                        .searchMedicineByName(_searchController.text.trim());
                  } else {
                    context
                        .read<MedicineCubit>()
                        .getMedicineList(isRefresh: true);
                  }
                },
                child: BlocBuilder<MedicineCubit, MedicineState>(
                  builder: (context, state) {
                    // Loading lần đầu
                    if (state is MedicineLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Có dữ liệu
                    if (state is MedicineListLoaded) {
                      final medicines = state.medicines;

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
                                  child: Text(
                                    'Không có dữ liệu thuốc',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
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
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          // Load thêm khi tới cuối (chỉ khi không tìm kiếm)
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

                    // Lỗi
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
                                child: Text(
                                  'Lỗi lấy danh sách thuốc',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                  ),
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
