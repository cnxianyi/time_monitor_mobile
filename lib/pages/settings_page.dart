import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:time_monitor_mobile/utils/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dailyTimeController = TextEditingController();
  final _weeklyTimeController = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // 设置初始值 - 只加载用户名
    _usernameController.text = AppSettings.username;

    // 如果有用户名，则获取时间限制设置
    if (AppSettings.username.isNotEmpty) {
      _fetchTimeSettings();
    } else {
      setState(() {
        _isLoading = false;
        // 使用默认值
        _dailyTimeController.text = '120';
        _weeklyTimeController.text = '840';
      });
    }
  }

  // 从API获取时间限制设置
  Future<void> _fetchTimeSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final username = AppSettings.username;
      final response = await http.get(
        Uri.parse('https://tms.xianyiapi.eu.org/limit?userName=$username'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // 假设API返回的数据格式包含 dailyTime 和 everyTime 字段
          _dailyTimeController.text =
              (data['data']['dailyLimit'] / 60).toStringAsFixed(0) ?? '120';
          _weeklyTimeController.text =
              (data['data']['everyLimit'] / 60).toStringAsFixed(0) ?? '840';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '获取设置失败: ${response.statusCode}';
          _isLoading = false;
          // 使用默认值
          _dailyTimeController.text = '120';
          _weeklyTimeController.text = '840';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '获取设置出错: $e';
        _isLoading = false;
        // 使用默认值
        _dailyTimeController.text = '120';
        _weeklyTimeController.text = '840';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _dailyTimeController.dispose();
    _weeklyTimeController.dispose();
    super.dispose();
  }

  // 保存设置
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // 检查用户名是否为空
      final username = _usernameController.text.trim();
      if (username.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请先输入用户名')));
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        // 保存用户名到本地
        AppSettings.username = username;
        await AppSettings.saveSettings();

        // 如果密码不为空，则发送设置到服务器
        final password = _passwordController.text.trim();
        if (password.isNotEmpty) {
          final todayTime = int.tryParse(_dailyTimeController.text) ?? 120;
          final dailyTime = int.tryParse(_weeklyTimeController.text) ?? 840;

          // 发送设置到服务器
          final response = await http.post(
            Uri.parse('https://tms.xianyiapi.eu.org/edit/time'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'dailyTime': todayTime * 60,
              'everyTime': dailyTime * 60,
            }),
          );

          if (response.statusCode == 200) {
            // 保存成功
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置已保存')));
            }
          } else {
            // 保存失败
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('同步失败: ${response.statusCode}')),
              );
            }
          }
        } else {
          // 只保存了用户名
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('未设置密码')));
          }
        }
      } catch (e) {
        // 显示错误提示
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // 错误消息显示
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // 用户名输入框
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '输入您的用户名',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入用户名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 密码输入框
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '密码',
                        hintText: '输入您的密码',
                        border: OutlineInputBorder(),
                        helperText: '需要密码才',
                      ),
                      validator: (value) {
                        // 密码可以为空，因为不是必须的
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 今日时间限制
                    TextFormField(
                      controller: _dailyTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '今日时间限制（分钟）',
                        hintText: '例如: 120',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入今日时间限制';
                        }
                        if (int.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 每日时间限制
                    TextFormField(
                      controller: _weeklyTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '每日时间限制（分钟）',
                        hintText: '例如: 840',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入每日时间限制';
                        }
                        if (int.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 提交按钮
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('保存设置', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
