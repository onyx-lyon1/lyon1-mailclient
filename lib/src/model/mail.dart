import 'dart:math';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';

class Mail {
  final MimeMessage _originalMessage;

  Mail(this._originalMessage);

  MimeMessage get getOriginalMessage => _originalMessage;

  String get getSubject {
    return _originalMessage.decodeSubject() ?? "";
  }

  List<String> get getRecipients {
    const List<String> recipients = [];
    for (MailAddress m in _originalMessage.cc ?? []) {
      recipients.add(m.email);
    }
    return recipients;
  }

  String get getSender {
    return _originalMessage.fromEmail ?? "n/a";
  }

  String get getReceiver {
    String receiver = "";
    for (MailAddress i in _originalMessage.to!) {
      receiver += "${i.email}, ";
    }
    receiver = receiver.substring(0, receiver.length - 2);
    return receiver;
  }

  DateTime get getDate {
    return _originalMessage.decodeDate() ?? DateTime.now();
  }

  bool get isSeen {
    return _originalMessage.hasFlag(MessageFlags.seen);
  }

  bool get isFlagged {
    return _originalMessage.isFlagged;
  }

  bool get hasAttachments {
    return _originalMessage.hasAttachments();
  }

  int? get getSequenceId {
    return _originalMessage.sequenceId;
  }

  List<String> get getAttachmentsNames {
    final List<String> fileNames = [];
    final List<MimePart> parts = _originalMessage.allPartsFlat;
    for (final MimePart mp in parts) {
      if (mp.decodeFileName() != null) {
        fileNames.add(mp.decodeFileName() ?? "");
      }
    }
    return fileNames;
  }

  List<int> getAttachment(String fileName) {
    final List<MimePart> parts = _originalMessage.allPartsFlat;
    for (final MimePart mp in parts) {
      if (mp.decodeFileName() == fileName) {
        Uint8List? content = mp.decodeContentBinary();
        if (content == null) {
          throw Exception("Unable to get attachment");
        }
        return content.toList();
      }
    }
    throw Exception("Unable to get attachment");
  }

  String getBody({
    removeTrackingImages = false,
    excerpt = true,
    excerptLength = 100,
  }) {
    if (excerpt) {
      int length =
          _originalMessage.decodeTextPlainPart()?.replaceAll("\n", "").length ??
              0;
      int maxsubstr = min(length, excerptLength);
      return _originalMessage
              .decodeTextPlainPart()
              ?.replaceAll("\n", "")
              .substring(0, maxsubstr) ??
          "";
    } else {
      String? html = _originalMessage.decodeTextHtmlPart();
      if (removeTrackingImages) {
        html?.replaceAll(RegExp(r"img=.*>"), ">");
      }
      return html ?? (_originalMessage.decodeTextPlainPart() ?? "-");
    }
  }
}
