# Vercel Deployment Guide

## 🚀 Deploy to Vercel

### Option 1: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Build your app locally:**
   ```bash
   flutter build web --release -O4 --no-source-maps
   ```

4. **Deploy:**
   ```bash
   vercel --prod
   ```

### Option 2: Deploy via GitHub Integration

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Import on Vercel:**
   - Go to https://vercel.com/new
   - Click "Import Git Repository"
   - Select your repository
   - Configure:
     - Framework Preset: **Other**
     - Build Command: `flutter build web --release -O4 --no-source-maps`
     - Output Directory: `build/web`
     - Install Command: Leave blank (handled by vercel.json)
   - Click "Deploy"

## 🌐 Add Custom Domain

### After deployment:

1. **Go to your project on Vercel Dashboard**
2. Click **Settings** → **Domains**
3. Add your custom domain (e.g., `hassankamran.com`)
4. **Configure DNS at your domain provider:**

   **For root domain (hassankamran.com):**
   - Type: `A`
   - Name: `@`
   - Value: `76.76.21.21`

   **For www subdomain:**
   - Type: `CNAME`
   - Name: `www`
   - Value: `cname.vercel-dns.com`

5. Wait for DNS propagation (5-10 minutes)
6. Vercel will auto-generate SSL certificate

## ✅ Verify Deployment

- Check: https://your-project.vercel.app
- Check: https://yourdomain.com
- Test: Mobile responsiveness
- Test: All routes work

## 🔧 Environment Variables (if needed)

If you need to add Firebase config or API keys:
1. Go to **Settings** → **Environment Variables**
2. Add variables (they'll be available as `String.fromEnvironment()`)

## 📊 Performance

Vercel automatically:
- Gzips files (reduces size by ~70%)
- Serves from global CDN
- Caches static assets
- Provides SSL/HTTPS
- Shows analytics

Your 24MB build will download as ~6-8MB!
