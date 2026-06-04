import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../data/models/order_type_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/create_order_request_model.dart';
import '../../domain/repositories/checkout_repository.dart';

/// Provider for managing checkout state and operations
class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider({CheckoutRepository? repository})
      : _repository = repository;

  final CheckoutRepository? _repository;
  final Logger _log = Logger();

  List<OrderTypeModel> _orderTypes = [];
  List<TableModel> _availableTables = [];
  OrderTypeModel? _selectedOrderType;
  TableModel? _selectedTable;
  String _notes = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  OrderModel? _createdOrder;

  // Getters
  List<OrderTypeModel> get orderTypes => _orderTypes;
  List<TableModel> get availableTables => _availableTables;
  OrderTypeModel? get selectedOrderType => _selectedOrderType;
  TableModel? get selectedTable => _selectedTable;
  String get notes => _notes;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  OrderModel? get createdOrder => _createdOrder;
  bool get isDineIn => _selectedOrderType?.isDineIn ?? false;

  /// Check if order can be submitted
  bool get canSubmit {
    if (_selectedOrderType == null) return false;
    if (_selectedOrderType!.isDineIn && _selectedTable == null) return false;
    return true;
  }

  /// Initialize provider by fetching order types and available tables
  Future<void> init() async {
    if (_repository == null) {
      _log.e('[CheckoutProvider] Repository not initialized');
      _errorMessage = 'Repository not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[CheckoutProvider] Initializing checkout data...');
      final repo = _repository!;
      final results = await Future.wait([
        repo.getOrderTypes(),
        repo.getAvailableTables(),
      ]);

      _orderTypes = results[0] as List<OrderTypeModel>;
      _availableTables = results[1] as List<TableModel>;

      // Set default to take_away if available
      final takeAway = _orderTypes.cast<OrderTypeModel?>().firstWhere(
        (type) => type?.name == 'take_away',
        orElse: () => null,
      );
      if (takeAway != null) {
        _selectedOrderType = takeAway;
      }

      _log.i('[CheckoutProvider] Loaded ${_orderTypes.length} order types, ${_availableTables.length} tables');
    } catch (e, st) {
      _log.e('[CheckoutProvider] Failed to initialize', error: e, stackTrace: st);
      _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select an order type
  void selectOrderType(OrderTypeModel type) {
    _selectedOrderType = type;
    // Reset table selection if not dine_in
    if (!type.isDineIn) {
      _selectedTable = null;
    }
    _log.i('[CheckoutProvider] Selected order type: ${type.name}');
    notifyListeners();
  }

  /// Select a table
  void selectTable(TableModel? table) {
    _selectedTable = table;
    _log.i('[CheckoutProvider] Selected table: ${table?.tableNumber ?? 'none'}');
    notifyListeners();
  }

  /// Set notes without notifying listeners (optimization)
  void setNotes(String value) {
    _notes = value;
  }

  /// Submit the order
  Future<bool> submitOrder() async {
    if (_repository == null) {
      _log.e('[CheckoutProvider] Repository not initialized for submitOrder');
      _errorMessage = 'Repository not available';
      notifyListeners();
      return false;
    }

    if (!canSubmit) {
      _log.w('[CheckoutProvider] Cannot submit: validation failed');
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _log.i('[CheckoutProvider] Submitting order...');
      final request = CreateOrderRequestModel(
        restaurantTableId: isDineIn ? _selectedTable?.id : null,
        orderTypeId: _selectedOrderType!.id,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      final repo = _repository!;
      _createdOrder = await repo.createOrder(request);
      _log.i('[CheckoutProvider] Order created: ${_createdOrder!.invoiceNumber}');
      return true;
    } catch (e, st) {
      _log.e('[CheckoutProvider] Failed to submit order', error: e, stackTrace: st);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Reset all state to initial values
  void reset() {
    _orderTypes = [];
    _availableTables = [];
    _selectedOrderType = null;
    _selectedTable = null;
    _notes = '';
    _isLoading = false;
    _isSubmitting = false;
    _errorMessage = null;
    _createdOrder = null;
    _log.i('[CheckoutProvider] State reset');
    notifyListeners();
  }
}
