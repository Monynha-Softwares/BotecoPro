import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/data_models.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

// Formata valor como moeda brasileira
String formatCurrency(double value) {
  final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return formatter.format(value);
}

// Formata data e hora no padrão brasileiro
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
}

// Formata apenas a data no padrão brasileiro
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy', 'pt_BR').format(dateTime);
}

// AppBar customizada para o app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Card de Menu para a Homepage
class MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const MenuCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColor != null
                  ? [backgroundColor!, backgroundColor!.withOpacity(0.7)]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(delay: const Duration(milliseconds: 100));
  }
}

// Card de status (utilizado na homepage)
class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatusCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color ?? Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .moveX(begin: 30, duration: const Duration(milliseconds: 300));
  }
}

// Indicador de carregamento personalizado estilizado
class BotecoLoader extends StatelessWidget {
  final String? message;
  final double size;

  const BotecoLoader({
    Key? key,
    this.message,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: botecoWine.withOpacity(0.2),
            borderRadius: BorderRadius.circular(size / 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated circle
              SizedBox(
                width: size * 0.75,
                height: size * 0.75,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(botecoWine),
                  strokeWidth: 5,
                ),
              ),
              // Icon in the center
              Icon(
                Icons.sports_bar,
                size: size * 0.375,
                color: botecoWine,
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: const Duration(seconds: 2), begin: 0, end: 0.1)
        .then()
        .rotate(duration: const Duration(seconds: 2), begin: 0.1, end: 0),
        if (message != null) ...[  
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: botecoWine,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

// Badge de status para pedidos
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.pending:
        badgeColor = const Color(0xFFFFA000); // Amber
        statusText = 'Pendente';
        statusIcon = Icons.schedule;
        break;
      case OrderStatus.preparing:
        badgeColor = const Color(0xFF2196F3); // Blue
        statusText = 'Preparando';
        statusIcon = Icons.restaurant;
        break;
      case OrderStatus.ready:
        badgeColor = const Color(0xFF4CAF50); // Green
        statusText = 'Pronto';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.delivered:
        badgeColor = const Color(0xFF9E9E9E); // Grey
        statusText = 'Entregue';
        statusIcon = Icons.delivery_dining;
        break;
      case OrderStatus.canceled:
        badgeColor = const Color(0xFFF44336); // Red
        statusText = 'Cancelado';
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// Seletor de quantidade
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: quantity <= min
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: quantity <= min
              ? null
              : () => onChanged(quantity - 1),
        ),
        Container(
          width: 40,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: quantity >= max
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: quantity >= max
              ? null
              : () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

// Filtro de categorias
class CategoryFilter extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final ValueChanged<ProductCategory?> onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Row(
              children: [
                const Icon(Icons.filter_alt_off, size: 16),
                const SizedBox(width: 4),
                const Text('Todos'),
              ],
            ),
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight:
                  selectedCategory == null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              children: [
                const Icon(Icons.local_bar, size: 16),
                const SizedBox(width: 4),
                const Text('Bebidas'),
              ],
            ),
            selected: selectedCategory == ProductCategory.drink,
            onSelected: (_) => onCategorySelected(ProductCategory.drink),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.drink
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.drink
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              children: [
                const Icon(Icons.restaurant, size: 16),
                const SizedBox(width: 4),
                const Text('Comidas'),
              ],
            ),
            selected: selectedCategory == ProductCategory.food,
            onSelected: (_) => onCategorySelected(ProductCategory.food),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.food
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.food
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                const Text('Outros'),
              ],
            ),
            selected: selectedCategory == ProductCategory.other,
            onSelected: (_) => onCategorySelected(ProductCategory.other),
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == ProductCategory.other
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedCategory == ProductCategory.other
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog de confirmação
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: Text(
            confirmText,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}

// Card vazio para quando não há dados
class EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateCard({
    Key? key,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[  
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Botão de ação flutuante
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary),
      label: Text(
        label,
        style: TextStyle(color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    )
    .animate()
    .scale(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 200));
  }
}