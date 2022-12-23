# A mail client for Lyon1
Reliably fetch emails from https://mail.univ-lyon1.fr

![test result](https://github.com/onyx-lyon1/lyon1-mailclient/actions/workflows/dart.yml/badge.svg)

## Example
```dart
final Lyon1Mail mailClient = Lyon1Mail("p1234567", "a_valid_password");

if (!await mailClient.login()) {
    // handle gracefully
}

final List<Mail>? emailOpt = await mailClient.fetchMessages(15);
if (emailOpt == null || emailOpt.isEmpty) {
    // No emails
}

for (final Mail mail in emailOpt) {
    print("${mail.getSender()} sent ${mail.getSubject()} @${mail.getDate().toIso8601String()}");
    print("\tseen: ${mail.isSeen()}");
    print("\t${mail.getBody(excerpt: true, excerptLength: 50)}");
    print("\thasPJ: ${mail.hasAttachments()}");
    mail.getAttachmentsNames().forEach((fname) {
        print("\t\t$fname");
    });
}

await mailClient.logout();
```

## Tests
In your `test` folder, create a `.env` file containing the following:
```
    username: change me
    password: change_me
    email: p1234567@etu.univ-lyon1.fr
```
