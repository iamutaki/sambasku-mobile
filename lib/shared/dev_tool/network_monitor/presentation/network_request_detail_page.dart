import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../data/models/network_request_record.dart';

class NetworkRequestDetailPage extends StatelessWidget {
  const NetworkRequestDetailPage({super.key, required this.record});

  final NetworkRequestRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${record.method} ${record.path}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Copy cURL',
            icon: Icon(FLucideIcons.terminal),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _buildCurl()));
              showFToast(
                context: context,
                variant: FToastVariant.primary,
                icon: const Icon(FLucideIcons.copy, size: 16),
                title: const Text('cURL copied to clipboard'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FTabs(
          expands: true,
          children: [
            FTabEntry.entry(
              label: const Text('Summary'),
              child: _buildSummary(context),
            ),
            FTabEntry.entry(
              label: const Text('Request'),
              child: _buildRequest(context),
            ),
            FTabEntry.entry(
              label: const Text('Response'),
              child: _buildResponse(context),
            ),
          ],
        ),
      ),
    );
  }

  String _buildCurl() {
    final buffer = StringBuffer("curl --request ${record.method}");

    for (final entry in record.requestHeaders.entries) {
      buffer.write(" \\\n  --header '${entry.key}: ${entry.value}'");
    }

    final body = record.requestBody;
    if (body != null && body.isNotEmpty) {
      if (body.startsWith('[FormData]')) {
        buffer.write(" \\\n  --form '...'  # multipart/form-data");
      } else {
        buffer.write(" \\\n  --data '${body.replaceAll("'", "\\'")}'");
      }
    }

    buffer.write(" \\\n  '${record.url}'");
    return buffer.toString();
  }

  Widget _buildSummary(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'URL', value: record.url),
          _Row(label: 'Status', value: record.statusCode?.toString() ?? '-'),
          _Row(label: 'Duration', value: '${record.durationMs ?? '-'} ms'),
          _Row(label: 'Started', value: record.startedAt.toIso8601String()),
          _Row(label: 'Finished', value: record.finishedAt?.toIso8601String() ?? '-'),
          if (record.errorMessage != null) ...[
            const Gap(8),
            _Block(title: 'Error', content: record.errorMessage!, isError: true),
          ],
        ],
      ),
    );
  }

  Widget _buildRequest(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(title: 'Query Parameters', content: _formatMap(record.queryParameters)),
          const Gap(8),
          _Block(title: 'Request Headers', content: _formatMap(record.requestHeaders)),
          const Gap(8),
          _buildRequestBody(),
        ],
      ),
    );
  }

  Widget _buildResponse(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(title: 'Response Headers', content: _formatMap(record.responseHeaders)),
          const Gap(12),
          _Block(title: 'Response Body', content: record.responseBody ?? '-'),
        ],
      ),
    );
  }

  Widget _buildRequestBody() {
    final body = record.requestBody;
    if (body == null) return _Block(title: 'Request Body', content: '-');

    final isFormData = body.startsWith('[FormData]');
    return _Block(
      title: 'Request Body',
      content: isFormData ? body.substring('[FormData]\n'.length) : body,
      labelBadge: isFormData ? 'multipart/form-data' : null,
    );
  }

  String _formatMap(Map<String, String> values) {
    if (values.isEmpty) return '-';
    return values.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.content,
    this.isError = false,
    this.labelBadge,
  });

  final String title;
  final String content;
  final bool isError;
  final String? labelBadge;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: isError
            ? theme.colors.destructive.withValues(alpha: 0.08)
            : theme.colors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? theme.colors.destructive.withValues(alpha: 0.3)
              : theme.colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (labelBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    labelBadge!,
                    style: theme.typography.xs.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: theme.colors.primary,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isError ? theme.colors.destructive : theme.colors.mutedForeground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  showFToast(
                    context: context,
                    variant: FToastVariant.primary,
                    icon: const Icon(FLucideIcons.copy, size: 16),
                    title: Text('$title copied'),
                  );
                },
                child: Icon(FLucideIcons.copy, size: 12, color: theme.colors.mutedForeground),
              ),
            ],
          ),
          const Gap(4),
          SelectableText(
            content,
            style: theme.typography.xs.copyWith(
              height: 1.4,
              color: isError ? theme.colors.destructive : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.typography.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Gap(6),
          Expanded(
            child: SelectableText(value, style: theme.typography.xs),
          ),
        ],
      ),
    );
  }
}
