import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_app_bar.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/user_admin_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/user_admin_provider.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/user_admin_tile.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/widgets/user_form_sheet.dart';

/// Fake data untuk skeleton loader
final _fakeUsers = List.generate(7, (i) => UserAdminModel(
  id: i,
  name: 'User Name',
  email: 'user@example.com',
  phone: '081234567890',
  role: 'kasir',
  createdAt: '2024-01-01',
  updatedAt: '2024-01-01',
));

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserAdminProvider>().fetchUsers(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UserAdminProvider>().loadMore();
    }
  }

  Future<void> _openForm(BuildContext context, UserAdminModel? user) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserFormSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: NeoAppBar(title: 'KELOLA USER'),
      body: Consumer<UserAdminProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.users.isNotEmpty) _buildSummaryHeader(provider),
              Expanded(child: _buildBody(provider)),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: AppColors.dark, offset: Offset(5, 5), blurRadius: 0)],
        ),
        child: FloatingActionButton(
          onPressed: () => _openForm(context, null),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(UserAdminProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SummaryChip('Admin', provider.totalAdmin, AppColors.accent),
            const SizedBox(width: 8),
            _SummaryChip('Kasir', provider.totalKasir, AppColors.info),
            const SizedBox(width: 8),
            _SummaryChip('Customer', provider.totalCustomer, AppColors.success),
            if (provider.totalDeleted > 0) ...[
              const SizedBox(width: 8),
              _SummaryChip('Nonaktif', provider.totalDeleted, AppColors.textLight),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(UserAdminProvider provider) {
    if (provider.errorMessage != null && provider.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 3),
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(provider.errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.body),
            const SizedBox(height: 16),
            NeoButtonSmall(label: 'Coba Lagi', icon: Icons.refresh, onPressed: () => provider.fetchUsers(refresh: true)),
          ],
        ),
      );
    }


    // Tampilkan data atau skeleton berdasarkan state loading
    final users = provider.isLoading && provider.users.isEmpty
        ? _fakeUsers
        : provider.users;

    return RefreshIndicator(
      onRefresh: () => provider.fetchUsers(refresh: true),
      color: AppColors.accent,
      child: Skeletonizer(
        enabled: provider.isLoading && provider.users.isEmpty,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: users.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= users.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              );
            }

            final user = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UserAdminTile(
                user: user,
                onEdit: () => _openForm(context, user),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}