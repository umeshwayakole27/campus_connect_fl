# Quick Testing Guide - Navigation Feature

## 🚀 Quick Start (When Device Connected)

```bash
# 1. Connect device
adb devices

# 2. Run app
flutter run
```

## ✅ Feature Checklist

### MyLocation Button (Bottom-Right)
- [ ] Click button → Blue marker at your location
- [ ] Map centers on you
- [ ] Works without crashes

### Get Directions
- [ ] Tap any marker
- [ ] Click "Get Directions"
- [ ] Route appears (curved blue line)
- [ ] Distance shows correctly
- [ ] Clear button works

### Permissions
- [ ] Location permission requested
- [ ] Works when granted
- [ ] Helpful message when denied

## 🔍 What to Look For

### ✅ Good Signs:
- Blue marker shows your location
- Routes are curved (follow paths)
- Distance accurate (meters/km)
- Smooth camera animations
- Clear route button appears

### ⚠️ Warning Signs:
- Straight dashed line (means API not working, but OK as fallback)
- No route at all (check permissions)
- App crashes (check logs)

## 🐛 Quick Fixes

### No location permission?
→ Settings → Apps → Campus Connect → Permissions → Enable Location

### Route is straight line?
→ Check internet connection
→ Verify Directions API enabled in Google Cloud

### Map shows only Google logo?
→ Enable Maps SDK in Google Cloud
→ Add SHA-1 to API key restrictions

## 📱 Device Requirements

- Android device
- Location services enabled
- Internet connection (for real routes)
- Location permission granted

## 🎯 Success Criteria

If you can:
1. See your location (blue marker) ✓
2. Get directions to any campus location ✓
3. See a curved route path ✓
4. Clear the route ✓

Then navigation is working! 🎉

## 📞 Next Steps After Testing

Once tested and working:
→ Move to Phase 4: Event Management
→ Check progress.md for details

---

**Total Test Time: ~5 minutes**

**Files to Check:**
- NAVIGATION_FEATURE.md (detailed guide)
- NAVIGATION_SUMMARY.md (complete summary)
- progress.md (development tracker)
