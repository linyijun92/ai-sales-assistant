import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/api_service.dart';

part 'customer_list_screen.g.dart';

@riverpod
class CustomerListState extends _$CustomerListState {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get customers => _customers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setLoading(bool value) {
    _isLoading = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setCustomers(List<Map<String, dynamic>> value) {
    _customers = value;
    state = DateTime.now().millisecondsSinceEpoch;
  }

  void setSearchQuery(String value) {
    _searchQuery = value.toLowerCase();
    state = DateTime.now().millisecondsSinceEpoch;
  }

  List<Map<String, dynamic>> get filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    
    return _customers.where((customer) {
      final name = (customer['name'] as String?).toLowerCase() ?? '';
      final phone = (customer['phone'] as String?).toLowerCase() ?? '';
      
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();
  }
}

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    ref.read(customerListStateProvider.notifier).setLoading(true);

    try {
      // TODO: 调用真实的 API
      // 暂时返回模拟数据
      await Future.delayed(const Duration(seconds: 1));
      
      final mockCustomers = [
        {
          'id': '1',
          'name': '张三',
          'phone': '138****8888',
          'carModel': 'Model Y',
          'intentLevel': 'high',
          'followupStage': '已预约试驾',
          'lastFollowup': '2026-02-11',
        },
        {
          'id': '2',
          'name': '李四',
          'phone': '139****6666',
          'carModel': 'Model 3',
          'intentLevel': 'medium',
          'followupStage': '跟进中',
          'lastFollowup': '2026-02-10',
        },
        {
          'id': '3',
          'name': '王五',
          'phone': '137****7777',
          'carModel': 'Model Y',
          'intentLevel': 'low',
          'followupStage': '初期接触',
          'lastFollowup': '2026-02-09',
        },
      ];
      
      ref.read(customerListStateProvider.notifier).setCustomers(mockCustomers);
    } catch (e) {
      _showError('加载客户列表失败: ${e.toString()}');
    } finally {
      ref.read(customerListStateProvider.notifier).setLoading(false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getIntentLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return '高意向';
      case 'medium':
        return '中意向';
      case 'low':
        return '低意向';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerListStateProvider);
    final filteredCustomers = state.filteredCustomers;

    return Scaffold(
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索客户姓名或电话',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                ref.read(customerListStateProvider.notifier).setSearchQuery(value);
              },
            ),
          ),
          
          // 客户列表
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCustomers.isEmpty
                    ? const Center(child: Text('没有找到客户'))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(customer['name'][0]),
                              ),
                              title: Text(customer['name'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer['phone'] ?? ''),
                                  Row(
                                    children: [
                                      const Icon(Icons.directions_car, size: 16),
                                      const SizedBox(width: 4),
                                      Text(customer['carModel'] ?? ''),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customer['intentLevel'] == 'high'
                                          ? Colors.green
                                          : customer['intentLevel'] == 'medium'
                                              ? Colors.orange
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getIntentLevelColor(customer['intentLevel']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(customer['lastFollowup'] ?? ''),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
