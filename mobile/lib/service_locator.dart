import 'package:get_it/get_it.dart';
import 'package:mobile/data/ai_assistant/repository/ai_repository_impl.dart';
import 'package:mobile/data/ai_assistant/source/ai_remote_datasource.dart';
import 'package:mobile/data/auth/repository/auth_repository_impl.dart';
import 'package:mobile/data/auth/source/auth_api_service.dart';  
import 'package:mobile/data/inventory/datasources/inventory_remote_datasource.dart';
import 'package:mobile/data/inventory/repositories/inventory_repository_impl.dart';
import 'package:mobile/data/product/repository/product_repository_impl.dart';
import 'package:mobile/data/product/source/product_remote_datasource.dart';
import 'package:mobile/data/trends/datasource/trends_remote_datasource.dart';
import 'package:mobile/data/trends/repositories/trends_repository_impl.dart';
import 'package:mobile/domain/ai_assistant/repository/ai_repository.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/domain/auth/usecases/get_user.dart';
import 'package:mobile/domain/auth/usecases/is_logged_in.dart';
import 'package:mobile/domain/auth/usecases/is_logged_out.dart';
import 'package:mobile/domain/auth/usecases/send_password_reset_email.dart';
import 'package:mobile/domain/auth/usecases/signin.dart';
import 'package:mobile/domain/auth/usecases/signup.dart';
import 'package:mobile/domain/inventory/repository/inventory_repository.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory.dart';
import 'package:mobile/domain/inventory/usecases/get_inventory_summary.dart';
import 'package:mobile/domain/inventory/usecases/get_stock_status.dart';
import 'package:mobile/domain/product/repository/product_repository.dart';
import 'package:mobile/domain/product/usecases/get_product_by_sku.dart';
import 'package:mobile/domain/product/usecases/get_product_usecase.dart';
import 'package:mobile/domain/product/usecases/update_product_quantity_usecase.dart';
import 'package:mobile/domain/trends/repositories/trends_repositories.dart';
import 'package:mobile/domain/trends/usecases/get_predictions.dart';
import 'package:mobile/domain/trends/usecases/get_trends.dart';
import 'package:mobile/domain/trends/usecases/run_scraper.dart';
import 'package:mobile/presentation/inventory/provider/inventory_provider.dart';
import 'package:mobile/presentation/product/provider/product_provider.dart';
import 'package:mobile/presentation/trends/provider/trends_provider.dart';

final sl = GetIt.instance;

const String mediaBaseUrl = "https://c6afc006918d.ngrok-free.app/media/";

Future<void> iniatializeServiceLocator() async {
  const baseUrl = "https://c6afc006918d.ngrok-free.app/api/";  // Updated to Django backend
  sl.registerSingleton<String>(mediaBaseUrl, instanceName: "mediaBaseUrl");


  // ========================
  //  AUTH
  // ========================

  // services
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(baseUrl),
  );
  
  // repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthApiService>()),
  );

  // usecases
  sl.registerSingleton<SignupUseCase>(
    SignupUseCase(),
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase(),
  );

  sl.registerSingleton<SendPasswordResetEmailUseCase>(
    SendPasswordResetEmailUseCase(),
  );

  sl.registerSingleton<IsLoggedInUseCase>(
    IsLoggedInUseCase(),
  );

  sl.registerSingleton<GetUserUseCase>(
    GetUserUseCase(),
  );

  sl.registerSingleton<LogoutUseCase>(
    LogoutUseCase(),
  );


  // ========================
  //  INVENTORY FEATURE
  // ========================

  // data sources
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(baseUrl),
  );

  // repositories
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(sl<InventoryRemoteDataSource>()),
  );

  // usecases
  sl.registerLazySingleton<GetInventory>(
    () => GetInventory(sl<InventoryRepository>()),
  );
  sl.registerLazySingleton<GetStockStatus>(
    () => GetStockStatus(),
  );

  sl.registerLazySingleton<GetInventorySummary>(
    () => GetInventorySummary(),
  );

  // providers (presentation)
  sl.registerFactory<InventoryProvider>(
    () => InventoryProvider(
      sl<GetInventory>(),
      sl<GetInventorySummary>(),
    ),
  );

  // ========================
  //  AI ASSISTANT
  // ========================

  // datasource
  sl.registerLazySingleton<AiRemoteDataSource>(() => AiRemoteDataSource(baseUrl));

  // repository
  sl.registerLazySingleton<AiRepository>(() => AiRepositoryImpl(sl<AiRemoteDataSource>()));


  // ========================
  //  PRODUCT FEATURE 
  // ========================

  // Data source
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(baseUrl: baseUrl),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl<ProductRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<UpdateProductQuantityUseCase>(
    () => UpdateProductQuantityUseCase(sl<ProductRepository>()),
  );

  
  sl.registerLazySingleton<GetProductBySku>(
    () => GetProductBySku(sl<ProductRepository>()),
  );

  // Provider
  sl.registerFactory<ProductProvider>(
    () => ProductProvider(
      getProductsUseCase: sl<GetProductsUseCase>(),
      updateQuantityUseCase: sl<UpdateProductQuantityUseCase>(),
    ),
  );


 // ========================
 // TRENDS FEATURE 
 // ========================

  // Data Source
  sl.registerLazySingleton<TrendsRemoteDataSource>(
    () => TrendsRemoteDataSourceImpl(baseUrl: baseUrl),
  );

  // Repository
  sl.registerLazySingleton<TrendsRepository>(
    () => TrendsRepositoryImpl(sl<TrendsRemoteDataSource>()),
  );

  // Usecases
  sl.registerLazySingleton<GetTrends>(
    () => GetTrends(sl<TrendsRepository>()),
  );
  sl.registerLazySingleton<GetPredictions>(
    () => GetPredictions(sl<TrendsRepository>()),
  );
  sl.registerLazySingleton<RunScraper>(
    () => RunScraper(sl<TrendsRepository>()),
  );

  // Provider
  sl.registerFactory<TrendsProvider>(
    () => TrendsProvider(
      getTrends: sl<GetTrends>(),
      getPredictions: sl<GetPredictions>(),
      runScraper: sl<RunScraper>(),
    ),
  );
}

