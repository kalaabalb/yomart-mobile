import 'package:flutter/material.dart';
import '../models/retailer_contact.dart';
import '../utility/retailer_contact_uri.dart';

class RetailerContactList extends StatelessWidget {
  const RetailerContactList({
    super.key,
    required this.contacts,
    required this.placement,
    required this.onSelected,
    this.loading = false,
    this.error,
    this.onRetry,
    this.emptyMessage = 'No contact options are available right now.',
  });

  final List<RetailerContact> contacts;
  final String placement;
  final ValueChanged<Uri> onSelected;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final visible =
        contacts.where((contact) => contact.appearsAt(placement)).toList();
    if (loading && visible.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && visible.isEmpty) {
      return TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Contact options unavailable · Retry'),
      );
    }
    final actionable = visible
        .map((contact) => (contact, retailerContactUri(contact)))
        .where((item) => item.$2 != null)
        .toList();
    if (actionable.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.support_agent_outlined,
              size: 26,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: actionable.map((item) {
        final contact = item.$1;
        final uri = item.$2!;
        final icon = switch (contact.type) {
          'phone' => Icons.phone_outlined,
          'telegram' => Icons.send_rounded,
          'whatsapp' => Icons.chat_outlined,
          'email' => Icons.email_outlined,
          _ => Icons.open_in_new_rounded,
        };
        return ListTile(
          leading: Icon(icon),
          title: Text(contact.label),
          subtitle: Text(contact.description.isNotEmpty
              ? contact.description
              : contact.value),
          onTap: () => onSelected(uri),
        );
      }).toList(),
    );
  }
}
