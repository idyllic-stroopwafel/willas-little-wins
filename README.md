# Willa's Little Wins — MVP 0.1

A tiny, mobile-first shared scrapbook and training log for Willa, with Oscar and Dennis photo cameos. Four optional mini-adventures explain themselves through a friendly **? How to play** card. There's no prescribed training schedule, no streak penalties, and no leaderboard.

## What's working

- Tap a quest, optionally read its three-step how-to, and record **comfy**, **unsure**, or **too hard**.
- Add a note, photo, and sticker to any training log.
- Add photos to a scrapbook (Willa, Oscar, or Dennis), and decorate with standard emoji or your own uploaded stickers.
- Upload pet portraits, including the home-screen Willa image.
- View a gentle progress summary: comfortable repetitions by quest, recent attempts, and a shared bravery jar.
- Hidden, noncompetitive bravery-jar weighting gives Hil's participation extra influence on unlocks. It's intended to celebrate participation, not measure Willa's performance. Comfortable repetitions are counted separately.
- **Local preview mode** immediately works with no configuration, with photos stored in IndexedDB and metadata in localStorage. Use **Export backup** before clearing browser data.
- **Optional cloud mode** supports separate email sign-ins, a shared two-person household, private photo storage, and near-real-time refresh between phones, after setting up Supabase.
- Install as an iPhone home-screen web app when served from an HTTPS website.

## Try it now (local preview)

From this folder, run a static server:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000` in a browser. The app has no build step. When hosted on HTTPS, use Safari's Share > Add to Home Screen. All data in local preview mode lives only on that device and is not shared with another phone.

You can deploy these files as a static site to GitHub Pages, Cloudflare Pages, or Netlify. **Do not use `file://` to open index.html**: browsers restrict JavaScript modules and photo storage in that mode.

## Enable real sharing (optional, but necessary for both phones)

1. Create a free Supabase project. Open **SQL Editor**, and run the full `supabase.sql` file against a new project. This creates household membership, private data tables, row-level security, private image storage, and a two-person invite flow.
2. In **Project Settings > API**, copy the **Project URL** and **publishable / anon** key into `config.js`. The anon key is intended for the client; **never** use a service-role or secret key here.
3. Under **Authentication > Providers**, ensure email login is enabled. Under **Authentication > URL Configuration**, set your app's hosted URL as the Site URL and add it to Redirect URLs. The sign-in link uses that URL.
4. Host the folder on an HTTPS static host.
5. On the first phone, enter an email address, follow the sign-in link, choose Hil or Peter, and create the household (leave invite code empty).
6. In **Our pets**, copy the household invite code. On the other phone, sign in using the other person's email, choose their name, and enter that code. Both now see the same entries and media.

**Note:** Switching from local to cloud mode does *not* automatically import local prototype data. Experiment with placeholders locally, then enable cloud before you begin recording real training history.

## Design notes and scope

- Four training prompts: **The Cozy Den**, **Keys Are Boring**, **Back in a Flash**, and **The Waiting Game**. Each has a short definition, success criterion, and reminder to keep the dog below a distress threshold.
- No prescriptive duration or automatic next-step progression. A calm one-second attempt can count.
- A 'too hard' entry counts as an honest check-in, not a comfort success; it never advances the exercise difficulty.
- The album uses real photos supplied by the household, not stock pet pictures.
- This first version includes no editing/deletion flow, image captions remain lightweight, and rewards are intentionally minimal.
- For persistent, production use: test the two-account invite flow and storage access in your own Supabase project, configure auth email deliverability, and monitor storage usage. Row-level security prevents outsiders from accessing household data when configured as supplied.

## Asset suggestions

You don't need photos to start. When ready, collect **3–6 Willa photos, 1–2 Oscar photos, 1–2 Dennis photos**, and sticker PNG/WebP images (preferably with transparent backgrounds). Upload them in **Our pets** or the **Scrapbook**; no image filenames or dimensions are mandated.

## Behaviour sources

The task wording is based on choosing voluntary crate interactions, counterconditioning departure cues, and increasing separations below the dog's anxiety threshold:
- [ASPCA — Separation Anxiety](https://www.aspca.org/pet-care/dog-care/common-dog-behavior-issues/separation-anxiety)
- [Fear Free Happy Homes — Keep Calm and Kennel On](https://www.fearfreehappyhomes.com/keep-calm-and-kennel-on/)
- [AAHA — Separation Anxiety in Pets](https://www.aaha.org/resources/separation-anxiety-in-pets/)

This app isn't a substitute for a veterinarian or qualified behaviour professional if distress is substantial or persistent.

- The local prototype now ships with a bundled Willa photo as the default home-screen hero and portrait.