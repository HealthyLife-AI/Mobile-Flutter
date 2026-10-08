# HealthyLife AI — Flutter UI Skin

Implements the "Full Design & Motion System Prompt" tokens and every screen
flow visible in the shared Figma screenshots.

## Run
```
flutter pub get
flutter run
```
App boots: Splash (M1/M2/M3) → Onboarding → main shell (5 tabs: Home, Plan,
Foods, Progress, Profile) with a floating "تسجيل وجبة" button that opens the
log-meal flow (plan meal detail OR free food search → quantity → success).

## Structure
- `lib/core/theme` — AppColors / AppTextStyles / AppRadius / AppTheme:
  single source of truth for every token in section 2 of the spec.
- `lib/widgets` — reusable component library from section 7: GradientCtaButton,
  MacroPillBadge, SegmentedSlidingTabs, DateChipPicker, MetricStatBox +
  AnimatedNumberCounter (M8), MealCard, AnimatedBottomNavPill (M4),
  LiveMetricCard (M7), PulsingBreathingButton (M9).
- `lib/models/meal_models.dart` — mock data shaped like the `/me/meal-plan`
  and `/foods/search` API responses from the Mobile API Reference doc, so
  swapping in a real repository/BLoC layer later is a drop-in change.
- `lib/screens`:
  - `splash_screen.dart` — M1 pulse line, M2 logo reveal, M3 progress fill, floating particles
  - `onboarding_screen.dart` — 3-page swipe with sliding progress dots
  - `home_dashboard_screen.dart` — greeting header, daily progress, meal cards
  - `weekly_plan_screen.dart` — day picker (DateChipPicker) + macro summary + meal list
  - `meal_detail_screen.dart` — smart-swap ingredient picker (protein/carbs/veg groups)
  - `log_meal_intro_screen.dart` — branch: log from plan vs. log something off-plan
  - `food_search_screen.dart` — search + category chips + suggested foods
  - `quantity_selector_screen.dart` — grams stepper, quick amounts, fine-adjust slider
  - `meal_log_success_screen.dart` — M6 confetti burst + summary card
  - `plan_preparing_screen.dart` — "plan being prepared" empty/waiting state
  - `beetai_chat_screen.dart` — chat bubbles, typing indicator, ctaVoiceGradient send button
  - `progress_screen.dart` — time-range tabs, adherence/activity cards, comparative chart, LiveMetricCard
  - `profile_screen.dart` — account, AR/EN + theme segmented toggles, locked Health CV row
  - `achievements_screen.dart` — grid with M14 springy pulse on earned badges

## Notes / what's next
This covers the full flow shown in the screenshots plus the remaining
section-4/5 core screens (Splash, Onboarding, BeetAI Chat, Progress,
Profile, Achievements). Not yet built: Notifications Center, Barcode
Scanner, Health Sync, Sleep/Stress/Mood tracking (uses PulsingBreathingButton,
already built), Schedule/Accountability Calls, and real API wiring
(auth/refresh queue, idempotency_key on enqueue) per Mobile API Reference
section 9. Say the word and I'll add any of these next.

## Newest additions
- `notifications_center_screen.dart` — swipe-to-dismiss list, pulsing unread dot
- `barcode_scanner_screen.dart` — animated scan frame + light sweep
- `health_sync_screen.dart` — single rationale + connect button
- `sleep_stress_mood_screen.dart` — donut gauges + PulsingBreathingButton (M9)
- `schedule_calls_screen.dart` — DetailHeroHeader (M11) + StickyBottomBar (M12) + SegmentedSlidingTabs
- New shared widgets: DetailHeroHeader, StickyBottomBar, LockedFeatureOverlay

All reachable from the "حسابي" (Profile) tab and the food-search screen's
scan icon. Every screen in section 4/5 of the spec is now built. Remaining
work is real API wiring (auth/refresh, BLoC, idempotency queue) per Mobile
API Reference section 9 — say the word if you'd like that scaffolded next.

## Motion spec audit (M1–M15) — this pass fixed the gaps
An honest audit against the Motion Spec found 5 items under-implemented;
all are now complete:
- **M5** (chip selection): DateChipPicker and the food-search category
  chips now auto-scroll to center the tapped chip via `Scrollable.ensureVisible`,
  on top of the existing 200ms color cross-fade.
- **M10** (carousel entrance): new `HorizontalRecommendationCard` /
  `HorizontalRecommendationList` widgets give a one-time staggered
  Slide+Fade (70ms apart), wired into Home Dashboard's "وصفات مقترحة" row.
- **M11** (Hero + slide-up): `MealCard`'s icon and `MealDetailScreen`'s
  header icon now share a `Hero` tag per meal id, so tapping a meal card
  now genuinely flies the icon into the detail screen. Note: since the app
  shell keeps tabs alive via `IndexedStack`, only Home's MealCard enables
  the Hero (`enableHero: true` by default); Weekly Plan's instances pass
  `enableHero: false` to avoid a duplicate-tag crash — both screens
  render the same meal.id simultaneously once mounted.
- **M13** (quantity jump): QuantitySelectorScreen's +/- buttons now spawn
  a small "+10/-10" pill that scales in with `Curves.elasticOut` and flies
  from the tapped button toward the grams display before fading (380ms).
- **M15** (scroll fade): new `ScrollEdgeFade` widget wraps Home Dashboard's
  list with a `ShaderMask` edge-fade — cheaper than a per-item
  RenderBox/ScrollController listener and gives the same "items fade near
  the edges" effect.

M1–M4, M6–M9, M12, M14 were already implemented correctly in the previous
pass and were left untouched.

## v2 — Master Build Prompt EN corrections (this pass)
A newer, more precise design prompt (13 additional real screenshots)
corrected several things the earlier prompt got wrong or left vague:

- **Colors overhauled** (`app_colors.dart`): primary is now a confirmed
  SOLID color `#0B6B57`, not a gradient. New tokens: `primaryTint`,
  `neutralTrack` (progress-bar track only), `background #FAFAFB`,
  `textPrimary #15171A`, `textSecondary #7B828C`, `border`, `iconMuted`.
  `primaryGradient` is kept as a two-stop gradient of the *same* color so
  existing `gradient:` call sites didn't need a repo-wide edit.
- **Card radius corrected**: ~16–18px (was 24px).
- **M6 corrected — no confetti.** The prompt explicitly states "there is
  no confetti in the actual design." Replaced `SuccessConfettiScreen`'s
  burst with `SuccessGlowCheck` (calm gradient circle + settle glow),
  added `LiveUpdateBadge` (pulsing dot) and a real `AutoRedirectCountdown`
  (was static text before), and moved the CTA to a new `FullWidthActionBar`
  (a deliberate exception to the pill-button rule: less-rounded, no side
  margin, reserved for completing an entire flow).
- **M21 (achievements) corrected** to match the same "no confetti"
  philosophy: calm Scale+Fade (0.9→1.0, easeOut) with a soft glow that
  fades over 500ms, replacing the springy `elasticOut` bounce.
- **New substitution badges** (`substitution_badges.dart`): `CalorieDeltaBadge`
  ("+10 kcal" next to non-default alternatives), `DefaultOptionBadge`,
  `LockedCategoryBadge` (for a single-item, no-substitute group) — wired
  into `MealDetailScreen`'s option tiles, replacing ad-hoc inline badges.
  The M4 radio behavior was also corrected: selected = solid `primary`
  circle with a white ✓ (Scale, 200ms); unselected = empty circle with a
  light border — was previously green-tinted.
- **FoodTagColorMapper** (`app_colors.dart` + `food_tag_icon.dart`): search
  results are now colored by nutritional CATEGORY (redFruit, greenFruit,
  naturalSugar, dairy, cookedProtein, carb, nuts) — a system explicitly
  separate from the meal-type colors below, per the spec's own warning not
  to conflate them.
- **Meal-type icon colors added** (2.2): breakfast/lunch share an orange
  "daytime" family (distinguished by icon shape, not color), snack is
  green, dinner is indigo. `MealCard` and `MealDetailScreen` now share
  these via public helpers (`mealSlotBg`, `mealSlotIcon`, `mealSlotIconColor`
  in `meal_card.dart`) instead of each hardcoding orange.
- **ClinicalTrustFooter** added beneath every food-logging screen (Meal
  Detail, Food Search, Quantity Selector) per the spec's explicit privacy
  reassurance line.
- **Food Search screen reworked**: added the "Request a new item via
  WhatsApp" bottom sheet (M18, slide-up + scrim) and the "Estimate
  manually" button, both previously missing; results now fade/stagger in
  on filter change (M17) instead of snapping instantly.
- **BeetAI de-emphasized**: the spec leaves AI chat as "an open question,"
  with search + manual estimate as the *confirmed* baseline. Removed the
  BeetAI entry point from Home's header (replaced with the notifications
  bell, now actually wired up); `beetai_chat_screen.dart` is kept in the
  repo as a working prototype but is intentionally unlinked from any nav
  path until product confirms that flow.

## v3 — Measurements + Account section (13 new Figma screens)
New screens: `measurements_screen` (weight + trend chart distinguishing
clinic-verified rings vs home dots per BR-13, circumference grid, logging
streak), `measurement_entry_screen` (weight stepper + optional
circumference fields), `first_measurement_screen` (baseline established /
waiting for second point), `measurement_guide_screen` (4 body parts,
schematic CustomPainter illustrations), `specialist_profile_screen`,
`notification_settings_screen`, `password_settings_screen` (live strength
meter + rules checklist), `language_settings_screen`, `about_app_screen`;
`profile_screen` rebuilt as the "الحساب" screen.
New shared widgets: `SettingsRow`, `PasswordStrengthMeter`, `WeightTrendChart`.

### Code audit performed
- Brace/paren balance on all files; no duplicate public class names.
- Orphan check: every screen/widget is wired. `beetai_chat_screen` is
  intentionally unlinked (spec: open question). Two previously orphaned
  widgets (`MacroPillBadge`, `LockedFeatureOverlay`) are now used.
- Fixed a real layout-overflow risk (locked overlay taller than its child).
- Token references (`AppColors.*`, `AppTextStyles.*`, `AppRadius.*`, mock
  data) and named constructor params verified by script: 0 invalid.
- Removed unused imports; removed deprecated `ColorScheme.background`.
- Added `analysis_options.yaml` and unit tests (password strength, models).

### Known limitations (honest)
- No Flutter SDK was available here: `flutter analyze` / `flutter test`
  were NOT executed. Run both after `flutter pub get`.
- Language screen is UI-only (no real app-wide localization/RTL switch).
- Guide illustrations are schematic painters, not final artwork.

## v4 — Full patient journey (14 new Figma screens) + code audit

### New screens, in the order a patient actually experiences them
1. `splash_screen.dart` — now renders the real brand mark (`assets/images/logo.png`) instead of a placeholder icon.
2. `onboarding_screen.dart` — rebuilt as the 2-page marketing carousel with real photography (`onboarding_track.jpg`, `onboarding_plan.jpg`), "تخطي" and the final CTA both leading to activation.
3. **`activation_screen.dart`** *(new)* — the clinic-invite link landing page: specialist card, new/confirm password fields wired to the existing `PasswordStrengthMeter`, live rule checklist, activation only enabled once the password is strong and confirmed.
4. **`onboarding_measurements_screen.dart`** *(new)* — wizard step 1/3: mandatory baseline weight (+/- stepper) and optional waist/hip/thigh circumference, link out to the existing `MeasurementGuideScreen`.
5. **`onboarding_health_screen.dart`** *(new)* — wizard step 2/3: chronic-condition multi-select (≥1 required to continue), optional food-allergy multi-select, an editable medications list, and a free-text note to the specialist. Backed by the new `health_profile_models.dart`.
6. **`onboarding_notifications_screen.dart`** *(new)* — wizard step 3/3: the reminder-permission primer. Either "تفعيل الإشعارات الآن" or "ليس الآن" completes onboarding and lands on `AppShell`.
7. `AppShell` (unchanged) — the 5-tab home shell patients live in day to day.
8. **`health_record_screen.dart`** *(new)* — "السجل الطبي": commitment level/points, active health goal, approved medications, a read-only diagnoses/allergy grid, streak + achievement summary, and a "share with my specialist" action. Linked from Profile → المزيد.

Shared step UI extracted into `widgets/onboarding_step_header.dart` so the
three wizard screens can never disagree on their step count or progress
math.

### Code audit performed this pass
- **RTL correctness**: every `CrossAxisAlignment.end` inside a `Column` was
  auditing wrong — in a right-to-left `Directionality`, `.end` resolves to
  the *left* edge, not the right, so these columns were quietly
  left-aligning Arabic text against the app's own RTL wrapper. Mechanically
  replaced with `CrossAxisAlignment.start` app-wide (26 call sites across
  20 files) after confirming each one was inside a `Column`, not a `Row`
  (two `Row` matches were correctly left untouched). Likewise
  `Alignment.centerRight` → `AlignmentDirectional.centerStart` and
  `TextAlign.right` → `TextAlign.start` everywhere, and fixed one literal
  `Alignment.centerLeft` in the chat bubble alignment logic that had the
  outgoing/incoming sides backwards.
- **Deprecated API**: `Color.withOpacity(x)` → `Color.withValues(alpha: x)`
  app-wide (32 call sites) — `withOpacity` is deprecated in current Flutter
  and silently loses precision.
- Re-ran the brace/paren/bracket balance check and a duplicate-class-name
  scan on all 67 Dart files after every edit — clean.
- Confirmed every new screen only references tokens that already exist in
  `AppColors` / `AppRadius` / `AppTextStyles`, so no screen hardcodes a
  color or a corner radius.

## v5 — Unified chrome, motion system, and the real offline lifecycle

### App bar & navigation unification
- New `widgets/app_header_bar.dart`: the one header every *pushed* screen
  uses now (`[avatar] ··· [title] [→ back]`, or `backIcon: Icons.close_rounded`
  for a dismissible sheet-like screen). Mechanically swapped in on the 15
  screens that were using a plain default `AppBar(title: Text(...))`
  (measurements, meal detail, quantity selector, password/language/about,
  specialist profile, health record, notifications center, …), so back
  navigation and title placement finally read identically everywhere.
- Root-tab screens (Home, Plan, Foods, Progress, Profile) and a handful of
  deliberately-special full-bleed moments (`meal_log_success_screen`,
  `plan_preparing_screen`, `health_sync_screen`, `schedule_calls_screen`'s
  hero header, the black-background `barcode_scanner_screen`) were left
  with their bespoke chrome on purpose — unifying those would flatten
  design moments that are supposed to stand out. That distinction is now
  the documented rule, not an accident.
- The bottom nav was already single-source (`AnimatedBottomNavPill`, only
  ever mounted once in `AppShell`) — confirmed no screen duplicates it.
- **Found and fixed a real pre-existing bug while doing this pass**:
  `first_measurement_screen.dart` (shown right after a patient's very first
  weigh-in) had its app bar title hardcoded to "دليل القياسات" (Measurement
  *Guide*) — copy-pasted from a different screen. Retitled to "نقطة البداية".

### Motion system
- New `core/navigation/app_page_route.dart` — one shared transition (fade +
  upward slide + micro scale-in, 380ms) used on *every* push/pop in the
  app, mechanically replacing `MaterialPageRoute` everywhere (20 files).
- New `widgets/shimmer_box.dart` + `widgets/home_skeleton.dart` — a real
  loading skeleton, shaped exactly like the live dashboard, shown for the
  first ~700ms after Home mounts so content never "pops in".
- Home's meal-slot list now staggers in with a short fade + rise per card
  (`_AnimatedListEntry`) instead of appearing all at once.
- Notifications get a softly pulsing unread-dot; the offline/syncing
  banner cross-fades between states with `AnimatedContainer`/`AnimatedSize`.

### The real online/offline/sync lifecycle (Home Dashboard)
This was asked about directly, so to be explicit about what's implemented
and why there are deliberately **two different offline surfaces**:
- **Mid-session, cache already on screen** (Home Dashboard): a compact
  inline `OfflineBanner` appears above the progress card — "أنت غير متصل
  بالإنترنت الآن / بياناتك محفوظة محلياً بأمان تام", plus a
  "N بانتظار المزامنة" chip and a matching ⏳ badge on the affected meal
  card. Tapping the banner opens `ConnectionStatusSheet` (the detailed
  bottom-sheet explainer) for more context. When connectivity returns, the
  banner cross-fades into a brief "جاري مزامنة بياناتك..." pulse, then
  clears with a floating "تمت مزامنة N عنصر بنجاح" confirmation — this is
  the full loop the two Figma screenshots (connected vs. disconnected) were
  asking for, now actually wired end-to-end rather than two disconnected
  mockups.
- **Cold start / nothing cached at all** (`OfflineStateScreen`, full page):
  the harsher, emptier state — no data to show yet, so it explains what
  *can* still be done (browse the cached plan, log measurements, notes —
  all queued for sync) and offers "إعادة محاولة الاتصال" / "عرض الوجبات
  المحفوظة أوفلاين". A failed retry here hands off to the separate,
  generic `ErrorStateScreen` (a request that failed even though there *is*
  a connection — a different situation from "no connection at all", so it
  gets its own honest copy rather than reusing the offline message).
- Since this build has no real connectivity plugin, the header's Wi-Fi icon
  on Home is a transparent, tooltip-labeled preview affordance that runs
  through the exact same offline → syncing → online cycle a real
  connectivity listener would trigger — swap in `connectivity_plus` (or
  equivalent) and drive `_conn`/`_pendingCount` from it and the UI needs no
  other changes.

### Screen-graph audit (nothing left dangling)
Checked every screen's reference count across the app. One real orphan
found and fixed: `OfflineStateScreen` had no entry point — added to
Profile → المزيد. `BeetAiChatScreen` is *intentionally* unlinked (its own
doc comment says AI chat was an open question, not part of the confirmed
baseline) — left as documented, not wired in. Everything else resolves to
exactly the reference count its role implies (a settings sub-screen used
once from Profile, a two-step search→quantity flow sharing one title, etc).

### Still outstanding (same as v3, unchanged)
- `flutter analyze` / `flutter test` still need to be run in a real Flutter
  environment — not available in this sandbox.
- Language screen remains UI-only.
- `beetai_chat_screen.dart` remains intentionally unlinked.

## v6 — Health-data consent gate + follow-up-ended state

### New screens
- **`health_data_consent_screen.dart`** *(new)* — a real HIPAA-style
  informed-consent gate inserted between Activation and the health-data
  wizard: expandable clauses (data storage, who can see it, right to
  revoke), a required agreement checkbox that gates the CTA
  (`متابعة إعداد خطتي الصحية` is disabled until checked), and a link to the
  full policy. Leaving mid-flow (✕ or →) asks for confirmation rather than
  silently discarding an incomplete, legally-relevant step.
- **`follow_up_ended_screen.dart`** *(new)* — the "your clinical follow-up
  period has ended" state: final stats, the supervising specialist's card,
  a reassurance that all records are retained, a WhatsApp-style renewal CTA
  that opens the specialist's profile, a real "final report" summary sheet
  (`final_report_summary_sheet.dart`), and a working logout button. Reached
  from Profile → المزيد as a QA/demo entry (same convention as
  `PlanPreparingScreen`/`OfflineStateScreen`) — in production this is what
  Home would redirect to once the subscription end date passes.
- **`privacy_document_screen.dart`** *(new)* — one real, shared "read the
  full clinical privacy policy" document, linked from both new screens
  instead of two separate dead links.
- **`confirm_action_sheet.dart`** + **`core/navigation/logout_flow.dart`**
  *(new)* — a single reusable confirm-then-act bottom sheet, and one
  `performLogoutFlow()` every logout button in the app now calls.

### Real bugs fixed during this pass
Three logout buttons were pure decoration (`onPressed: () {}` / no handler
at all) and did nothing when tapped: Profile's logout card, the About
screen's logout button, and — now — the new follow-up-ended screen's, all
wired to the same real confirm → clear-stack → onboarding flow.

### Flow position
`ActivationScreen` (set password) now leads to `HealthDataConsentScreen`
first, and only then to `OnboardingMeasurementsScreen` (step 1/3) —
consent is a real gate, not a screen the wizard can bypass.
