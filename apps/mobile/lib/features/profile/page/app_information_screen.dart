import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:runway/core/theme/app_colors.dart';
import 'package:runway/core/theme/app_typography.dart';

class AppInformationScreen extends StatefulWidget {
  const AppInformationScreen({super.key});

  @override
  State<AppInformationScreen> createState() => _AppInformationScreenState();
}

class _AppInformationScreenState extends State<AppInformationScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = packageInfo.version;
    });
  }

  Future<void> _showPlaceholderDialog(String title) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('준비 중입니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.natural.backgroundColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.natural.backgroundColors.primary,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Image.asset(
                  'icons/arrow_left.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          '앱 정보',
          style: AppTypography.heading.h4.copyWith(
            color: AppColors.natural.textColors.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showPlaceholderDialog('이용약관');
              },
              title: Text(
                '이용약관',
                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),
              ),
              trailing: Image.asset(
                'icons/arrow_right.png',
                width: 12,
                height: 12,
                color: AppColors.natural.textColors.secondary,
              ),
            ),
            Divider(
              color: AppColors.natural.textColors.disabled,
              thickness: 0.5,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showPlaceholderDialog('개인정보 처리방침');
              },
              title: Text(
                '개인정보 처리방침',
                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),
              ),
              trailing: Image.asset(
                'icons/arrow_right.png',
                width: 12,
                height: 12,
                color: AppColors.natural.textColors.secondary,
              ),
            ),
            Divider(
              color: AppColors.natural.textColors.disabled,
              thickness: 0.5,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Runway',
                  applicationVersion: _version.isEmpty ? null : _version,
                );
              },
              title: Text(
                '오픈소스 라이선스',
                style: AppTypography.body.m.copyWith(
                  color: AppColors.natural.textColors.primary,
                ),
              ),
              trailing: Image.asset(
                'icons/arrow_right.png',
                width: 12,
                height: 12,
                color: AppColors.natural.textColors.secondary,
              ),
            ),
            Divider(
              color: AppColors.natural.textColors.disabled,
              thickness: 0.5,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '버전 정보\n',
                      style: AppTypography.body.m.copyWith(
                        color: AppColors.natural.textColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: _version,
                      style: AppTypography.body.s.copyWith(
                        color: AppColors.natural.textColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
