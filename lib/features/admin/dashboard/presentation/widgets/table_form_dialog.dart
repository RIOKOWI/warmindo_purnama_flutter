import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_text_field.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/table_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/data/models/table_request_model.dart';
import 'package:warmindo_purnama_flutter/features/admin/dashboard/presentation/providers/table_admin_provider.dart';

/// Dialog untuk create/edit table
class TableFormDialog extends StatefulWidget {
  final TableModel? table;

  const TableFormDialog({super.key, this.table});

  @override
  State<TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<TableFormDialog> {
  late final TextEditingController _tableNumberController;
  String _selectedStatus = 'available';

  bool get isEditing => widget.table != null;

  @override
  void initState() {
    super.initState();
    _tableNumberController = TextEditingController(
      text: widget.table?.tableNumber.replaceAll('MEJA ', '') ?? '',
    );
    _selectedStatus = widget.table?.status ?? 'available';
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tableNumber = _tableNumberController.text.trim();
    if (tableNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor meja wajib diisi'), backgroundColor: AppColors.error),
      );
      return;
    }

    final provider = context.read<TableAdminProvider>();
    final request = TableRequestModel(
      tableNumber: 'MEJA $tableNumber',
      status: _selectedStatus,
    );

    TableModel? result;
    if (isEditing) {
      result = await provider.updateTable(widget.table!.id, request);
    } else {
      result = await provider.createTable(request);
    }

    if (result != null && mounted) {
      Navigator.pop(context, result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan meja'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TableAdminProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.dark, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'EDIT MEJA' : 'TAMBAH MEJA',
              style: AppTextStyles.headline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeoTextField(
              controller: _tableNumberController,
              label: 'Nomor Meja',
              hint: 'Contoh: 01',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            Text('Status', style: AppTextStyles.body),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatusOption(
                    label: 'Tersedia',
                    value: 'available',
                    groupValue: _selectedStatus,
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusOption(
                    label: 'Terisi',
                    value: 'occupied',
                    groupValue: _selectedStatus,
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: 'Batal',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    label: isEditing ? 'Simpan' : 'Tambah',
                    isLoading: provider.isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final color = value == 'available' ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.dark,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? color : AppColors.text,
            fontWeight: isSelected ? FontWeight.w700 : null,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}