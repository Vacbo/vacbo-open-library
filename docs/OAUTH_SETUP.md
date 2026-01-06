# OAuth Setup Guide

Configure Google and GitHub OAuth for login.

## Part 1: Google OAuth

### Step 1: Create Google OAuth App

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Go to **APIs & Services** → **OAuth consent screen**
4. Configure consent screen:
   - User Type: **External**
   - App name: `Vacbo Library`
   - User support email: `contact@vacbo.dev`
   - Developer contact: `contact@vacbo.dev`
5. Add scopes: `email`, `profile`, `openid`
6. Add test users (your email) if in testing mode
7. Click **Save and Continue**

### Step 2: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Configure:
   - Application type: **Web application**
   - Name: `Vacbo Library`
   - Authorized JavaScript origins: `https://library.vacbo.dev`
   - Authorized redirect URIs: `https://library.vacbo.dev/login/google/authorized`
4. Click **Create**
5. Copy **Client ID** and **Client Secret**

### Step 3: Configure in Calibre-Web

1. Login to https://library.vacbo.dev as admin
2. Go to **Admin** → **Configuration** → **Feature Configuration**
3. Set **Login Type** to include OAuth
4. Fill in:
   - **Google OAuth Client ID**: (paste)
   - **Google OAuth Client Secret**: (paste)
5. Click **Save**

## Part 2: GitHub OAuth

### Step 1: Create GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **OAuth Apps** → **New OAuth App**
3. Fill in:
   - Application name: `Vacbo Library`
   - Homepage URL: `https://library.vacbo.dev`
   - Authorization callback URL: `https://library.vacbo.dev/login/github/authorized`
4. Click **Register application**
5. Copy **Client ID**
6. Click **Generate a new client secret**
7. Copy **Client Secret**

### Step 2: Configure in Calibre-Web

1. Login to https://library.vacbo.dev as admin
2. Go to **Admin** → **Configuration** → **Feature Configuration**
3. Fill in:
   - **GitHub OAuth Client ID**: (paste)
   - **GitHub OAuth Client Secret**: (paste)
4. Click **Save**

## Linking Accounts

### For Existing Users

1. Login with username/password
2. Go to your **Profile** (top right → your username)
3. Click **Link** next to Google or GitHub
4. Authorize the application
5. Account is now linked

### For New Users

1. Go to https://library.vacbo.dev
2. Click the **Google** or **GitHub** icon on login page
3. Authorize the application
4. Account is created automatically

## Troubleshooting

### "Scope has changed" error (Google)

The docker-compose.yml includes `OAUTHLIB_RELAX_TOKEN_SCOPE=1` which should fix this. If it persists:

```bash
docker compose restart calibre-web
```

### "Redirect URI mismatch"

Ensure callback URLs match exactly:
- Google: `https://library.vacbo.dev/login/google/authorized`
- GitHub: `https://library.vacbo.dev/login/github/authorized`

No trailing slashes, must use HTTPS.

### OAuth buttons not showing

1. Verify OAuth is enabled in Feature Configuration
2. Verify Client ID and Secret are filled in
3. Restart Calibre-Web:

```bash
docker compose restart calibre-web
```

### "Access blocked: app not verified" (Google)

While in testing mode, only test users can login. Either:
- Add users to test users list in Google Console
- Submit app for verification (takes time)

## Security Notes

- Rotate OAuth secrets every 6-12 months
- Monitor app access in Google/GitHub settings
- Users should set a password as backup authentication
