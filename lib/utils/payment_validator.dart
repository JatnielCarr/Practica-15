class PaymentValidator {
  // Validar número de tarjeta (16 dígitos)
  static bool validateCardNumber(String cardNumber) {
    // Remover espacios y guiones
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    // Verificar que sean exactamente 16 dígitos
    if (cleaned.length != 16) return false;
    
    // Verificar que solo contenga números
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return false;
    
    // Algoritmo de Luhn para validación
    return _luhnCheck(cleaned);
  }

  // Algoritmo de Luhn
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  // Validar fecha de expiración (MM/YY)
  static bool validateExpiryDate(String expiryDate) {
    // Formato MM/YY
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;
    
    final parts = expiryDate.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) return false;
    
    // Validar mes (01-12)
    if (month < 1 || month > 12) return false;
    
    // Obtener fecha actual
    final now = DateTime.now();
    final currentYear = now.year % 100; // Últimos 2 dígitos del año
    final currentMonth = now.month;
    
    // Validar que la fecha no haya expirado
    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;
    
    return true;
  }

  // Validar CVV (3 dígitos)
  static bool validateCVV(String cvv) {
    // Exactamente 3 dígitos
    if (cvv.length != 3) return false;
    
    // Solo números
    return RegExp(r'^\d{3}$').hasMatch(cvv);
  }

  // Validar todos los campos del pago
  static Map<String, dynamic> validatePayment({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) {
    final errors = <String>[];
    
    if (!validateCardNumber(cardNumber)) {
      errors.add('Número de tarjeta inválido (debe ser 16 dígitos)');
    }
    
    if (!validateExpiryDate(expiryDate)) {
      errors.add('Fecha de expiración inválida (formato MM/YY)');
    }
    
    if (!validateCVV(cvv)) {
      errors.add('CVV inválido (debe ser 3 dígitos)');
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  // Formatear número de tarjeta con espacios (XXXX XXXX XXXX XXXX)
  static String formatCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      if (i < 16) {
        buffer.write(cleaned[i]);
      }
    }
    
    return buffer.toString();
  }

  // Enmascarar número de tarjeta (**** **** **** 1234)
  static String maskCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length != 16) return cardNumber;
    
    return '**** **** **** ${cleaned.substring(12)}';
  }

  // Detectar tipo de tarjeta
  static String detectCardType(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith('5')) return 'Mastercard';
    if (cleaned.startsWith('3')) return 'American Express';
    if (cleaned.startsWith('6')) return 'Discover';
    
    return 'Unknown';
  }
}
