import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveform_designer/state/designer/designer.state.dart';
import 'package:waveform_designer/state/waveform/waveform.state.dart';
import 'package:waveform_designer/theme/AppTheme.dart';
import 'package:waveform_designer/widgets/designer/chart/WaveFormPainter.dart';

class PanIndicator extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PanIndicator();
}

class _PanIndicator extends ConsumerState {
  bool _isHovering = true;

  void _toggleHover() {
    setState(() {
      _isHovering = !_isHovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var waveformState = ref.watch(waveFormStateProvider);
        var designerState = ref.watch(designerStateProvider);
        var widgetWidth = constraints.maxWidth;
        var width = designerState.sliceRatio * widgetWidth;
        var leftOffset = designerState.sliceOffset * widgetWidth;

        return Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              height: 54,
              width: widgetWidth,
              color: AppTheme.lightShade,
            ),
            Container(
              height: 54,
              width: double.infinity,
              child: CustomPaint(
                painter: WaveFormPainter(
                  duration: waveformState.duration,
                  transitionPoints: waveformState.transitionPoints,
                  slice: 1.0,
                  offset: 0.0,
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(leftOffset, 0),
              child: MouseRegion(
                onEnter: (_) => _toggleHover,
                onExit: (_) => _toggleHover,
                cursor: _isHovering
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    var delta = details.delta.dx / widgetWidth;
                    ref
                        .read(designerStateProvider.notifier)
                        .updatePanOffset(delta);
                  },
                  child: Container(
                    height: 54,
                    width: width,
                    color: AppTheme.darkShade.withAlpha(118),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
