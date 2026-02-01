import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../consignment/data/consignment_repository.dart';
import '../../../consignment/data/models/consignment.dart';
import '../../data/models/sale_request.dart';
import '../bloc/sale_bloc.dart';

/// Page for recording a new sale. (Shop owner only)
class RecordSalePage extends StatelessWidget {
  const RecordSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SaleBloc(getIt()),
      child: const _RecordSaleForm(),
    );
  }
}

class _RecordSaleForm extends StatefulWidget {
  const _RecordSaleForm();

  @override
  State<_RecordSaleForm> createState() => _RecordSaleFormState();
}

class _RecordSaleFormState extends State<_RecordSaleForm> {
  final _formKey = GlobalKey<FormState>();

  Consignment? _selectedConsignment;
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  List<Consignment> _consignments = [];
  bool _loadingConsignments = true;

  @override
  void initState() {
    super.initState();
    _loadConsignments();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadConsignments() async {
    try {
      final repo = getIt<ConsignmentRepository>();
      final consignments = await repo.getMyConsignments(
        status: ConsignmentStatus.active,
      );
      setState(() {
        _consignments = consignments;
        _loadingConsignments = false;
      });
    } catch (e) {
      setState(() => _loadingConsignments = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedConsignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih titipan terlebih dahulu')),
      );
      return;
    }

    final quantity = int.parse(_quantityController.text);
    if (quantity > _selectedConsignment!.currentQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah melebihi stok tersedia (${_selectedConsignment!.currentQuantity})',
          ),
        ),
      );
      return;
    }

    final request = SaleRequest(
      consignmentId: _selectedConsignment!.id,
      quantity: quantity,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    context.read<SaleBloc>().add(RecordSale(request));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Catat Penjualan')),
      body: BlocListener<SaleBloc, SaleState>(
        listener: (context, state) {
          if (state is SaleRecorded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Penjualan berhasil dicatat!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is SaleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: _loadingConsignments
            ? const Center(child: CircularProgressIndicator())
            : _consignments.isEmpty
            ? _buildNoConsignments(context)
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Consignment Picker
                    Text('Pilih Titipan', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Consignment>(
                      value: _selectedConsignment,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pilih titipan',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: _consignments.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${c.product.name} (stok: ${c.currentQuantity})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (c) =>
                          setState(() => _selectedConsignment = c),
                      validator: (v) => v == null ? 'Pilih titipan' : null,
                    ),
                    const SizedBox(height: 16),

                    // Selected consignment info
                    if (_selectedConsignment != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedConsignment!.product.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _InfoTile(
                                    label: 'Harga Jual',
                                    value: currencyFormat.format(
                                      _selectedConsignment!.sellingPrice,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  _InfoTile(
                                    label: 'Stok Tersedia',
                                    value:
                                        '${_selectedConsignment!.currentQuantity}',
                                  ),
                                  const SizedBox(width: 24),
                                  _InfoTile(
                                    label: 'Komisi',
                                    value:
                                        '${_selectedConsignment!.commissionPercent.toStringAsFixed(0)}%',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Terjual',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.numbers),
                        helperText: _selectedConsignment != null
                            ? 'Maksimal: ${_selectedConsignment!.currentQuantity}'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Masukkan jumlah';
                        final qty = int.tryParse(v);
                        if (qty == null || qty <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Preview calculation
                    if (_selectedConsignment != null &&
                        _quantityController.text.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final qty =
                              int.tryParse(_quantityController.text) ?? 0;
                          final total =
                              qty * _selectedConsignment!.sellingPrice;
                          final commission =
                              total *
                              (_selectedConsignment!.commissionPercent / 100);
                          final earning = total - commission;

                          return Card(
                            color: theme.colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Perhitungan',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  _CalcRow(
                                    label: 'Total Penjualan',
                                    value: currencyFormat.format(total),
                                  ),
                                  _CalcRow(
                                    label: 'Komisi Toko',
                                    value:
                                        '- ${currencyFormat.format(commission)}',
                                  ),
                                  const Divider(),
                                  _CalcRow(
                                    label: 'Pendapatan Penitip',
                                    value: currencyFormat.format(earning),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    BlocBuilder<SaleBloc, SaleState>(
                      builder: (context, state) {
                        final isLoading = state is SaleLoading;
                        return FilledButton.icon(
                          onPressed: isLoading ? null : _submit,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Catat Penjualan'),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNoConsignments(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada titipan aktif',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak dapat mencatat penjualan karena tidak ada titipan aktif',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _CalcRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                : null,
          ),
          Text(
            value,
            style: isBold
                ? Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }
}
