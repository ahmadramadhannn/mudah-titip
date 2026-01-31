import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/agreement_request.dart';
import '../../data/models/commission_type.dart';
import '../bloc/agreement_bloc.dart';

/// Page for proposing a new agreement for a consignment.
class ProposeAgreementPage extends StatelessWidget {
  final int consignmentId;

  const ProposeAgreementPage({super.key, required this.consignmentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AgreementBloc>(),
      child: _ProposeAgreementView(consignmentId: consignmentId),
    );
  }
}

class _ProposeAgreementView extends StatefulWidget {
  final int consignmentId;

  const _ProposeAgreementView({required this.consignmentId});

  @override
  State<_ProposeAgreementView> createState() => _ProposeAgreementViewState();
}

class _ProposeAgreementViewState extends State<_ProposeAgreementView> {
  final _formKey = GlobalKey<FormState>();
  CommissionType _selectedType = CommissionType.percentage;
  final _commissionValueController = TextEditingController();
  final _bonusThresholdController = TextEditingController();
  final _bonusAmountController = TextEditingController();
  final _termsNoteController = TextEditingController();

  @override
  void dispose() {
    _commissionValueController.dispose();
    _bonusThresholdController.dispose();
    _bonusAmountController.dispose();
    _termsNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Perjanjian')),
      body: BlocConsumer<AgreementBloc, AgreementState>(
        listener: (context, state) {
          if (state is AgreementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(true);
          } else if (state is AgreementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AgreementActionInProgress;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Commission Type Selection
                Text(
                  'Tipe Komisi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCommissionTypeSelector(theme),
                const SizedBox(height: 24),

                // Dynamic fields based on commission type
                _buildCommissionFields(theme),
                const SizedBox(height: 24),

                // Terms Note
                Text(
                  'Catatan Tambahan (Opsional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _termsNoteController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan catatan atau syarat tambahan...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton(
                  onPressed: isLoading ? null : _onSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajukan Perjanjian'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommissionTypeSelector(ThemeData theme) {
    return Column(
      children: CommissionType.values.map((type) {
        final isSelected = type == _selectedType;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(51),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() => _selectedType = type);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommissionFields(ThemeData theme) {
    switch (_selectedType) {
      case CommissionType.percentage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Persentase Komisi',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commissionValueController,
              decoration: const InputDecoration(
                hintText: 'Contoh: 10',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Persentase komisi wajib diisi';
                }
                final val = int.tryParse(value);
                if (val == null || val < 0 || val > 100) {
                  return 'Persentase harus antara 0-100';
                }
                return null;
              },
            ),
          ],
        );

      case CommissionType.fixedPerItem:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jumlah Per Item',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commissionValueController,
              decoration: const InputDecoration(
                hintText: 'Contoh: 2000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah per item wajib diisi';
                }
                return null;
              },
            ),
          ],
        );

      case CommissionType.tieredBonus:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Penjualan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bonusThresholdController,
              decoration: const InputDecoration(
                hintText: 'Contoh: 90',
                suffixText: '% terjual',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Target penjualan wajib diisi';
                }
                final val = int.tryParse(value);
                if (val == null || val < 0 || val > 100) {
                  return 'Persentase harus antara 0-100';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Jumlah Bonus',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bonusAmountController,
              decoration: const InputDecoration(
                hintText: 'Contoh: 50000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah bonus wajib diisi';
                }
                return null;
              },
            ),
          ],
        );
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final request = AgreementRequest(
      consignmentId: widget.consignmentId,
      commissionType: _selectedType,
      commissionValue: _selectedType != CommissionType.tieredBonus
          ? double.tryParse(_commissionValueController.text)
          : null,
      bonusThresholdPercent: _selectedType == CommissionType.tieredBonus
          ? int.tryParse(_bonusThresholdController.text)
          : null,
      bonusAmount: _selectedType == CommissionType.tieredBonus
          ? double.tryParse(_bonusAmountController.text)
          : null,
      termsNote: _termsNoteController.text.isNotEmpty
          ? _termsNoteController.text
          : null,
    );

    context.read<AgreementBloc>().add(ProposeAgreement(request));
  }
}
