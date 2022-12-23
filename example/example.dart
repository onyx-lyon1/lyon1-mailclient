import 'package:lyon1mail/lyon1mail.dart';

void main() async {
  final Lyon1Mail mailClient = Lyon1Mail("p1234567", "a_valid_password");

  if (!await mailClient.login()) {
    // handle gracefully
  }

  final List<Mail>? emailOpt = await mailClient.fetchMessages(15);
  if (emailOpt == null || emailOpt.isEmpty) {
    // No emails
  }

  for (final Mail mail in emailOpt!) {
    print(
        "${mail.getSender} sent ${mail.getSubject} @${mail.getDate.toIso8601String()}");
    print("\tseen: ${mail.isSeen}");
    print("\t${mail.getBody(excerpt: true, excerptLength: 50)}");
    print("\thasPJ: ${mail.hasAttachments}");
    for (var fname in mail.getAttachmentsNames) {
      print("\t\t$fname");
    }
  }

  await mailClient.logout();
}
