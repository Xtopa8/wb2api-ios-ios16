import SwiftUI

/// 任务作业列表：渲染 `tasks/jobs` 的 JSONValue，空态交给系统空视图。
struct JobListView: View {
    private let entries: [JobEntry]

    init(jobs: JSONValue?) {
        entries = (jobs ?? .null).rows.enumerated().map { offset, item in
            JobEntry(index: offset, value: item)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.s) {
            SectionHeader(title: "任务作业", subtitle: "\(entries.count) 项记录")

            if entries.isEmpty {
                WBEmptyState(
                    "暂无作业",
                    systemImage: "tray",
                    description: Text("队列空闲时不会生成作业记录")
                )
                .padding(.vertical, Metrics.l)
            } else {
                ForEach(entries) { entry in
                    JobCardView(entry: entry)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
