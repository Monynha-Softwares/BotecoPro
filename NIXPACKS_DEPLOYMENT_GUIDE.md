# 🚂 Railway / Nixpacks Deployment Guide - BotecoPro

This guide explains how to deploy BotecoPro to platforms that use Nixpacks (like Railway.app) for automatic builds.

## 📋 Overview

**Nixpacks** is an automatic build system that detects your application type and builds it accordingly. This repository includes custom nixpacks configuration optimized for Flutter web applications.

### Files Involved
- `nixpacks.toml` - Nixpacks configuration file
- `nixpacks-setup.sh` - Helper script for install, build, and start phases

---

## 🚀 Quick Deploy to Railway

### Prerequisites
- GitHub account with this repository
- Railway.app account (free tier available)

### Step-by-Step

1. **Go to Railway.app**
   - Visit https://railway.app
   - Click "Start a New Project"
   - Select "Deploy from GitHub repo"

2. **Connect Repository**
   - Authorize Railway to access your GitHub
   - Select the `BotecoPro` repository
   - Railway will automatically detect the nixpacks configuration

3. **Configure Environment Variables** (Optional)
   ```
   FLUTTER_VERSION=3.24.5
   PORT=8080
   ```

4. **Deploy**
   - Railway will automatically:
     - Install Flutter SDK
     - Run `flutter pub get`
     - Build with `flutter build web --release`
     - Start a web server on the assigned port
   
5. **Access Your App**
   - Railway will provide a public URL like: `https://botecepro-production.up.railway.app`
   - Your app is now live! 🎉

---

## 🔧 How It Works

### Build Process

The nixpacks configuration defines three phases:

#### 1. **Setup Phase**
```toml
[phases.setup]
nixPkgs = ["wget", "git", "bash", "curl", "xz", "python3"]
```
Installs necessary system packages.

#### 2. **Install Phase**
```bash
./nixpacks-setup.sh install
```
- Downloads Flutter SDK (version specified in FLUTTER_VERSION)
- Extracts and configures Flutter
- Runs `flutter pub get` to install dependencies

#### 3. **Build Phase**
```bash
./nixpacks-setup.sh build
```
- Builds the web application with `flutter build web --release`
- Generates optimized static files in `build/web/`

#### 4. **Start Phase**
```bash
./nixpacks-setup.sh start
```
- Serves the static files using Python's built-in HTTP server
- Listens on the PORT environment variable (provided by Railway)

---

## 📝 Configuration Details

### nixpacks.toml

```toml
[variables]
FLUTTER_VERSION = "3.24.5"

[phases.setup]
nixPkgs = ["wget", "git", "bash", "curl", "xz", "python3"]

[phases.install]
cmds = [
    "chmod +x nixpacks-setup.sh",
    "./nixpacks-setup.sh install"
]

[phases.build]
cmds = [
    "chmod +x nixpacks-setup.sh",
    "./nixpacks-setup.sh build"
]

[start]
cmd = "./nixpacks-setup.sh start"
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FLUTTER_VERSION` | 3.24.5 | Flutter SDK version to install |
| `PORT` | 8080 | Port for the web server (auto-set by Railway) |

---

## 🧪 Testing Locally

You can test the nixpacks build process locally:

### Install Nixpacks CLI
```bash
npm install -g @railway/cli
railway login
```

### Test Build
```bash
# Run the install phase
./nixpacks-setup.sh install

# Run the build phase
./nixpacks-setup.sh build

# Test the start command
./nixpacks-setup.sh start
```

Then open http://localhost:8080 in your browser.

---

## 🔍 Troubleshooting

### Build Fails: "Flutter SDK not found"

**Solution**: Check that FLUTTER_VERSION is set correctly and the download URL is accessible.

```bash
# Verify Flutter version
curl -I https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
```

### Build Fails: "pub get failed"

**Solution**: Check your `pubspec.yaml` for any incompatible dependencies.

```bash
# Test locally
flutter pub get
```

### Runtime Error: "No such file or directory: build/web"

**Solution**: Ensure the build phase completed successfully. Check Railway logs for build errors.

### Server Won't Start

**Solution**: Verify Python3 is available and the PORT variable is set:

```bash
# Check Python
python3 --version

# Check PORT
echo $PORT
```

---

## 🌐 Alternative Platforms

This nixpacks configuration works with any platform that supports nixpacks:

### Render.com
1. Create new "Web Service"
2. Connect GitHub repository
3. Render auto-detects nixpacks.toml
4. Deploy!

### Heroku (with nixpacks buildpack)
```bash
heroku create your-app-name
heroku buildpacks:set https://github.com/railwayapp/nixpacks
git push heroku main
```

---

## 📊 Performance & Scaling

### Build Time
- Initial build: ~5-8 minutes (Flutter SDK download + build)
- Subsequent builds: ~2-3 minutes (cached SDK)

### Runtime Performance
- Static files served via Python HTTP server
- Suitable for MVP and small-scale deployments
- For production, consider:
  - Using nginx instead of Python HTTP server
  - CDN for static assets
  - Horizontal scaling

### Build Size
```
Total app size: ~3.8 MB
- main.dart.js: ~2.8 MB
- canvaskit/: ~640 KB
- assets/: ~200 KB
```

---

## 🔐 Security Considerations

### Current Setup (MVP)
- ✅ Static file serving (no server-side code execution)
- ✅ Client-side data storage (localStorage)
- ⚠️ No authentication (public access)
- ⚠️ No HTTPS enforcement (handled by platform)

### Production Recommendations
1. Enable HTTPS (usually automatic on Railway)
2. Add authentication layer
3. Implement rate limiting
4. Use environment variables for sensitive config
5. Regular security audits

---

## 💰 Cost Estimation

### Railway.app Free Tier
- ✅ 500 free hours/month
- ✅ Suitable for MVP testing
- 💵 $5/month for production

### Typical Usage (BotecoPro MVP)
```
CPU: Low (static file serving)
Memory: ~512 MB
Bandwidth: ~10 GB/month (for ~1000 users)
Storage: ~50 MB

✅ Fits within free tier limits!
```

---

## 🎯 Next Steps

### After Successful Deployment

1. **Test All Features**
   - [ ] Home page loads
   - [ ] All navigation tabs work
   - [ ] Data persists in localStorage
   - [ ] Responsive design works

2. **Share with Users**
   - Copy the Railway URL
   - Share for feedback
   - Monitor usage in Railway dashboard

3. **Monitor Performance**
   - Check Railway logs for errors
   - Monitor response times
   - Track resource usage

4. **Plan Scaling**
   - Add custom domain
   - Implement backend API
   - Add authentication
   - Move to production-grade hosting

---

## 📚 Additional Resources

- [Nixpacks Documentation](https://nixpacks.com/docs)
- [Railway.app Documentation](https://docs.railway.app)
- [Flutter Web Documentation](https://flutter.dev/web)
- [BotecoPro Firebase Guide](./FIREBASE_DEPLOYMENT_GUIDE.md)

---

## 🆘 Support

### Issues with Deployment?

1. Check Railway build logs
2. Verify all files are committed to Git
3. Test build locally with `./nixpacks-setup.sh`
4. Open an issue on GitHub

### Need Help?

- 💬 GitHub Issues: [Report a problem](https://github.com/Monynha-Softwares/BotecoPro/issues)
- 📖 Documentation: See other deployment guides in this repo
- 🚂 Railway Support: https://railway.app/help

---

**BotecoPro is now ready for nixpacks deployment! 🚀**

Last Updated: October 2025
Version: 1.0.0
