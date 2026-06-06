import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_admin_model.dart';
import '../providers/user_admin_provider.dart';
import '../widgets/user_admin_tile.dart';
import '../widgets/user_form_sheet.dart';

/// Halaman untuk manage user (CRUD)
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

    // Add listener for infinite scroll
    _scrollController.addListener(_onScroll);

    // Fetch users on init
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

  /// Open form untuk create/edit user
  Future<void> _openForm(BuildContext context, UserAdminModel? user) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UserFormSheet(user: user),
    );
  }

  /// Show confirmation dialog untuk delete
  Future<void> _confirmDelete(
      BuildContext context, UserAdminModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nonaktifkan user?'),
        content: Text(
          '${user.name} (${user.email}) akan dinonaktifkan. '
          'User ini tidak bisa login sampai diaktifkan kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _doDelete(context, user);
    }
  }

  /// Do delete user
  Future<void> _doDelete(BuildContext context, UserAdminModel user) async {
    final provider = context.read<UserAdminProvider>();
    final success = await provider.deleteUser(user.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'User ${user.name} berhasil dinonaktifkan'
                : 'Gagal menonaktifkan user: ${provider.errorMessage}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Show confirmation dialog untuk restore
  Future<void> _confirmRestore(
      BuildContext context, UserAdminModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktifkan kembali?'),
        content: Text('${user.name} (${user.email}) akan dapat login kembali.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _doRestore(context, user);
    }
  }

  /// Do restore user
  Future<void> _doRestore(BuildContext context, UserAdminModel user) async {
    final provider = context.read<UserAdminProvider>();
    final success = await provider.restoreUser(user.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'User ${user.name} berhasil diaktifkan kembali'
                : 'Gagal mengaktifkan user: ${provider.errorMessage}',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Build summary header
  Widget _buildSummaryHeader(UserAdminProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SummaryChip('Admin', provider.totalAdmin, Colors.red),
            const SizedBox(width: 6),
            _SummaryChip('Kasir', provider.totalKasir, Colors.blue),
            const SizedBox(width: 6),
            _SummaryChip('Customer', provider.totalCustomer, Colors.green),
            if (provider.totalDeleted > 0) ...[
              const SizedBox(width: 6),
              _SummaryChip('Nonaktif', provider.totalDeleted, Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  /// Build body berdasarkan state
  Widget _buildBody(UserAdminProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchUsers(refresh: true),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (provider.users.isEmpty) {
      return const Center(child: Text('Belum ada user'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchUsers(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: provider.users.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = provider.users[index];
          return UserAdminTile(
            user: user,
            onEdit: () => _openForm(context, user),
            onDelete: () => _confirmDelete(context, user),
            onRestore: () => _confirmRestore(context, user),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<UserAdminProvider>().fetchUsers(refresh: true),
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Chip untuk menampilkan summary count
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}