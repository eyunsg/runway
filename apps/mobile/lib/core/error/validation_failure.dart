import 'failure.dart';

abstract class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class EmailFailure extends ValidationFailure {
  const EmailFailure(super.message);
}

class PasswordFailure extends ValidationFailure {
  const PasswordFailure(super.message);
}

class DisplayNameFailure extends ValidationFailure {
  const DisplayNameFailure(super.message);
}

class PortfolioValidationFailure extends ValidationFailure {
  const PortfolioValidationFailure(super.message);
}

class EmptyAssetsFailure extends PortfolioValidationFailure {
  const EmptyAssetsFailure(super.message);
}

class InvalidAssetFailure extends PortfolioValidationFailure {
  const InvalidAssetFailure(super.message);
}
