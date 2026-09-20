import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/async_loader.dart';
import '../../shared/widgets/confirm_action.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/message_user_button.dart';
import '../../shared/widgets/status_pill.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          title: 'Buyers',
          subtitle: 'All buyer accounts on the platform',
          actions: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search buyers...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
            ),
          ],
        ),
        Expanded(
          child: AsyncLoader<List<AdminUser>>(
            loader: AdminApiClient.fetchUsers,
            builder: (context, users, reload) {
              final filtered = _query.isEmpty
                  ? users
                  : users
                        .where(
                          (u) =>
                              u.name.toLowerCase().contains(_query) ||
                              u.email.toLowerCase().contains(_query),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return const EmptyState(message: 'No buyers found.');
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('NAME')),
                              DataColumn(
                                label: Text('CONTACT'),
                                columnWidth: FlexColumnWidth(),
                              ),
                              DataColumn(label: Text('ROLE')),
                              DataColumn(label: Text('ACCOUNT')),
                              DataColumn(label: Text('JOINED')),
                              DataColumn(label: Text('ACTIONS')),
                            ],
                            rows: [
                              for (final user in filtered)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        user.name.isEmpty ? '-' : user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            user.email,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                            ),
                                          ),
                                          Text(
                                            user.phone,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.warmTaupe,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Text(user.role.isEmpty ? '-' : user.role),
                                    ),
                                    DataCell(
                                      StatusPill.suspended(user.isSuspended),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat.yMMMd().format(
                                          user.createdAt,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MessageUserButton(userId: user.id),
                                          const SizedBox(width: 4),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: user.isSuspended
                                                  ? AppColors.trustGreen
                                                  : const Color(0xFFB3261E),
                                            ),
                                            onPressed: () => confirmAndRun(
                                              context,
                                              title: user.isSuspended
                                                  ? 'Unsuspend buyer?'
                                                  : 'Suspend buyer?',
                                              message: user.isSuspended
                                                  ? '${user.name} will regain access to the app.'
                                                  : '${user.name} will be blocked from the app immediately.',
                                              confirmLabel: user.isSuspended
                                                  ? 'Unsuspend'
                                                  : 'Suspend',
                                              destructive: !user.isSuspended,
                                              action: () => user.isSuspended
                                                  ? AdminApiClient.unsuspendProfile(
                                                      user.id,
                                                    )
                                                  : AdminApiClient.suspendProfile(
                                                      user.id,
                                                    ),
                                              onSuccess: reload,
                                            ),
                                            child: Text(
                                              user.isSuspended
                                                  ? 'Unsuspend'
                                                  : 'Suspend',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
