# Publishing to the COI Mod Hub

This is the full walkthrough for getting your mod onto [hub.coigame.com](https://hub.coigame.com). The `/ship-it` skill walks you through packaging and gives you a condensed version of these steps in-session. Come here when you want the full picture.

---

## Before you start

Make sure you have:
- Run `/ship-it` to completion (or run `.\scripts\package-release.ps1` manually)
- Your release zip at `scripts\releases\<MOD_ID>-v<version>.zip`
- An account at [hub.coigame.com](https://hub.coigame.com) (Register link in the top nav)

---

## First release: creating a new mod listing

### 1. Log in and navigate to Mods

Go to [hub.coigame.com](https://hub.coigame.com) and log in. Click **Mods** in the top nav, then click the **ADD MOD** button.

> If you don't see ADD MOD, make sure you're logged in — it's only visible to authenticated users.

### 2. Upload the zip

You land at `hub.coigame.com/Mod/Create` — "Upload a mod". The Hub reads your `manifest.json` automatically from the zip and pre-populates the edit page from it.

1. Drag `scripts\releases\<MOD_ID>-v<version>.zip` onto the upload area, or click **CHOOSE ZIP**.
2. Check the box: **"I have read and agree to the Modding Policy including section 7. Hub Distribution."**
3. Click **UPLOAD & CONTINUE**.

### 3. Complete the edit page

After the upload, the Hub takes you to an edit page to add the remaining details. Here's what to expect and how it maps to your project files:

| Hub field | Source | Notes |
|---|---|---|
| **Name** | `display_name` from manifest | Max 50 chars. Pre-populated from the zip. Cannot be changed after first upload. |
| **Short description** | `description_short` from manifest | Max 180 chars. Pre-populated. Cannot be changed after first upload. |
| **Description** | `description_long` from manifest | Full description shown on the mod's page. |
| **License** | Your choice | See license options below. Set once; persists across all future versions. |
| **Source code URL** | `links[0]` from manifest | Your GitHub repo, if you have one. |
| **Tags** | Your choice | Options include: Quality of Life, Tweaks, Balance, UI, Overhaul, etc. |
| **Min game version** | `min_game_version` from manifest | Oldest COI version your mod supports. |
| **Max verified game version** | `max_verified_game_version` from manifest | Newest version you've tested against; shown as the upper end of the compatibility range. |
| **Save-game: can add** | `can_add_to_saved_game` from manifest | Pre-populated from the zip. |
| **Save-game: can remove** | `can_remove_from_saved_game` from manifest | Pre-populated from the zip. |
| **Status** | Your choice | **Stable** for a real release, **Beta** for a pre-release. |
| **Screenshots** | Optional | See step 4 below. |

> **Name and Short description cannot be edited after submission.** Verify them in `manifest.json` before uploading.

#### License options

- **MIT** -- standard permissive open-source. Others can use, modify, and redistribute freely with attribution.
- **COI-Open** -- COI-specific. Others can freely use, modify, and share your mod within Captain of Industry, with credit required and the same license applied to derivatives.
- **COI-Keep** -- COI-specific. Derivative works are not allowed without your permission. Includes a community-maintenance exception: if you go inactive, the community may maintain it.

If you're unsure, MIT or COI-Open are both player-friendly choices. COI-Keep makes sense if you want to retain tight control over forks.

### 4. Screenshots (optional but recommended)

Attach a thumbnail and any screenshots on the edit page. A single in-game screenshot significantly improves click-through from the Mods catalog. You can also add or change them later from your mod's management page.

### 5. Submit

Save/submit the edit page. The listing may go through a brief review before becoming publicly visible.

The Hub reads `changelog.txt` directly from inside the zip — no copy-pasting needed.

---

## Subsequent releases: uploading a new version

1. Go to [hub.coigame.com](https://hub.coigame.com) and navigate to your mod's page.
2. Look for an **"Upload new version"** or **"Add version"** button (visible only when logged in as the mod owner).
3. Attach the new zip from `scripts\releases\<MOD_ID>-v<version>.zip`.
4. Set the **game version compatibility range** — update the max version if a COI update just dropped.
5. Set the status: **Stable** or **Beta**.
6. The Hub reads the updated `changelog.txt` from inside the new zip automatically.

That's it. No need to re-enter the name, description, license, or tags — those stay with the listing.

---

## Things that cannot change after first upload

- **Name** (`display_name`)
- **Short description** (`description_short`)

Everything else — tags, full description, screenshots, source link — can be edited from the listing's management page at any time.

---

## Notes

- **No automatic updates.** Players must manually download and install each new version. The Hub is a file host, not a package manager.
- **`changelog.txt` is plain text.** The Hub renders it as-is. No markdown. The `/ship-it` skill strips markdown formatting when writing to it.
- **The zip is the distribution artifact.** GitHub is source-only. Players download from the Hub.
