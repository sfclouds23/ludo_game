import '../../domain/models/capture_resolution.dart';

/// Presentation-only playback state for an already-resolved capture.
///
/// The logical result is contained in [resolution.gameState] before playback
/// begins. Advancing or abandoning this object cannot change that state.
class CapturePlayback {
  CapturePlayback._({
    required this.resolution,
    required this.phase,
    required this.returnedTokenCount,
  });

  factory CapturePlayback.start(CaptureResolution resolution) {
    return CapturePlayback._(
      resolution: resolution,
      phase: resolution.didCapture
          ? CapturePlaybackPhase.impact
          : CapturePlaybackPhase.complete,
      returnedTokenCount: 0,
    );
  }

  final CaptureResolution resolution;
  final CapturePlaybackPhase phase;
  final int returnedTokenCount;

  bool get isComplete => phase == CapturePlaybackPhase.complete;
  bool get isInputLocked => !isComplete;

  List<String> get returnedTokenIds => List<String>.unmodifiable(
    resolution.capturedTokenIds.take(returnedTokenCount),
  );

  String? get currentReturningTokenId {
    if (phase != CapturePlaybackPhase.returningTokens ||
        returnedTokenCount >= resolution.capturedTokenIds.length) {
      return null;
    }

    return resolution.capturedTokenIds[returnedTokenCount];
  }

  CapturePlayback advance() {
    switch (phase) {
      case CapturePlaybackPhase.impact:
        return CapturePlayback._(
          resolution: resolution,
          phase: CapturePlaybackPhase.returningTokens,
          returnedTokenCount: 0,
        );
      case CapturePlaybackPhase.returningTokens:
        final nextReturnedCount = returnedTokenCount + 1;
        final isFinished =
            nextReturnedCount >= resolution.capturedTokenIds.length;

        return CapturePlayback._(
          resolution: resolution,
          phase: isFinished
              ? CapturePlaybackPhase.complete
              : CapturePlaybackPhase.returningTokens,
          returnedTokenCount: nextReturnedCount,
        );
      case CapturePlaybackPhase.complete:
        return this;
    }
  }
}

enum CapturePlaybackPhase { impact, returningTokens, complete }
