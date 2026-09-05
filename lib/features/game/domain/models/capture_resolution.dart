import 'game_state.dart';

/// Immutable result of resolving post-movement capture consequences.
///
/// [gameState] is the authoritative logical state after any captured opponent
/// tokens have already been returned to their yards. Presentation may animate
/// [capturedTokenIds] afterward but cannot change this result.
class CaptureResolution {
  CaptureResolution({
    required this.gameState,
    required this.movedTokenId,
    required Iterable<String> capturedTokenIds,
  }) : capturedTokenIds = List<String>.unmodifiable(capturedTokenIds);

  /// Authoritative logical state after capture consequences are applied.
  final GameState gameState;

  /// Stable ID of the token whose completed move triggered this resolution.
  final String movedTokenId;

  /// Opponent token IDs returned to yard by this resolution.
  final List<String> capturedTokenIds;

  /// Whether this post-move resolution captured at least one opponent token.
  bool get didCapture => capturedTokenIds.isNotEmpty;
}
