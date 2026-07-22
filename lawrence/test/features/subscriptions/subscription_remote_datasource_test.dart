import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawrence/core/network/network_client.dart';
import 'package:lawrence/features/subscriptions/data/datasources/subscription_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkClient extends Mock implements NetworkClient {}

void main() {
  late MockNetworkClient networkClient;
  late SubscriptionRemoteDataSourceImpl dataSource;

  setUp(() {
    networkClient = MockNetworkClient();
    dataSource = SubscriptionRemoteDataSourceImpl(networkClient);
  });

  test('cancelamento usa exclusivamente a rota canonica v1', () async {
    when(
      () => networkClient.patch<dynamic>(
        '/api/v1/subscriptions/subscription-1/cancel',
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ),
    );

    await dataSource.cancelSubscription('subscription-1');

    verify(
      () => networkClient.patch<dynamic>(
        '/api/v1/subscriptions/subscription-1/cancel',
      ),
    ).called(1);
  });

  test('consulta de checkout usa a rota canonica v1', () async {
    when(
      () => networkClient.get<dynamic>(
        '/api/v1/payments/checkout/status/checkout-1',
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {'status': 'paid'},
      ),
    );

    final status = await dataSource.getCheckoutStatus('checkout-1');

    expect(status, 'paid');
    verify(
      () => networkClient.get<dynamic>(
        '/api/v1/payments/checkout/status/checkout-1',
      ),
    ).called(1);
  });
}
