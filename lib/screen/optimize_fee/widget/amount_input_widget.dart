import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';
import '../../../provider/currency_provider.dart';
import '../../../util/constant_util.dart';

// Formatter personnalisé avec vérification de limite
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final double max;
  
  ThousandsSeparatorInputFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si le texte est vide, on retourne tel quel
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Enlever tous les espaces existants
    String digitsOnly = newValue.text.replaceAll(' ', '');

    // Vérifier que c'est bien un nombre valide
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(digitsOnly)) {
      return oldValue;
    }

    // Vérifier si la valeur dépasse la limite
    final numericValue = double.tryParse(digitsOnly);
    if (numericValue != null && numericValue > max) {
      // Si on essaie d'ajouter des caractères (nouveau texte plus long), bloquer
      if (newValue.text.replaceAll(' ', '').length > oldValue.text.replaceAll(' ', '').length) {
        return oldValue; // Retourner l'ancienne valeur pour bloquer
      }
      // Sinon (suppression), permettre la modification
    }

    // Séparer la partie entière et décimale
    List<String> parts = digitsOnly.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Formater la partie entière avec des espaces
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }

    // Ajouter la partie décimale si elle existe
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    } else if (digitsOnly.endsWith('.')) {
      formatted += '.';
    }

    // Calculer la nouvelle position du curseur
    int originalCursorPos = newValue.selection.baseOffset;
    int spacesBeforeCursor = newValue.text.substring(0, originalCursorPos).split(' ').length - 1;
    int digitsBeforeCursor = originalCursorPos - spacesBeforeCursor;
    
    // Compter les espaces dans le texte formaté jusqu'à la position du curseur
    int newSpacesBeforeCursor = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length && digitCount < digitsBeforeCursor; i++) {
      if (formatted[i] == ' ') {
        newSpacesBeforeCursor++;
      } else if (formatted[i] != '.') {
        digitCount++;
      } else if (formatted[i] == '.') {
        digitCount++;
      }
    }
    
    int newCursorPos = digitsBeforeCursor + newSpacesBeforeCursor;
    newCursorPos = newCursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

class AmountInputWidget extends StatefulWidget {
  const AmountInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 99999999999.0,
    this.label = 'Amount',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min, max;
  final String label;

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late final TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isUserTyping = false;
  String _lastValidText = '';

  @override
  void initState() {
    super.initState();
    _lastValidText = _formatValue(widget.value);
    _controller = TextEditingController(text: _lastValidText);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _isUserTyping = false;
      // CORRECTION: Ne pas reformater depuis widget.value
      // Le texte dans _controller est déjà correct et formaté
    }
  }

  @override
  void didUpdateWidget(AmountInputWidget old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_isUserTyping && !_focusNode.hasFocus) {
      _lastValidText = _formatValue(widget.value);
      _controller.text = _lastValidText;
    }
  }

  String _formatValue(double value) {
    // Pour les très grands nombres (> 1e15), utiliser une représentation plus précise
    String valueStr;
    
    if (value.abs() > 1e15) {
      // Utiliser toStringAsFixed(0) pour les très grands entiers
      if (value == value.toInt()) {
        valueStr = value.toInt().toString();
      } else {
        // Pour les décimaux très grands, conserver la précision
        valueStr = value.toStringAsFixed(0);
      }
    } else if (value == value.toInt()) {
      // Pour les entiers normaux
      valueStr = value.toInt().toString();
    } else {
      // Pour les décimaux - conserver les décimales significatives
      String tempStr = value.toString();
      if (tempStr.contains('.')) {
        List<String> parts = tempStr.split('.');
        String decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');
        if (decimalPart.isEmpty) {
          valueStr = parts[0];
        } else {
          valueStr = '${parts[0]}.$decimalPart';
        }
      } else {
        valueStr = tempStr;
      }
    }
    
    // Séparer partie entière et décimale
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Formater la partie entière avec des espaces
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    // Ajouter la partie décimale si elle existe
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    }
    
    return formatted;
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _focusNode.hasFocus
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
          : Theme.of(context).colorScheme.surface,
      borderRadius: Global.borderMd,
      border: Border.all(
        color: _focusNode.hasFocus
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        width: _focusNode.hasFocus ? 1.5 : 0.8,
      ),
    ),
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: ThemeUtil.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                context.read<CurrencyProvider>().currencySymbol,
                style: ThemeUtil.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 56,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
                ThousandsSeparatorInputFormatter(max: widget.max),
                LengthLimitingTextInputFormatter(30), // Augmenté pour les grands nombres
              ],
              style: ThemeUtil.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onTextChanged,
            ),
          ),
        ),
      ],
    ),
  );

  void _onTextChanged(String value) {
    _isUserTyping = true;
    
    // Enlever les espaces pour la conversion
    String cleanValue = value.replaceAll(' ', '');
    
    final decimalValue = ConstantUtil.parseLocalizedNumber(cleanValue);
    if (decimalValue != null) {
      final doubleValue = decimalValue.toDouble();
      if (doubleValue >= widget.min && doubleValue <= widget.max) {
        // Sauvegarder le texte actuel comme dernier texte valide
        _lastValidText = value;
        widget.onChanged(doubleValue);
      }
    } else if (cleanValue.isEmpty) {
      widget.onChanged(widget.min);
    }
  }
}
