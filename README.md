# EZL Films — Site

The static site for **EZL Films**, a cinematic short-form video studio based in Los Angeles.

- **Live URL:** (TBD — see deployment section)
- **Stack:** Plain HTML + CSS, no build step, no JS framework
- **Hosting:** Cloudflare Pages (free tier, auto-deploys on push)
- **Source of truth:** This directory. Edit `index.html`, push to GitHub, the live site updates in ~30 seconds.

---

## Local development

Just open `index.html` in a browser. There is no build step.

```bash
open index.html        # macOS
xdg-open index.html    # Linux
start index.html       # Windows
```

For a quick local server (so Vimeo embeds work correctly):

```bash
python3 -m http.server 8000
# then visit http://localhost:8000
```

---

## Deployment

The site is deployed via **Cloudflare Pages**, connected to a GitHub repo. Every push to `main` triggers a redeploy.

### One-time setup (already done by Hermes)
1. GitHub repo created: `ezlfilms/ezlfilms-site` (TBD — confirm with user)
2. Cloudflare Pages project created and connected to the repo
3. Build settings: nothing required (no build command, output dir = root)

### Pushing updates

From this directory:

```bash
git add .
git commit -m "Describe what changed"
git push
```

Cloudflare picks up the push and redeploys in ~30 seconds. No manual action needed.

---

## File structure

```
.
├── index.html         # The entire site (HTML + inlined CSS)
├── .gitignore
└── README.md          # This file
```

That's it. One HTML file. When the portfolio grows, we may split into `index.html`, `work.html`, etc. — but for v1, single page is right.

---

## Content placeholders to fill before launch

When the user is ready (post-recovery), these need real values:

- `HERO_REEL_SRC` in the hero section — Vimeo embed URL
- 4× `PASTE_VIMEO_URL_HERE` in the work grid — Vimeo URLs for the 4 portfolio pieces
- `hello@ezlfilms.com` — set up email forwarder OR replace with personal email
- `formspree.io/f/REPLACE_FORM_ID` — Formspree form ID (free signup)
- Instagram + Vimeo handles in the footer

---

## Palette tokens

```
--orange:       #C04A1A   (deep burnt)
--orange-glow:  #E8632C   (hover/accent)
--black:        #0A0908
--ink:          #1A1815   (raised surfaces / cards)
--cream:        #F2E8D5   (primary text)
--cream-dim:    #C9BFA9   (secondary text)
--line:         #2A2520   (borders)
```

Aesthetic reference: Blade Runner 2049 poster, A24 branding. Film-grain SVG overlay is applied via `body::before`.

---

## Future improvements (when there's time + revenue)

- [ ] Split work into individual project pages (`/work/restaurant-name/`)
- [ ] Add a blog / journal for SEO ("How a 30-second reel changed a restaurant's Saturday bookings")
- [ ] Add a private "client portal" page with download links for delivered files
- [ ] Custom domain (ezlfilms.com) once revenue supports it
- [ ] Add a real Calendly embed for the 15-min intro call
- [ ] Add an "as featured in" section once there's press to point to
