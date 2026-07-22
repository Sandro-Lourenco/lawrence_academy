import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/network/network_client.dart';
import '../../features/auth/application/use_cases/login_use_case.dart';
import '../../features/auth/application/use_cases/logout_use_case.dart';
import '../../features/auth/application/use_cases/register_use_case.dart';
import '../../features/auth/application/use_cases/restore_session_use_case.dart';
import '../../features/auth/application/use_cases/request_password_reset_use_case.dart';
import '../../features/auth/data/datasources/supabase_auth_datasource.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository_interface.dart';
import '../../features/certificates/data/datasources/certificate_remote_datasource.dart';
import '../../features/certificates/data/repositories/certificate_repository_impl.dart';
import '../../features/certificates/domain/repositories/certificate_repository.dart';
import '../../features/invoices/data/datasources/invoice_remote_datasource.dart';
import '../../features/invoices/data/repositories/invoice_repository_impl.dart';
import '../../features/invoices/domain/repositories/invoice_repository_interface.dart';
import '../../features/invoices/domain/use_cases/get_invoices_use_case.dart';
import '../../features/profile/application/use_cases/get_my_profile_use_case.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/subscriptions/application/use_cases/cancel_subscription_use_case.dart';
import '../../features/subscriptions/application/use_cases/create_checkout_use_case.dart';
import '../../features/subscriptions/application/use_cases/get_checkout_status_use_case.dart';
import '../../features/subscriptions/application/use_cases/get_subscriptions_use_case.dart';
import '../../features/subscriptions/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository_interface.dart';
import '../../features/sync/data/queue_repository.dart';
import '../../features/sync/domain/repositories/queue_repository.dart';
import '../../features/teacher_studio/data/datasources/teacher_course_remote_data_source.dart';
import '../../features/teacher_studio/data/repositories/teacher_course_repository_impl.dart';
import '../../features/teacher_studio/domain/repositories/teacher_course_repository.dart';
import '../../features/teacher_studio/domain/usecases/teacher_course_usecases.dart';
import '../config/env_config.dart';

final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

final supabaseAuthDataSourceProvider = Provider<SupabaseAuthDataSource>((ref) {
  return SupabaseAuthDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseAuthDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final requestPasswordResetUseCaseProvider =
    Provider<RequestPasswordResetUseCase>((ref) {
      return RequestPasswordResetUseCase(ref.watch(authRepositoryProvider));
    });

final certificateDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref
      .watch(envConfigProvider)
      .apiBaseUrl
      .replaceAll(RegExp(r'/api/v1/?$'), '');
  return Dio(BaseOptions(baseUrl: baseUrl));
});

final certificateDataSourceProvider = Provider<CertificateRemoteDataSource>((
  ref,
) {
  return CertificateRemoteDataSource(ref.watch(certificateDioProvider));
});

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(ref.watch(certificateDataSourceProvider));
});

final invoiceRemoteDataSourceProvider = Provider<InvoiceRemoteDataSource>((
  ref,
) {
  return InvoiceRemoteDataSource(ref.watch(networkClientProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(ref.watch(invoiceRemoteDataSourceProvider));
});

final getInvoicesUseCaseProvider = Provider<GetInvoicesUseCase>((ref) {
  return GetInvoicesUseCase(ref.watch(invoiceRepositoryProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(networkClientProvider));
});

final getMyProfileUseCaseProvider = Provider<GetMyProfileUseCase>((ref) {
  return GetMyProfileUseCase(ref.watch(profileRepositoryProvider));
});

final subscriptionRemoteDataSourceProvider =
    Provider<SubscriptionRemoteDataSource>((ref) {
      return SubscriptionRemoteDataSourceImpl(ref.watch(networkClientProvider));
    });

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRemoteDataSourceProvider),
  );
});

final getSubscriptionsUseCaseProvider = Provider<GetSubscriptionsUseCase>((
  ref,
) {
  return GetSubscriptionsUseCase(ref.watch(subscriptionRepositoryProvider));
});

final createCheckoutUseCaseProvider = Provider<CreateCheckoutUseCase>((ref) {
  return CreateCheckoutUseCase(ref.watch(subscriptionRepositoryProvider));
});

final cancelSubscriptionUseCaseProvider = Provider<CancelSubscriptionUseCase>((
  ref,
) {
  return CancelSubscriptionUseCase(ref.watch(subscriptionRepositoryProvider));
});

final getCheckoutStatusUseCaseProvider = Provider<GetCheckoutStatusUseCase>((
  ref,
) {
  return GetCheckoutStatusUseCase(ref.watch(subscriptionRepositoryProvider));
});

final syncQueueRepositoryProvider = Provider<QueueRepository>((ref) {
  return SQLiteQueueRepository();
});

final teacherCourseRemoteDataSourceProvider =
    Provider<ITeacherCourseRemoteDataSource>((ref) {
      return TeacherCourseRemoteDataSource(
        ref.watch(networkClientProvider),
        ref.watch(supabaseClientProvider),
      );
    });

final teacherCourseRepositoryProvider = Provider<ITeacherCourseRepository>((
  ref,
) {
  return TeacherCourseRepositoryImpl(
    ref.watch(teacherCourseRemoteDataSourceProvider),
  );
});

final teacherCourseUseCasesProvider = Provider<TeacherCourseUseCases>((ref) {
  return TeacherCourseUseCases(ref.watch(teacherCourseRepositoryProvider));
});
