import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/power_up_item.dart';
import '../services/supabase_service.dart';
import '../utils/payment_validator.dart';

class StoreScreen extends StatefulWidget {
  final String playerName;
  
  const StoreScreen({super.key, required this.playerName});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<PowerUpItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    
    final items = await SupabaseService.getAvailableItems();
    
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[300]!, Colors.purple[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '🛒 TIENDA DE POWER-UPS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay items disponibles',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return _buildItemCard(_items[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(PowerUpItem item) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showPurchaseDialog(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Icon(
                _getItemIcon(item.type),
                size: 64,
                color: _getItemColor(item.type),
              ),
              const SizedBox(height: 12),
              
              // Nombre
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Descripción
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'triple_shot':
        return Icons.filter_3;
      case 'explosive_bird':
        return Icons.whatshot;
      case 'super_speed':
        return Icons.speed;
      default:
        return Icons.stars;
    }
  }

  Color _getItemColor(String type) {
    switch (type) {
      case 'triple_shot':
        return Colors.blue;
      case 'explosive_bird':
        return Colors.orange;
      case 'super_speed':
        return Colors.purple;
      default:
        return Colors.amber;
    }
  }

  void _showPurchaseDialog(PowerUpItem item) {
    final cardController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comprar ${item.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Precio: \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Información de Pago',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Número de tarjeta
              TextField(
                controller: cardController,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
              ),
              const SizedBox(height: 12),
              
              // Fecha de expiración y CVV
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        hintText: '12/25',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final validation = PaymentValidator.validatePayment(
                cardNumber: cardController.text,
                expiryDate: expiryController.text,
                cvv: cvvController.text,
              );

              if (!validation['isValid']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(validation['errors'].join('\n')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _processPurchase(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase(PowerUpItem item) async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simular procesamiento de pago
    await Future.delayed(const Duration(seconds: 2));

    // Guardar compra en Supabase
    final success = await SupabaseService.purchaseItem(
      playerName: widget.playerName,
      itemId: item.id!,
      itemType: item.type,
    );

    if (!mounted) return;
    Navigator.pop(context); // Cerrar indicador de carga

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡${item.name} comprado exitosamente! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Retornar al game screen con la información del item comprado
      Navigator.pop(context, {
        'itemName': item.name,
        'itemType': item.type,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar la compra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Input Formatter para número de tarjeta
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Input Formatter para fecha de expiración
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
