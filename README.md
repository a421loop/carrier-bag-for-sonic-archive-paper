# Carrier bag

A basket of sand where each recording is a pixel flower.
- **Tap a flower:** its recording plays and the flower grows.
- **Tap several:** they play together.
- **Leave one alone:** it withers.
- **Share a basket:** it plays only when two of you are on the page.

This folder is the whole website. It runs on **GitHub Pages** (free hosting) and **Supabase** (free database, audio storage and sign-in). There's no server to run.

## Setting it up (about 15 minutes, once)

### 1. Supabase: the database
1. Go to supabase.com and sign up (free).
2. Click **New project**. Name it `carrier-bag`, pick any password and the region nearest you, then **Create**. Wait about 2 minutes.
3. In the left bar, open **SQL Editor** and click **New query**.
4. Open `supabase/setup.sql` from this folder. Copy all of it, paste it in, and click **Run**. It should say "Success. No rows returned."
5. In the left bar, open **Project Settings → API**. Keep this page open; you need two values from it in step 3.

### 2. GitHub: the website
1. Go to github.com and sign in or sign up.
2. Click **New repository**. Name it `carrier-bag`, set it to **Public** (Pages is free for public repositories), and **Create**.
3. On the new repository page, click **uploading an existing file**. Drag in everything from this folder, including the `vendor` and `supabase` folders, then **Commit changes**.
4. Go to **Settings → Pages**. Under "Branch" choose `main` and `/ (root)`, then **Save**.
5. After about a minute, the page shows your address, something like `https://yourname.github.io/carrier-bag/`.

### 3. Connect the two
1. On GitHub, open `config.js` and click the pencil icon to edit it.
2. Replace the two `PASTE …` values with the ones from Supabase:
   - `supabaseUrl` ← **Project URL**
   - `supabaseKey` ← the **anon public** key. Don't use the `service_role` key: that one must stay secret.
3. Click **Commit changes**.
4. In Supabase, open **Authentication → URL Configuration**:
   - set **Site URL** to your GitHub Pages address
   - add that same address under **Redirect URLs**
   - Save.

### 4. Use it
1. Open your GitHub Pages address.
2. Type your email and tap **send me a link**.
3. Open the link in the email (on the same device) and you're in.

## Using it
- **+ add** adds recordings. Each one opens a small pixel pad to draw its blossom, or keep the one that's already there.
- **Tap a flower** to play it, and **tap it again** to stop. Tap several to hear them together.
- **Hold (or right-click) a flower** to rename it, redraw it, or take it out.
- **Baskets** are the names at the top left. **+** makes a new one. Tap the current name to rename it, make it "just me" or "listen together", or throw it away.
- **share** copies a link to the open basket and makes it shared. Send the link to a friend. They sign in with their own email, the basket shows up for them, and it plays when you're both on the page.
- **test** (bottom left) lets you skip days ahead to see withering, or pretend a friend is here.

## Good to know
- **Privacy:**
  - Baskets are private until you share them.
  - A shared basket is visible only to you and the friends who opened its link.
  - Audio files are only readable by signed-in people, under long random names.
- **Free plan limits:**
  - 1 GB of audio in total.
  - 50 MB per file. Longer recordings are split automatically and joined back together when they play.
- **Sign-in email:** Supabase's built-in email sender is limited to a few emails an hour. That's fine for you and a few friends.
- **Paused project:** free Supabase projects pause after a week with no visits. Open your Supabase dashboard and click **Restore** if that happens.

## Files
| file | what it is |
|---|---|
| `index.html` | the page (built from `page.html` by `build.py`) |
| `page.html` | the page source; the same page also runs as a Claude artifact |
| `config.js` | your Supabase address and public key |
| `supabase/setup.sql` | the tables, rules and audio storage; paste it into Supabase once |
| `vendor/supabase.js` | Supabase's own library (v2.45.4, MIT license), included so nothing loads from elsewhere |
