import 'package:flutter/material.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_backend_scan.dart';
import 'package:phoenix/src/beginning/utilities/lyrics/lyrics_controller.dart';

/// Compact status indicator for backend lyrics scan / availability.
class LyricsScanStatusIcon extends StatelessWidget {
  final String trackPath;
  final double size;

  const LyricsScanStatusIcon({
    super.key,
    required this.trackPath,
    this.size = 22,
  });

  Color _color(LyricsScanStatus status) {
    switch (status) {
      case LyricsScanStatus.ready:
        return const Color(0xFF2ECC71);
      case LyricsScanStatus.running:
        return const Color(0xFF3498DB);
      case LyricsScanStatus.notFound:
      case LyricsScanStatus.failed:
        return const Color(0xFF95A5A6);
      case LyricsScanStatus.unknown:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData _icon(LyricsScanStatus status) {
    switch (status) {
      case LyricsScanStatus.ready:
        return Icons.lyrics;
      case LyricsScanStatus.running:
        return Icons.cloud_sync_outlined;
      case LyricsScanStatus.notFound:
        return Icons.lyrics_outlined;
      case LyricsScanStatus.failed:
        return Icons.error_outline;
      case LyricsScanStatus.unknown:
        return Icons.lyrics_outlined;
    }
  }

  void _showDetails(BuildContext context, LyricsScanState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.detailLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Raleway',
                  ),
                ),
                if (state.step.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Fortschritt: ${state.step}'
                    '${state.stepName.isNotEmpty ? ' — ${state.stepName}' : ''}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                if (state.error != null && state.error!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ],
                if (state.jobId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Job: ${state.jobId}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LyricsBackendScanQueue.inst,
      builder: (context, _) {
        var state = LyricsBackendScanQueue.inst.stateFor(trackPath);
        // Prefer green if controller already has synced lyrics.
        if (LyricsController.inst.isSynced &&
            LyricsController.inst.current.hasContent) {
          state = const LyricsScanState(status: LyricsScanStatus.ready);
        }
        return IconButton(
          tooltip: state.detailLabel,
          iconSize: size,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size + 8, height: size + 8),
          onPressed: () => _showDetails(context, state),
          icon: Icon(
            _icon(state.status),
            color: _color(state.status),
            size: size,
          ),
        );
      },
    );
  }
}
