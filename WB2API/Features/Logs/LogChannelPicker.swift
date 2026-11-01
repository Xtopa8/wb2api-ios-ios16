import SwiftUI

/// 通道筛选：分段控件，触控高度对齐 44pt。
struct LogChannelPicker: View {
    @Binding var selection: LogChannel

    var body: some View {
        Picker("日志通道", selection: $selection) {
            ForEach(LogChannel.allCases) { channel in
                Text(channel.title).tag(channel)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .frame(minHeight: Metrics.minTap)
        .motion(Motion.spring, value: selection)
        .accessibilityLabel("日志通道")
    }
}
