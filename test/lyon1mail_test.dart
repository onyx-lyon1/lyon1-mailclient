import 'package:dotenv/dotenv.dart';
import 'package:lyon1mail/lyon1mail.dart';
import 'package:test/test.dart';

void main() {
  late Lyon1Mail mailClient;
  DotEnv env = DotEnv(includePlatformEnvironment: true);

  Future<bool> sendDummyMail(final String recipientEmail) async {
    await mailClient.login();
    return await mailClient.sendEmail(
      sender: Address(env['EMAIL']!, 'nom de test'),
      recipients: [
        Address(recipientEmail, 'nom de test 2'),
      ],
      subject: 'test',
      body: 'bodytest',
    );
  }

  late String username;
  late String password;
  late String emailAddress;
  setUpAll(() {
    env.load();

    username = env['USERNAME'] ?? "";
    password = env['PASSWORD'] ?? "";
    emailAddress = env['EMAIL'] ?? "";

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }

    mailClient = Lyon1Mail(username, password);
  });

  test('login then logout', () async {
    await mailClient.login();
    await mailClient.logout();
  });

  test('fetchMessages 10 emails while being logged in', () async {
    await mailClient.login();
    final List<Mail> mails = (await mailClient.fetchMessages(10)) ?? [];
    expect(mails.length, equals(10));
    await mailClient.logout();
  });

  test('fetch 10 messages without being logged in', () async {
    expect((await mailClient.fetchMessages(10)) == null, equals(true));
  });

  test('toggle read status of latest email', () async {
    await mailClient.login();
    final List<Mail> mails = (await mailClient.fetchMessages(10)) ?? [];

    final bool isFirstMailSeen = mails.first.isSeen;

    if (isFirstMailSeen) {
      await mailClient.markAsUnread(mails.first.getSequenceId!);
    } else {
      await mailClient.markAsRead(mails.first.getSequenceId!);
    }

    expect(((await mailClient.fetchMessages(10)) ?? []).first.isSeen,
        !isFirstMailSeen);

    if (isFirstMailSeen) {
      await mailClient.markAsRead(mails.first.getSequenceId!);
    } else {
      await mailClient.markAsUnread(mails.first.getSequenceId!);
    }

    await mailClient.logout();
  });

  test('toggle flag status of latest email', () async {
    await mailClient.login();
    final List<Mail> mails = (await mailClient.fetchMessages(10)) ?? [];

    final bool isFirstMailFlaged = mails.first.isFlagged;

    if (isFirstMailFlaged) {
      await mailClient.unmarkAsFlagged(mails.first.getSequenceId!);
    } else {
      await mailClient.markAsFlagged(mails.first.getSequenceId!);
    }

    expect(((await mailClient.fetchMessages(10)) ?? []).first.isFlagged,
        !isFirstMailFlaged);

    if (isFirstMailFlaged) {
      await mailClient.markAsFlagged(mails.first.getSequenceId!);
    } else {
      await mailClient.unmarkAsFlagged(mails.first.getSequenceId!);
    }

    await mailClient.logout();
  });

  test('send one email to self', () async {
    await sendDummyMail(emailAddress);

    await mailClient.login();
    final List<Mail> mailsBeforeDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsBeforeDeletion.isNotEmpty, true);

    final int latestMessageId = mailsBeforeDeletion.first.getSequenceId!;
    await mailClient.delete(latestMessageId);

    final List<Mail> mailsAfterDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsAfterDeletion.isNotEmpty, true);
    expect(mailsAfterDeletion.first.getSequenceId != latestMessageId, true);
    await mailClient.logout();
  });

  test('send one email to another person', () async {
    await sendDummyMail(env['OTHER_EMAIL']!);
  });

  test('reply one email to self', () async {
    await sendDummyMail(emailAddress);

    await mailClient.login();
    final List<Mail> mailsBeforeDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsBeforeDeletion.isNotEmpty, true);

    final bool responseStatus = await mailClient.reply(
      originalMessageId: mailsBeforeDeletion.first.getSequenceId!,
      body: "response body",
      subject: "response subject",
      replyAll: false,
    );

    expect(responseStatus, true);

    final int latestMessageId = mailsBeforeDeletion.first.getSequenceId!;
    await mailClient.delete(latestMessageId);

    final List<Mail> mailsAfterDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsAfterDeletion.isNotEmpty, true);
    expect(mailsAfterDeletion.first.getSequenceId == latestMessageId, true);
    expect(
        mailsAfterDeletion.first.getBody(excerpt: false).contains(
            mailsBeforeDeletion.first.getBody(excerpt: false).substring(
                0, mailsBeforeDeletion.first.getBody().length - 1)), //remove \r
        true);
    await mailClient.logout();
  });

  test('resolve contact', () async {
    await mailClient.login();
    Address? email = (await mailClient.resolveContact(username)).first;
    expect(email.email, emailAddress);
  });

  test('delete latest email', () async {
    await sendDummyMail(
        emailAddress); // to make sure we dont delete important mails :)

    await mailClient.login();
    final List<Mail> mailsBeforeDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsBeforeDeletion.isNotEmpty, true);

    final int latestMessageId = mailsBeforeDeletion.first.getSequenceId!;
    await mailClient.delete(latestMessageId);

    final List<Mail> mailsAfterDeletion =
        (await mailClient.fetchMessages(1)) ?? [];
    expect(mailsAfterDeletion.isNotEmpty, true);
    expect(mailsAfterDeletion.first.getSequenceId != latestMessageId, true);
    await mailClient.logout();
  });
}
