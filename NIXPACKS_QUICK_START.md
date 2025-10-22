# 🚀 Quick Start: Deploy BotecoPro to Railway

This is a **60-second quick start** for deploying BotecoPro using nixpacks on Railway.app.

## ✅ Prerequisites
- GitHub account
- This repository

## 📝 Steps

### 1. Sign Up for Railway (Free)
Visit: https://railway.app
- Click "Login with GitHub"
- Authorize Railway

### 2. Create New Project
- Click "New Project"
- Select "Deploy from GitHub repo"
- Choose `Monynha-Softwares/BotecoPro`

### 3. Wait for Build
Railway automatically:
- ✅ Detects `nixpacks.toml`
- ✅ Installs Flutter SDK
- ✅ Runs `flutter pub get`
- ✅ Builds with `flutter build web --release`
- ✅ Starts web server

**Build time**: ~5-8 minutes (first time)

### 4. Access Your App
Railway provides a URL like:
```
https://botecepro-production.up.railway.app
```

**Done! 🎉**

## 🔧 Optional: Custom Domain
1. Go to Railway project settings
2. Click "Settings" → "Domains"
3. Add your custom domain
4. Update DNS records as shown

## 📊 Monitor Your App
- View logs in Railway dashboard
- Check resource usage
- Monitor deployment status

## 💰 Costs
**Free Tier**: 500 hours/month
**BotecoPro Usage**: ~100 hours/month (for MVP)
**Cost**: $0 ✅

## 🆘 Troubleshooting

### Build Failed?
1. Check Railway build logs
2. Verify all files are committed
3. See [NIXPACKS_DEPLOYMENT_GUIDE.md](./NIXPACKS_DEPLOYMENT_GUIDE.md)

### App Not Loading?
1. Wait for build to complete
2. Check deployment status in Railway
3. View runtime logs

## 📚 Full Documentation
- [NIXPACKS_DEPLOYMENT_GUIDE.md](./NIXPACKS_DEPLOYMENT_GUIDE.md) - Complete guide
- [NIXPACKS_BUILD_DIAGRAM.md](./NIXPACKS_BUILD_DIAGRAM.md) - Visual diagrams
- [NIXPACKS_IMPLEMENTATION_SUMMARY.md](./NIXPACKS_IMPLEMENTATION_SUMMARY.md) - Technical details

---

**Total Time**: ~8 minutes (including build)
**Difficulty**: Beginner-friendly
**Cost**: Free
