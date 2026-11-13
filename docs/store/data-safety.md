# Data safety (Google Play) and privacy details (App Store)

What the patient app collects, for the store forms. Keep it in step with the
code: a change that collects something new updates this file in the same pull
request.

All data travels over HTTPS. The patient can delete the account, and with it
the data, from the app (Account → Delete account) or from the public
account-deletion page.

| Data | Examples | Why | Shared with |
|---|---|---|---|
| Account details | name, phone number, username, patient code | sign-in, the nutritionist knowing who the patient is | the patient's nutritionist |
| Demographics | gender | wording, plan design | the patient's nutritionist |
| Health information | weight and body measurements, conditions, allergies, medications, sleep, stress and mood entries | the meal plan and follow-up | the patient's nutritionist |
| Medical documents | photos or PDFs of lab results and reports the patient chooses to upload | follow-up | the patient's nutritionist |
| Food and nutrition | meal logs, food likes and dislikes | adherence and follow-up | the patient's nutritionist |
| Messages and requests | quick requests, appointment notes, check-in answers | contact with the nutritionist | the patient's nutritionist |
| Appointments | type, time, channel | scheduling and reminders | the patient's nutritionist |
| Device identifiers | the push token (Firebase Cloud Messaging) | notifications | Google (Firebase) as processor |
| App settings | language, time zone, notification preferences | sending notifications at the right time and in the right language | none |
| Crash logs and diagnostics | the type of an error and its stack trace, app version, device model and OS version | finding and fixing crashes | Google (Firebase Crashlytics) as processor |

Not collected: location, contacts, advertising identifiers, browsing history,
payment details. The camera and photo library are used only when the patient
chooses to attach a medical report.

## Crash reports

Crash reports go to Firebase Crashlytics and are built to carry no patient
data (`lib/core/logging/crash_reporter.dart`):

- off in debug builds;
- no user identifier, no custom keys and no log lines are attached;
- an error is reported as its type and stack trace only; its message, which
  could quote a name, a note or a health value, stays on the device.

Crashlytics itself adds an installation id, the app version, the device model
and the OS version.

## Public pages

The store listings point to pages on the public website
(`https://frontend-nextjs-phi-ten.vercel.app`), which carry the language in the
first path segment:

- Privacy policy: `/ar/privacy` and `/en/privacy`
- Account deletion (required by Google Play): `/ar/account-deletion` and
  `/en/account-deletion`

Deleting the account is also possible inside the app, with the password.
