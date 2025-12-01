// medicine_ocr_result.dart

enum OcrDataType {
  viThuoc,
  donThuoc,
  unknown,
}

class OcrMedicineComponent {
  final String ten;
  final String hamLuong;

  const OcrMedicineComponent({
    required this.ten,
    required this.hamLuong,
  });
}

class OcrPrescriptionDrug {
  final String tenThuoc;
  final String soLuong;
  final String sang;
  final String trua;
  final String toi;

  const OcrPrescriptionDrug({
    required this.tenThuoc,
    required this.soLuong,
    required this.sang,
    required this.trua,
    required this.toi,
  });
}

class MedicineOcrResult {
  final OcrDataType loaiDuLieu;

  // Dữ liệu vỉ thuốc
  final String? tenThuoc;
  final int? soLuongVien;
  final List<OcrMedicineComponent> thanhPhan;

  // Dữ liệu đơn thuốc
  final String? tenBenhNhan;
  final String? ngaySinh;
  final String? gioiTinh;
  final String? diaChi;
  final String? chanDoan;
  final List<OcrPrescriptionDrug> danhSachThuoc;
  final String? bacSi;
  final String? benhVien;

  // Optional: lưu lại raw JSON nếu cần debug
  final Map<String, dynamic> rawJson;

  const MedicineOcrResult({
    required this.loaiDuLieu,
    required this.rawJson,
    // vi_thuoc
    this.tenThuoc,
    this.soLuongVien,
    this.thanhPhan = const [],
    // don_thuoc
    this.tenBenhNhan,
    this.ngaySinh,
    this.gioiTinh,
    this.diaChi,
    this.chanDoan,
    this.danhSachThuoc = const [],
    this.bacSi,
    this.benhVien,
  });

  factory MedicineOcrResult.fromJson(Map<String, dynamic> json) {
    final loai = (json['loai_du_lieu'] as String?) ?? '';

    if (loai == 'vi_thuoc') {
      final components = <OcrMedicineComponent>[];
      final list = json['thanh_phan'];
      if (list is List) {
        for (final e in list) {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            components.add(
              OcrMedicineComponent(
                ten: (map['ten'] ?? '').toString(),
                hamLuong: (map['ham_luong'] ?? '').toString(),
              ),
            );
          }
        }
      }

      int? soLuongVien;
      final sl = json['so_luong_vien'];
      if (sl is num) {
        soLuongVien = sl.toInt();
      } else if (sl is String) {
        soLuongVien = int.tryParse(sl);
      }

      return MedicineOcrResult(
        loaiDuLieu: OcrDataType.viThuoc,
        rawJson: json,
        tenThuoc: (json['ten_thuoc'] ?? '').toString(),
        soLuongVien: soLuongVien,
        thanhPhan: components,
      );
    }

    if (loai == 'don_thuoc') {
      final drugs = <OcrPrescriptionDrug>[];
      final list = json['danh_sach_thuoc'];
      if (list is List) {
        for (final e in list) {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            final lieuDung = (map['lieu_dung'] is Map)
                ? Map<String, dynamic>.from(map['lieu_dung'] as Map)
                : <String, dynamic>{};

            drugs.add(
              OcrPrescriptionDrug(
                tenThuoc: (map['ten_thuoc'] ?? '').toString(),
                soLuong: (map['so_luong'] ?? '').toString(),
                sang: (lieuDung['sang'] ?? '').toString(),
                trua: (lieuDung['trua'] ?? '').toString(),
                toi: (lieuDung['toi'] ?? '').toString(),
              ),
            );
          }
        }
      }

      return MedicineOcrResult(
        loaiDuLieu: OcrDataType.donThuoc,
        rawJson: json,
        tenBenhNhan: (json['ten_benh_nhan'] ?? '').toString(),
        ngaySinh: (json['ngay_sinh'] ?? '').toString(),
        gioiTinh: (json['gioi_tinh'] ?? '').toString(),
        diaChi: (json['dia_chi'] ?? '').toString(),
        chanDoan: (json['chan_doan'] ?? '').toString(),
        danhSachThuoc: drugs,
        bacSi: (json['bac_si'] ?? '').toString(),
        benhVien: (json['benh_vien'] ?? '').toString(),
      );
    }

    // Nếu loai_du_lieu không khớp
    return MedicineOcrResult(
      loaiDuLieu: OcrDataType.unknown,
      rawJson: json,
    );
  }

  @override
  String toString() => 'MedicineOcrResult(loaiDuLieu: $loaiDuLieu)';
}
