#!/bin/bash

# Create directory structure
mkdir -p lib/core/constants
mkdir -p lib/core/di
mkdir -p lib/core/error
mkdir -p lib/core/network
mkdir -p lib/core/routing
mkdir -p lib/core/widgets
mkdir -p lib/features/auth/data/datasources
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/domain/usecases
mkdir -p lib/features/auth/presentation/providers
mkdir -p lib/features/auth/presentation/screens
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/registration/data/datasources
mkdir -p lib/features/registration/data/models
mkdir -p lib/features/registration/data/repositories
mkdir -p lib/features/registration/domain/entities
mkdir -p lib/features/registration/domain/repositories
mkdir -p lib/features/registration/domain/usecases
mkdir -p lib/features/registration/presentation/providers
mkdir -p lib/features/registration/presentation/screens
mkdir -p lib/features/registration/presentation/widgets
mkdir -p test/auth
mkdir -p test/registration

# Create empty Dart files
touch lib/core/constants/api_endpoints.dart
touch lib/core/constants/app_colors.dart
touch lib/core/constants/app_strings.dart
touch lib/core/di/injector.dart
touch lib/core/error/exceptions.dart
touch lib/core/error/failures.dart
touch lib/core/network/api_client.dart
touch lib/core/network/dio_config.dart
touch lib/core/routing/app_router.dart
touch lib/core/widgets/custom_button.dart
touch lib/core/widgets/custom_text_field.dart
touch lib/core/widgets/loading_indicator.dart
touch lib/features/auth/data/datasources/auth_remote_data_source.dart
touch lib/features/auth/data/models/user_model.dart
touch lib/features/auth/data/repositories/auth_repository_impl.dart
touch lib/features/auth/domain/entities/user.dart
touch lib/features/auth/domain/repositories/auth_repository.dart
touch lib/features/auth/domain/usecases/login.dart
touch lib/features/auth/domain/usecases/logout.dart
touch lib/features/auth/presentation/providers/auth_provider.dart
touch lib/features/auth/presentation/screens/login_screen.dart
touch lib/features/auth/presentation/screens/splash_screen.dart
touch lib/features/auth/presentation/widgets/login_form.dart
touch lib/features/registration/data/datasources/registration_remote_data_source.dart
touch lib/features/registration/data/models/member_model.dart
touch lib/features/registration/data/repositories/registration_repository_impl.dart
touch lib/features/registration/domain/entities/member.dart
touch lib/features/registration/domain/repositories/registration_repository.dart
touch lib/features/registration/domain/usecases/register_member.dart
touch lib/features/registration/presentation/providers/registration_provider.dart
touch lib/features/registration/presentation/screens/registration_screen.dart
touch lib/features/registration/presentation/widgets/registration_form.dart
touch lib/main.dart
touch test/auth/auth_repository_test.dart
touch test/registration/registration_repository_test.dart

echo "Project structure for 'salam' created successfully!"
