import '../../domain/models/token_move_transaction.dart';
import '../../domain/models/token_position.dart';

/// Presentation-only playback state for one committed token move.
///
/// The authoritative GameState is already final inside [transaction]. This
/// object only tracks which logical step the presentation should currently
/// display while input remains locked.
class TokenMovementPlayback {
  TokenMovementPlayback._({
    required this.transaction,
    required this.stepIndex,
  });

  /// Starts playback at the transaction's first visual movement step.
  factory TokenMovementPlayback.start(TokenMoveTransaction transaction) {
    if (transaction.steps.isEmpty) {
      throw ArgumentError.value(
        transaction,
        'transaction',
        'A movement transaction must contain at least one visual step.',
      );
    }

    return TokenMovementPlayback._(transaction: transaction, stepIndex: 0);
  }

  /// Committed movement transaction being presented.
  final TokenMoveTransaction transaction;

  /// Zero-based visual step currently displayed.
  final int stepIndex;

  /// Token whose visual movement is active.
  String get tokenId => transaction.tokenId;

  /// Current presentation-only logical position.
  TokenPosition get visualPosition => transaction.steps[stepIndex];

  /// Whether another intermediate/final visual step remains.
  bool get hasNextStep => stepIndex + 1 < transaction.steps.length;

  /// Input must remain unavailable for the full playback lifetime.
  bool get isInputLocked => true;

  /// Returns playback advanced by exactly one visual step.
  ///
  /// Returns this instance when already displaying the final step.
  TokenMovementPlayback advance() {
    if (!hasNextStep) {
      return this;
    }

    return TokenMovementPlayback._(
      transaction: transaction,
      stepIndex: stepIndex + 1,
    );
  }

  /// Presentation override consumed by LudoBoard/LudoTokenLayer.
  Map<String, TokenPosition> get visualPositionOverrides =>
      Map<String, TokenPosition>.unmodifiable({tokenId: visualPosition});
}
