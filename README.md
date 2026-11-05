# Willa's Little Wins — MVP 0.2

A tiny, mobile-first shared scrapbook and training log for Willa, with Oscar and Dennis photo cameos. Four optional mini-adventures explain themselves through a friendly **? How to play** card. There's no prescribed training schedule, no streak penalties, and no leaderboard.

## What's working

- Tap a quest, optionally read its three-step how-to, and record **comfy**, **unsure**, or **too hard**.
- Add a note, photo, and sticker to any training log.
- The scrapbook starts with all eight original household photos supplied for the app; add new moments and decorate with emoji or custom uploaded sticker art.
- Upload pet portraits, including the home-screen Willa image.
- View comfortable repetitions, recent attempts, and the household's Bravery Jar. Filling each milestone unlocks a **new collectible emoji sticker** usable on scrapbook photos and training logs; see the sticker shelf under **Little wins**.
- Hidden, noncompetitive bravery-jar weighting gives Hil's participation extra influence on unlocks. It's intended to celebrate participation, not measure Willa's performance. Comfortable repetitions are counted separately.
- **Local preview mode** immediately works with no configuration, with photos stored in IndexedDB and metadata in localStorage. Use **Export backup** before clearing browser data.
- **Cloud mode** supports separate email-and-password accounts, a shared two-person household, private photo storage, and near-real-time refresh between phones, after setting up Supabase.
- Install as an iPhone home-screen web app when served from an HTTPS website.

## Try it now (local preview)

From this folder, run a static server:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000` in a browser. The app has no build step. When hosted on HTTPS, use Safari's Share > Add to Home Screen. All data in local preview mode lives only on that device and is not shared with another phone.

You can deploy these files as a static site to GitHub Pages, Cloudflare Pages, or Netlify. **Do not use `file://` to open index.html**: browsers restrict JavaScript modules and photo storage in that mode.

## Enable real sharing — no domain or SMTP required

1. The Supabase project is already configured in `config.js`, and the database schema and permissions are installed.
2. In Supabase, open **Authentication → Sign In / Providers → Email** and **turn off Confirm email** (email verification) so a two-person password signup does not require outgoing email. Leave email/password authentication enabled. Hosted Supabase projects require confirmation by default.
3. Open `https://idyllic-stroopwafel.github.io/willas-little-wins/`. On the first phone, enter an email and a **unique, strong password**, then tap **Create an account**. Choose Peter or Hil and create a household (leave invite code empty).
4. In **Our pets**, copy the household invitation code. On the other phone, choose **Create an account** with the second person's different email and password, and then enter the invitation code to join the existing household.
5. Afterward, use **Sign in** with that email and password if a device signs out. Sessions usually remain signed in.

**Important trade-offs:** Without email verification, Supabase cannot establish that the signup email belongs to the person creating the account. Treat the household invitation code as private and use strong, different passwords. Until SMTP is added, **password-reset email won't work**, so save passwords in your password managers. Consider restricting new account registrations after both household members are enrolled. Never put passwords in GitHub or this README.

**Note:** Switching from local to cloud mode does **not** automatically import local prototype data. Before adding Supabase credentials, use **Our pets → Export my backup** on any device where you tested the prototype. The cloud household will begin with fresh training logs. The eight bundled starter photos remain visible in both modes.

## Design notes and scope

- Four training prompts: **The Cozy Den**, **Keys Are Boring**, **Back in a Flash**, and **The Waiting Game**. Each has a short definition, success criterion, and reminder to keep the dog below a distress threshold.
- No prescriptive duration or automatic next-step progression. A calm one-second attempt can count.
- A 'too hard' entry counts as an honest check-in, not a comfort success; it never advances the exercise difficulty.
- The album uses the eight real photos supplied by the household, bundled under `photos/`. Those bundled photos (including ones featuring people) are **publicly accessible** because this is a public GitHub Pages repository. Later user-uploaded photos go to a private Supabase bucket in cloud mode.
- This first version includes no editing/deletion flow, image captions remain lightweight, and the surprise rewards are five collectible stickers, not just a status change.
- For persistent, production use: test the two-account invite flow and storage access in your own Supabase project, configure auth email deliverability, and monitor storage usage. Row-level security prevents outsiders from accessing household data when configured as supplied.

## Asset suggestions

Eight starter photos are already included. Separate custom sticker files have not yet been provided. Sticker PNG/WebP images (preferably with transparent backgrounds) can be uploaded in **Our pets → Add sticker**. The collectible emoji stickers are unlocked by the Bravery Jar.

## Behaviour sources

The task wording is based on choosing voluntary crate interactions, counterconditioning departure cues, and increasing separations below the dog's anxiety threshold:
- [ASPCA — Separation Anxiety](https://www.aspca.org/pet-care/dog-care/common-dog-behavior-issues/separation-anxiety)
- [Fear Free Happy Homes — Keep Calm and Kennel On](https://www.fearfreehappyhomes.com/keep-calm-and-kennel-on/)
- [AAHA — Separation Anxiety in Pets](https://www.aaha.org/resources/separation-anxiety-in-pets/)

This app isn't a substitute for a veterinarian or qualified behaviour professional if distress is substantial or persistent.

- The home screen uses Willa's real photo by default.