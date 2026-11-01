import SwiftUI

/// 「更多」Tab：品牌头部 + 全部二级功能入口。
///
/// 导航统一用 `NavigationLink(value:)` + `navigationDestination(for:)`，
/// 目标类型是 `MoreDestination`，全 App 只注册一次。
struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    MoreBrandHeader()
                        .listRowSeparator(.hidden)
                }

                Section("模型与日志") {
                    NavigationLink(value: MoreDestination.models) {
                        MoreEntryRow(
                            title: "模型",
                            subtitle: "模型目录与能力",
                            systemImage: "square.stack.3d.up"
                        )
                    }
                    NavigationLink(value: MoreDestination.logs) {
                        MoreEntryRow(
                            title: "日志",
                            subtitle: "实时日志与错误汇总",
                            systemImage: "text.alignleft"
                        )
                    }
                }

                Section("资源") {
                    NavigationLink(value: MoreDestination.packages) {
                        MoreEntryRow(
                            title: "礼包",
                            subtitle: "按账号分组的礼包明细",
                            systemImage: "gift"
                        )
                    }
                    NavigationLink(value: MoreDestination.vouchers) {
                        MoreEntryRow(
                            title: "券码",
                            subtitle: "可用券码一览",
                            systemImage: "ticket"
                        )
                    }
                    NavigationLink(value: MoreDestination.compensation) {
                        MoreEntryRow(
                            title: "补偿",
                            subtitle: "查看并一键领取补偿",
                            systemImage: "arrow.uturn.backward.circle"
                        )
                    }
                }

                Section("关于") {
                    NavigationLink(value: MoreDestination.about) {
                        MoreEntryRow(
                            title: "开源",
                            subtitle: "仓库、构建与反馈渠道",
                            systemImage: "chevron.left.forwardslash.chevron.right"
                        )
                    }
                }

                Section("系统") {
                    NavigationLink(value: MoreDestination.config) {
                        MoreEntryRow(
                            title: "配置",
                            subtitle: "面板全字段配置",
                            systemImage: "slider.horizontal.3"
                        )
                    }
                    NavigationLink(value: MoreDestination.login) {
                        MoreEntryRow(
                            title: "登录",
                            subtitle: "扫码授权 / API Key 添加账号",
                            systemImage: "person.badge.key"
                        )
                    }
                    NavigationLink(value: MoreDestination.importAccounts) {
                        MoreEntryRow(
                            title: "导入账号",
                            subtitle: "从 Cockpit 导出文件批量导入",
                            systemImage: "square.and.arrow.down"
                        )
                    }
                    NavigationLink(value: MoreDestination.settings) {
                        MoreEntryRow(
                            title: "设置",
                            subtitle: "服务器、密钥与测试连接",
                            systemImage: "gearshape"
                        )
                    }
                }
            }
            .navigationTitle("更多")
            .navigationDestination(for: MoreDestination.self) { destination in
                switch destination {
                case .models: ModelsView()
                case .logs: LogsView()
                case .packages: PackagesView()
                case .vouchers: VouchersView()
                case .compensation: CompensationView()
                case .config: ConfigView()
                case .login: LoginView()
                case .importAccounts: ImportAccountsView()
                case .settings: SettingsView()
                case .about: AboutView()
                }
            }
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(SessionStore())
}
