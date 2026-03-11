import '../../../core/state/async_state.dart';

/// Login Feature에서 사용하는 State 타입 alias.
///
/// 실제 구현은 core/state/async_state.dart의 AsyncState를 사용한다.
/// Feature 레벨에서 상태 타입을 명확하게 하기 위해 alias를 둔다.
typedef LoginState = AsyncState<void>;
