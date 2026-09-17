import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import 'dev_tool_inspector.dart';

class DevToolPage extends StatefulWidget {
  const DevToolPage({
    super.key,
    required this.inspectors,
    this.onClose,
  });

  final List<DevToolInspector> inspectors;
  final VoidCallback? onClose;

  @override
  State<DevToolPage> createState() => _DevToolPageState();
}

class _DevToolPageState extends State<DevToolPage> {
  DevToolInspector? _activeInspector;

  void _close() {
    if (_activeInspector != null) {
      setState(() => _activeInspector = null);
    } else {
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspector = _activeInspector;

    return PopScope(
      canPop: inspector == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _activeInspector = null);
      },
      child: FScaffold(
        childPad: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _close,
                      child: Icon(
                        inspector != null
                            ? FLucideIcons.arrowLeft
                            : FLucideIcons.x,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        inspector?.name ?? 'Dev Tools',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (inspector != null) ...inspector.appBarActions ?? [],
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: inspector != null
                    ? Material(
                        type: MaterialType.transparency,
                        child: inspector.buildPage(context),
                      )
                    : widget.inspectors.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: widget.inspectors.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, indent: 64),
                            itemBuilder: (context, index) => _InspectorCard(
                              inspector: widget.inspectors[index],
                              onTap: () => setState(
                                () => _activeInspector =
                                    widget.inspectors[index],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectorCard extends StatelessWidget {
  const _InspectorCard({
    required this.inspector,
    required this.onTap,
  });

  final DevToolInspector inspector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: inspector.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(inspector.icon, color: inspector.color, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspector.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      inspector.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FLucideIcons.wrench,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const Gap(12),
          Text(
            'Belum ada inspector',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const Gap(4),
          Text(
            'Tambahkan DevToolInspector ke daftar inspectors',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
