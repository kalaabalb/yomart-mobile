import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce_flutter/services/catalog_event_subscription.dart';

void main() {
  group('CatalogEventParser', () {
    test('maps catalogue events to only the API resources that need refetching', () {
      expect(catalogResourcesToRefresh(['products']), {'products'});
      expect(catalogResourcesToRefresh(['products', 'products']), {'products'});
      expect(catalogResourcesToRefresh(['*']), publicCatalogResources);
      expect(catalogResourcesToRefresh(['orders']), isEmpty);
    });
    test('requests resync when connected and accepts only public resources', () {
      final parser = CatalogEventParser();
      expect(parser.addLine('event: catalog.resync'), isNull);
      expect(parser.addLine('data: {}'), isNull);
      expect(parser.addLine(''), ['*']);

      expect(parser.addLine('event: catalog.changed'), isNull);
      expect(parser.addLine('id: instance:1'), isNull);
      expect(parser.addLine('data: {"resources":["products","categories"]}'), isNull);
      expect(parser.addLine(''), ['products', 'categories']);

      parser.addLine('event: catalog.changed');
      parser.addLine('id: instance:1');
      parser.addLine('data: {"resources":["products"]}');
      expect(parser.addLine(''), isNull);

      parser.addLine('event: catalog.changed');
      parser.addLine('data: {"resources":["orders"]}');
      expect(parser.addLine(''), isNull);

      parser.addLine('event: catalog.changed');
      parser.addLine('data: malformed');
      expect(parser.addLine(''), isNull);
    });

    test('ignores heartbeat comments and unknown event names', () {
      final parser = CatalogEventParser();
      expect(parser.addLine(': keep-alive'), isNull);
      parser.addLine('event: private.order.updated');
      parser.addLine('data: {"resources":["orders"]}');
      expect(parser.addLine(''), isNull);
    });
  });

  test('event subscription resyncs, reconnects after stream close, and stops cleanly', () async {
    var connections = 0;
    final events = <int>[];
    final subscription = CatalogEventSubscription(
      onChanged: (_) => events.add(DateTime.now().millisecondsSinceEpoch),
      clientFactory: () => MockClient((request) async {
        connections++;
        expect(request.url.path, '/events/catalog');
        expect(request.headers['accept'], 'text/event-stream');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response('event: catalog.resync\ndata: {}\n\nevent: catalog.changed\ndata: {"resources":["products"]}\n\n', 200,
            headers: {'content-type': 'text/event-stream'});
      }),
    );
    subscription.start();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(events.length, 1);
    expect(connections, 1);
    await subscription.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(connections, 1);
  });

  test('initial resync is suppressed after startup catalog load and duplicate SSE IDs are ignored', () async {
    final changes = <int>[];
    final client = MockClient((_) async => http.Response(
          'event: catalog.resync\ndata: {}\n\nevent: catalog.changed\nid: instance:1\ndata: {"resources":["products"]}\n\n'
          'event: catalog.changed\nid: instance:1\ndata: {"resources":["products"]}\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        ));
    final subscription = CatalogEventSubscription(
      onChanged: (_) => changes.add(DateTime.now().millisecondsSinceEpoch),
      clientFactory: () => client,
    );
    subscription.start();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(changes.length, 1);
    await subscription.dispose();
  });

  test('foreground restart opens a fresh stream and resyncs after background pause', () async {
    var connections = 0;
    final subscription = CatalogEventSubscription(
      onChanged: (_) {},
      clientFactory: () => MockClient((_) async {
        connections++;
        return http.Response('event: catalog.resync\ndata: {}\n\n', 200,
            headers: {'content-type': 'text/event-stream'});
      }),
    );
    subscription.start();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await subscription.stop(); // app moved to background
    subscription.start(); // app resumed
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(connections, 2);
    await subscription.dispose();
  });

  test('network interruption reconnects with bounded retry and no credentials', () async {
    var connections = 0;
    final subscription = CatalogEventSubscription(
      onChanged: (_) {},
      clientFactory: () => MockClient((request) async {
        connections++;
        expect(request.headers.containsKey('authorization'), isFalse);
        if (connections == 1) throw http.ClientException('synthetic offline');
        return http.Response('event: catalog.resync\ndata: {}\n\n', 200,
            headers: {'content-type': 'text/event-stream'});
      }),
    );
    subscription.start();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(connections, 2);
    await subscription.dispose();
  });
}
