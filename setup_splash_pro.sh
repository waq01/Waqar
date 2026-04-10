#!/bin/bash
set -e

# ── 1. أضف dependency ──────────────────────────────────────────────
sed -i '/implementation composeBom/a\    implementation '\''androidx.core:core-splashscreen:1.0.1'\''' app/build.gradle

# ── 2. colors.xml ──────────────────────────────────────────────────
cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_bg_light">#FFFFFFFF</color>
    <color name="splash_bg_dark">#FF000000</color>
</resources>
EOF

# ── 3. themes.xml (نهار) ───────────────────────────────────────────
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Waqar.Splash" parent="Theme.SplashScreen">
        <item name="windowSplashScreenBackground">@color/splash_bg_light</item>
        <item name="windowSplashScreenAnimatedIcon">@drawable/ic_app</item>
        <item name="postSplashScreenTheme">@style/Theme.Waqar</item>
    </style>
    <style name="Theme.Waqar" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="android:windowBackground">@color/splash_bg_light</item>
    </style>
</resources>
EOF

# ── 4. themes.xml (ليل) ────────────────────────────────────────────
mkdir -p app/src/main/res/values-night
cat > app/src/main/res/values-night/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.Waqar.Splash" parent="Theme.SplashScreen">
        <item name="windowSplashScreenBackground">@color/splash_bg_dark</item>
        <item name="windowSplashScreenAnimatedIcon">@drawable/ic_app_dark</item>
        <item name="postSplashScreenTheme">@style/Theme.Waqar</item>
    </style>
    <style name="Theme.Waqar" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="android:windowBackground">@color/splash_bg_dark</item>
    </style>
</resources>
EOF

# ── 5. AndroidManifest ─────────────────────────────────────────────
sed -i 's|android:theme="@style/Theme.Waqar"|android:theme="@style/Theme.Waqar.Splash"|' \
    app/src/main/AndroidManifest.xml

# ── 6. MainActivity.kt ─────────────────────────────────────────────
cat > app/src/main/java/com/xstudio/waqar/MainActivity.kt << 'EOF'
package com.xstudio.waqar

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.xstudio.waqar.ui.screens.SplashScreen
import com.xstudio.waqar.ui.theme.WaqarTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            WaqarTheme {
                var showSplash by remember { mutableStateOf(true) }
                if (showSplash) {
                    SplashScreen(onFinish = { showSplash = false })
                }
            }
        }
    }
}
EOF

# ── 7. Git ─────────────────────────────────────────────────────────
git add .
git commit -m "feat: implement SplashScreen API to eliminate cold start flash"
git push
