
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../formatted_text.dart';
import 'message_state_indicator.dart';

class MessageText extends StatelessWidget {
  const MessageText({required this.message, this.foregroundColor, super.key});

  final Message message;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FormattedText(
              message.formattedContent,
              softWrap: true,
              maxLines: null,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: foregroundColor),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MessageStateIndicator(message: message, foregroundColor: foregroundColor,),
            ],
          ),
        ],
    );
  }
}