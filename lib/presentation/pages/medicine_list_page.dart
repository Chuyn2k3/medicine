import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/data/models/medicine_model.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/medicine_cubit.dart';
import '../widgets/medicine_list_item.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({Key? key}) : super(key: key);

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();

    // Load initial data
    context.read<MedicineCubit>().getMedicineList(isRefresh: true);

    // Listen for scroll to load more
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more data when reaching bottom
      if (!_isSearching) {
        context.read<MedicineCubit>().getMedicineList();
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Thuốc'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thuốc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                          context
                              .read<MedicineCubit>()
                              .getMedicineList(isRefresh: true);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MedicineCubit, MedicineState>(
              builder: (context, state) {
                print(state);
                if (state is MedicineLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MedicineListLoaded) {
                  final medicines = state.medicines;
                  final _hasMorePages = medicines.length == 10;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _hasMorePages ? medicines.length + 1 : medicines.length,
                    itemBuilder: (context, index) {
                      if (_hasMorePages && index == medicines.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        );
                      }

                      return MedicineListItem(
                        medicine: medicines[index],
                        onTap: () {
                          context
                              .read<MedicineCubit>()
                              .getMedicineById(medicines[index].id);
                          _showMedicineDetail(context, medicines[index]);
                        },
                      );
                    },
                  );
                }

                if (state is MedicineError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<MedicineCubit>()
                                .getMedicineList(isRefresh: true);
                          },
                          child: const Text('Thử Lại'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicineDetail(BuildContext context, MedicineModel medicine) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicine.name ?? "-",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Liều lượng',
                  medicine.quantity != null
                      ? medicine.quantity.toString()
                      : "-"),
              _buildDetailRow('Cách dùng', medicine.dosage ?? "-"),
              const SizedBox(height: 16),
              Text(
                'Mô tả',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(medicine.description ?? "-"),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
