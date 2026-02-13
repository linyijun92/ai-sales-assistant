import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/api_service.dart';

part 'reports_screen.g.dart';

@riverpod
class ReportsState extends _$ReportsState {
  int _selectedTabIndex = 0;
  Map<String, dynamic>? _dailyReport;
  bool _isLoading = false;

  int get selectedTabIndex => _selectedTabIndex;
  Map<String, dynamic>? get dailyReport => _dailyReport;
  bool get isLoading => _isLoading;

  void selectTab(int index) {
    _selectedTabIndex = index;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setLoading(bool value) {
    _isLoading = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setDailyReport(Map<String, dynamic>? value) {
    _dailyReport = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    ref.read(reportsStateProvider.notifier).setLoading(true);

    try {
      // TODO: 调用真实的 API
      // 暂时返回模拟数据
      await Future.delayed(const Duration(seconds: 1));
      
      final mockReport = {
        'date': '2026-02-12',
        'summary': '今日共跟进 15 位客户，完成 3 次试驾',
        'content': '''
# 每日数据整理报告 - 2026-02-12

## 今日重点客户

1. **张三** (高意向)
   - 车型：Model Y
   - 状态：已预约试驾
   - 跟进记录：今日电话沟通，客户对价格敏感

2. **李四** (中意向)
   - 车型：Model 3
   - 状态：跟进中
   - 跟进记录：发送了车型对比资料

## 试驾情况汇总

- **试驾总人数**：3 人
- **车型分布**：
  - Model Y: 2 人
  - Model 3: 1 人

## 客户反馈汇总

1. Model Y 空间宽敞，驾驶体验好
2. Model 3 操控性优秀，价格更亲民
3. 希望能有更多优惠活动

## 待跟进提醒

超过 7 天未联系的客户：
1. **王五** (上次联系：2026-02-05)
2. **赵六** (上次联系：2026-02-03)

## 跟进建议

1. 高意向客户：重点跟进试驾后反馈，尽快促成交易
2. 中意向客户：发送更多车型对比资料，安排试驾
3. 低意向客户：定期保持联系，建立信任
        ''',
      };
      
      ref.read(reportsStateProvider.notifier).setDailyReport(mockReport);
    } catch (e) {
      _showError('加载报告失败: ${e.toString()}');
    } finally {
      ref.read(reportsStateProvider.notifier).setLoading(false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsStateProvider);

    return Scaffold(
      body: Column(
        children: [
          // Tab 切换
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      title: '每日报告',
                      isSelected: state.selectedTabIndex == 0,
                      onTap: () => ref.read(reportsStateProvider.notifier).selectTab(0),
                    ),
                  ),
                  Expanded(
                    child: _buildTab(
                      title: '试驾日报',
                      isSelected: state.selectedTabIndex == 1,
                      onTap: () => ref.read(reportsStateProvider.notifier).selectTab(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 报告内容
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.selectedTabIndex == 0
                    ? _buildDailyReport(context, state.dailyReport)
                    : _buildTestDriveReport(context, state.dailyReport),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyReport(BuildContext context, Map<String, dynamic>? report) {
    if (report == null) {
      return const Center(child: Text('没有可用的报告'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 报告日期
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '报告日期',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(report['date'] ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 摘要
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(report['summary'] ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          
          // 详细内容
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(report['content'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDriveReport(BuildContext context, Map<String, dynamic>? report) {
    // 暂时显示占位内容
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('试驾日报功能开发中...'),
      ),
    );
  }
}
