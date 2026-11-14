import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utility/constants.dart';

const publicCatalogResources = <String>{
  'categories', 'subCategories', 'brands', 'products', 'posters', 'stories',
  'collections', 'store-settings', 'retailer-contacts', 'support-content',
};

Set<String> catalogResourcesToRefresh(Iterable<String> changed) {
  if (changed.contains('*')) return publicCatalogResources;
  return changed.where(publicCatalogResources.contains).toSet();
}

/// Parses the deliberately small public SSE contract. Events contain resource
/// names only; clients always reload authoritative records through the API.
class CatalogEventParser {
  String _event = '';
  String _id = '';
  final List<String> _data = [];
  final Set<String> _seenIds = <String>{};

  List<String>? addLine(String line) {
    if (line.startsWith(':')) return null;
    if (line.startsWith('event:')) {
      _event = line.substring(6).trim();
      return null;
    }
    if (line.startsWith('id:')) {
      _id = line.substring(3).trim();
      return null;
    }
    if (line.startsWith('data:')) {
      _data.add(line.substring(5).trimLeft());
      return null;
    }
    if (line.isNotEmpty) return null;

    final event = _event;
    final id = _id;
    final data = _data.join('\n');
    _event = '';
    _id = '';
    _data.clear();
    if (event == 'catalog.resync') return const ['*'];
    if (event != 'catalog.changed') return null;
    if (id.isNotEmpty && !_seenIds.add(id)) return null;
    if (_seenIds.length > 128) _seenIds.remove(_seenIds.first);
    try {
      final decoded = jsonDecode(data);
      final resources = decoded is Map ? decoded['resources'] : null;
      if (resources is List && resources.isNotEmpty &&
          resources.every((resource) => resource is String && publicCatalogResources.contains(resource))) {
        return resources.cast<String>();
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}

class _CatalogEventConnection {
  _CatalogEventConnection(this.lines, this.close);
  final Stream<String> lines;
  final Future<void> Function() close;
}

/// Lifecycle-aware, unauthenticated subscription for public catalog invalidation.
class CatalogEventSubscription {
  CatalogEventSubscription({required this.onChanged, http.Client Function()? clientFactory})
      : _clientFactory = clientFactory ?? http.Client.new;

  final void Function(List<String> resources) onChanged;
  final http.Client Function() _clientFactory;
  bool _running = false;
  bool _disposed = false;
  int _generation = 0;
  bool _skipFirstResync = true;
  Timer? _retryTimer;
  _CatalogEventConnection? _connection;

  void start() {
    if (_disposed || _running || mainUrl.isEmpty) return;
    _running = true;
    final generation = ++_generation;
    unawaited(_run(generation));
  }

  Future<void> _run(int generation) async {
    var failures = 0;
    while (_running && !_disposed) {
      http.Client? client;
      try {
        final activeClient = _clientFactory();
        client = activeClient;
        final request = http.Request('GET', Uri.parse('$mainUrl/events/catalog'))
          ..headers['Accept'] = 'text/event-stream';
        final response = await client.send(request).timeout(const Duration(seconds: 15));
        if (response.statusCode != 200 ||
            !(response.headers['content-type'] ?? '').toLowerCase().contains('text/event-stream')) {
          client.close();
          throw StateError('Catalog event stream is unavailable.');
        }
        final connection = _CatalogEventConnection(
          response.stream.transform(utf8.decoder).transform(const LineSplitter()),
          () async => activeClient.close(),
        );
        _connection = connection;
        failures = 0;
        final parser = CatalogEventParser();
        await for (final line in connection.lines) {
          if (!_running || _disposed) break;
          final changed = parser.addLine(line);
          if (changed != null) {
            if (changed.length == 1 && changed.first == '*' && _skipFirstResync) {
              _skipFirstResync = false;
            } else {
              onChanged(changed);
            }
          }
        }
        await connection.close();
        if (identical(_connection, connection)) _connection = null;
      } catch (_) {
        failures++;
        await _connection?.close();
        _connection = null;
        client?.close();
      }
      if (_running && !_disposed && generation == _generation) {
        final seconds = failures == 0 ? 1 : (1 << (failures - 1).clamp(0, 5).toInt());
        await _waitBeforeReconnect(Duration(seconds: seconds.clamp(1, 30).toInt()));
      }
    }
  }

  Future<void> stop() async {
    _running = false;
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    final connection = _connection;
    _connection = null;
    await connection?.close();
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
  }

  Future<void> _waitBeforeReconnect(Duration duration) async {
    final completer = Completer<void>();
    _retryTimer?.cancel();
    _retryTimer = Timer(duration, () {
      _retryTimer = null;
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }
}
