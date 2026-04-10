#!/bin/bash
set -e

PKG=app/src/main/java/com/xstudio/waqar

# ── 1. build.gradle ───────────────────────────────────────────────
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    compileSdk 35
    namespace "com.xstudio.waqar"

    defaultConfig {
        applicationId "com.xstudio.waqar"
        minSdk 26
        targetSdk 35
        versionCode (System.getenv("VERSION_CODE")?.toInteger() ?: 1)
        versionName "1.0"
    }

    signingConfigs {
        release {
            def kp = System.getenv("KEYSTORE_PATH")
            if (kp) {
                storeFile file(kp)
                storePassword System.getenv("KEYSTORE_PASS")
                keyAlias System.getenv("KEY_ALIAS")
                keyPassword System.getenv("KEY_PASS")
            }
        }
    }

    buildTypes {
        release {
            def kp = System.getenv("KEYSTORE_PATH")
            if (kp) signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            versionNameSuffix "-debug"
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    buildFeatures {
        compose true
    }

    composeOptions {
        kotlinCompilerExtensionVersion '1.5.10'
    }
}

dependencies {
    def composeBom = platform('androidx.compose:compose-bom:2024.02.00')
    implementation composeBom
    implementation 'androidx.core:core-splashscreen:1.0.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.compose.ui:ui'
    implementation 'androidx.compose.ui:ui-tooling-preview'
    debugImplementation 'androidx.compose.ui:ui-tooling'
    implementation 'androidx.compose.material3:material3'
    implementation 'androidx.compose.material:material-icons-core'
    implementation 'androidx.activity:activity-compose:1.8.2'
    implementation 'androidx.navigation:navigation-compose:2.7.7'
}
EOF

# ── 2. GitHub Actions workflow ─────────────────────────────────────
cat > .github/workflows/build.yml << 'EOF'
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Setup Keystore
        run: |
          mkdir -p ~/.android
          if [ -n "${{ secrets.DEBUG_KEYSTORE_B64 }}" ]; then
            echo "${{ secrets.DEBUG_KEYSTORE_B64 }}" | base64 -d > ~/.android/debug.keystore
          else
            keytool -genkeypair -v \
              -keystore ~/.android/debug.keystore \
              -storepass android -alias androiddebugkey -keypass android \
              -keyalg RSA -keysize 2048 -validity 10000 \
              -dname "CN=Android Debug,O=Android,C=US"
          fi

      - name: Build APK
        env:
          VERSION_CODE: ${{ github.run_number }}
        run: bash gradlew assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: Waqar-v${{ github.run_number }}
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

# ── 3. strings.xml (English) ──────────────────────────────────────
cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Waqar</string>
    <string name="home">Home</string>
    <string name="explore">Explore</string>
    <string name="profile">Profile</string>
    <string name="home_subtitle">Discover Islamic Nasheeds</string>
    <string name="featured_label">Featured</string>
    <string name="featured_title">Top Nasheeds</string>
    <string name="play_now">Play Now</string>
    <string name="recently_played">Recently Played</string>
    <string name="categories">Categories</string>
    <string name="cat_quran">Quran</string>
    <string name="cat_madih">Madih</string>
    <string name="cat_children">Children</string>
    <string name="cat_educational">Educational</string>
    <string name="cat_ramadan">Ramadan</string>
    <string name="cat_various">Various</string>
    <string name="search_placeholder">Search nasheeds…</string>
    <string name="browse_categories">Browse Categories</string>
    <string name="profile_version">Version %1$s</string>
    <string name="settings">Settings</string>
    <string name="pref_appearance">Appearance</string>
    <string name="pref_appearance_sub">Dark &amp; Light theme</string>
    <string name="pref_language">Language</string>
    <string name="pref_language_sub">Arabic &amp; English</string>
    <string name="about">About</string>
    <string name="about_sub">About Waqar app</string>
</resources>
EOF

# ── 4. strings.xml (Arabic) ───────────────────────────────────────
mkdir -p app/src/main/res/values-ar
cat > app/src/main/res/values-ar/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">وقار</string>
    <string name="home">الرئيسية</string>
    <string name="explore">اكتشف</string>
    <string name="profile">حسابي</string>
    <string name="home_subtitle">اكتشف الأناشيد الإسلامية</string>
    <string name="featured_label">مميز</string>
    <string name="featured_title">أفضل الأناشيد</string>
    <string name="play_now">استمع الآن</string>
    <string name="recently_played">استمعت مؤخراً</string>
    <string name="categories">التصنيفات</string>
    <string name="cat_quran">القرآن الكريم</string>
    <string name="cat_madih">المديح</string>
    <string name="cat_children">الأطفال</string>
    <string name="cat_educational">التربوية</string>
    <string name="cat_ramadan">رمضانيات</string>
    <string name="cat_various">متنوعة</string>
    <string name="search_placeholder">ابحث عن نشيد…</string>
    <string name="browse_categories">تصفح التصنيفات</string>
    <string name="profile_version">الإصدار %1$s</string>
    <string name="settings">الإعدادات</string>
    <string name="pref_appearance">المظهر</string>
    <string name="pref_appearance_sub">الوضع الداكن والفاتح</string>
    <string name="pref_language">اللغة</string>
    <string name="pref_language_sub">العربية والإنجليزية</string>
    <string name="about">حول التطبيق</string>
    <string name="about_sub">معلومات عن وقار</string>
</resources>
EOF

# ── 5. Color.kt ───────────────────────────────────────────────────
cat > $PKG/ui/theme/Color.kt << 'EOF'
package com.xstudio.waqar.ui.theme

import androidx.compose.ui.graphics.Color

val RoyalBlue        = Color(0xFF4169E1)
val RoyalBlueLight   = Color(0xFF7B96EC)
val RoyalBlueDark    = Color(0xFF2A4BBF)

val DarkBackground   = Color(0xFF000000)
val DarkSurface      = Color(0xFF0D0D0D)
val DarkSurfaceVar   = Color(0xFF1A1A1A)

val LightBackground  = Color(0xFFFFFFFF)
val LightSurface     = Color(0xFFF5F5F5)
val LightSurfaceVar  = Color(0xFFEEEEEE)
EOF

# ── 6. Type.kt ────────────────────────────────────────────────────
cat > $PKG/ui/theme/Type.kt << 'EOF'
package com.xstudio.waqar.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.xstudio.waqar.R

val WaqarFont = FontFamily(Font(R.font.waqarfont))

val WaqarTypography = Typography(
    displaySmall  = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 32.sp, lineHeight = 40.sp),
    headlineLarge = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 28.sp, lineHeight = 36.sp),
    headlineMedium= TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 24.sp, lineHeight = 32.sp),
    headlineSmall = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 20.sp, lineHeight = 28.sp),
    titleLarge    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 18.sp, lineHeight = 26.sp),
    titleMedium   = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 16.sp, lineHeight = 24.sp),
    titleSmall    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 14.sp, lineHeight = 20.sp),
    bodyLarge     = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 16.sp, lineHeight = 24.sp),
    bodyMedium    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 14.sp, lineHeight = 20.sp),
    bodySmall     = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 12.sp, lineHeight = 16.sp),
    labelLarge    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 14.sp, lineHeight = 20.sp),
    labelMedium   = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 12.sp, lineHeight = 16.sp),
    labelSmall    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 11.sp, lineHeight = 16.sp),
)
EOF

# ── 7. Theme.kt ───────────────────────────────────────────────────
cat > $PKG/ui/theme/Theme.kt << 'EOF'
package com.xstudio.waqar.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColors = darkColorScheme(
    primary          = RoyalBlue,
    onPrimary        = Color.White,
    primaryContainer = RoyalBlueDark,
    secondary        = RoyalBlueLight,
    background       = DarkBackground,
    surface          = DarkSurface,
    surfaceVariant   = DarkSurfaceVar,
    onBackground     = Color.White,
    onSurface        = Color.White,
    onSurfaceVariant = Color(0xFFCCCCCC),
    outline          = Color(0xFF444444),
)

private val LightColors = lightColorScheme(
    primary          = RoyalBlue,
    onPrimary        = Color.White,
    primaryContainer = Color(0xFFDDE4FA),
    secondary        = RoyalBlueDark,
    background       = LightBackground,
    surface          = LightSurface,
    surfaceVariant   = LightSurfaceVar,
    onBackground     = Color(0xFF111111),
    onSurface        = Color(0xFF111111),
    onSurfaceVariant = Color(0xFF555555),
    outline          = Color(0xFFCCCCCC),
)

@Composable
fun WaqarTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography  = WaqarTypography,
        content     = content
    )
}
EOF

# ── 8. Screen.kt ──────────────────────────────────────────────────
mkdir -p $PKG/ui/navigation
cat > $PKG/ui/navigation/Screen.kt << 'EOF'
package com.xstudio.waqar.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.ui.graphics.vector.ImageVector
import com.xstudio.waqar.R

sealed class Screen(
    val route: String,
    val labelRes: Int,
    val icon: ImageVector
) {
    object Home    : Screen("home",    R.string.home,    Icons.Default.Home)
    object Explore : Screen("explore", R.string.explore, Icons.Default.Search)
    object Profile : Screen("profile", R.string.profile, Icons.Default.Person)

    companion object {
        val items = listOf(Home, Explore, Profile)
    }
}
EOF

# ── 9. MainScreen.kt ──────────────────────────────────────────────
cat > $PKG/ui/screens/MainScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.xstudio.waqar.ui.navigation.Screen

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    Scaffold(
        bottomBar = {
            NavigationBar(
                tonalElevation = 0.dp,
                containerColor = MaterialTheme.colorScheme.surface,
            ) {
                Screen.items.forEach { screen ->
                    val selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true
                    NavigationBarItem(
                        selected = selected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = {
                            Icon(
                                imageVector = screen.icon,
                                contentDescription = stringResource(screen.labelRes)
                            )
                        },
                        label = {
                            Text(
                                text = stringResource(screen.labelRes),
                                style = MaterialTheme.typography.labelSmall
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = MaterialTheme.colorScheme.primary,
                            selectedTextColor   = MaterialTheme.colorScheme.primary,
                            unselectedIconColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.45f),
                            unselectedTextColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.45f),
                            indicatorColor      = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f),
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController     = navController,
            startDestination  = Screen.Home.route,
            modifier          = Modifier.padding(innerPadding),
            enterTransition   = { fadeIn(tween(180)) },
            exitTransition    = { fadeOut(tween(180)) },
            popEnterTransition  = { fadeIn(tween(180)) },
            popExitTransition   = { fadeOut(tween(180)) },
        ) {
            composable(Screen.Home.route)    { HomeScreen() }
            composable(Screen.Explore.route) { ExploreScreen() }
            composable(Screen.Profile.route) { ProfileScreen() }
        }
    }
}
EOF

# ── 10. HomeScreen.kt ─────────────────────────────────────────────
cat > $PKG/ui/screens/HomeScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.xstudio.waqar.R

@Composable
fun HomeScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        listOf(
                            MaterialTheme.colorScheme.primary.copy(alpha = 0.13f),
                            Color.Transparent
                        )
                    )
                )
                .padding(horizontal = 20.dp, vertical = 28.dp)
        ) {
            Column {
                Text(
                    text = stringResource(R.string.app_name),
                    style = MaterialTheme.typography.displaySmall,
                    color = MaterialTheme.colorScheme.primary,
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    text = stringResource(R.string.home_subtitle),
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.55f)
                )
            }
        }

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .height(190.dp)
                .clip(RoundedCornerShape(22.dp))
                .background(
                    Brush.linearGradient(
                        listOf(
                            MaterialTheme.colorScheme.primary,
                            MaterialTheme.colorScheme.primary.copy(alpha = 0.55f)
                        )
                    )
                ),
            contentAlignment = Alignment.CenterStart
        ) {
            Column(modifier = Modifier.padding(horizontal = 24.dp, vertical = 20.dp)) {
                Text(
                    text = stringResource(R.string.featured_label),
                    style = MaterialTheme.typography.labelMedium,
                    color = Color.White.copy(alpha = 0.75f)
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    text = stringResource(R.string.featured_title),
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color.White,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.height(18.dp))
                Button(
                    onClick = {},
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.White.copy(alpha = 0.22f),
                        contentColor   = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Icon(Icons.Default.PlayArrow, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(stringResource(R.string.play_now), style = MaterialTheme.typography.labelLarge)
                }
            }
        }

        Spacer(Modifier.height(28.dp))

        Text(
            text = stringResource(R.string.recently_played),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.padding(horizontal = 20.dp)
        )
        Spacer(Modifier.height(12.dp))
        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(5) { NasheedCard(it) }
        }

        Spacer(Modifier.height(28.dp))

        Text(
            text = stringResource(R.string.categories),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.padding(horizontal = 20.dp)
        )
        Spacer(Modifier.height(12.dp))
        CategoriesGrid()
        Spacer(Modifier.height(90.dp))
    }
}

@Composable
private fun NasheedCard(index: Int) {
    val titles    = listOf("نشيد الفجر", "طلع البدر", "يا طيبة", "مولاي", "إلهي")
    val durations = listOf("3:24", "4:12", "2:58", "5:01", "3:44")
    Card(
        modifier = Modifier.size(width = 140.dp, height = 160.dp),
        shape    = RoundedCornerShape(16.dp),
        colors   = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant),
        elevation = CardDefaults.cardElevation(0.dp)
    ) {
        Box(Modifier.fillMaxSize()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(100.dp)
                    .background(
                        Brush.linearGradient(
                            listOf(
                                MaterialTheme.colorScheme.primary.copy(alpha = 0.75f + index * 0.05f),
                                MaterialTheme.colorScheme.primary.copy(alpha = 0.4f)
                            )
                        )
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.PlayArrow, contentDescription = null, tint = Color.White, modifier = Modifier.size(34.dp))
            }
            Column(
                modifier = Modifier.align(Alignment.BottomStart).padding(10.dp)
            ) {
                Text(
                    text  = titles.getOrElse(index) { "نشيد" },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    fontWeight = FontWeight.Medium,
                    maxLines = 1
                )
                Text(
                    text  = durations.getOrElse(index) { "3:00" },
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.55f)
                )
            }
        }
    }
}

@Composable
private fun CategoriesGrid() {
    val cats = listOf(
        R.string.cat_quran, R.string.cat_madih,
        R.string.cat_children, R.string.cat_educational,
        R.string.cat_ramadan, R.string.cat_various
    )
    Column(
        modifier = Modifier.padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        cats.chunked(2).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                row.forEach { res ->
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(52.dp)
                            .clip(RoundedCornerShape(14.dp))
                            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.08f))
                            .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.2f), RoundedCornerShape(14.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text  = stringResource(res),
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.primary,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
        }
    }
}
EOF

# ── 11. ExploreScreen.kt ──────────────────────────────────────────
cat > $PKG/ui/screens/ExploreScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.xstudio.waqar.R

private val categoryGradients = listOf(
    listOf(Color(0xFF1B5E20), Color(0xFF00897B)),
    listOf(Color(0xFF4A148C), Color(0xFF7B1FA2)),
    listOf(Color(0xFFE65100), Color(0xFFFF7043)),
    listOf(Color(0xFF0D47A1), Color(0xFF1976D2)),
    listOf(Color(0xFF827717), Color(0xFFF9A825)),
    listOf(Color(0xFF212121), Color(0xFF616161)),
)

@Composable
fun ExploreScreen() {
    var query by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
    ) {
        Spacer(Modifier.height(28.dp))
        Text(
            text  = stringResource(R.string.explore),
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(
            value       = query,
            onValueChange = { query = it },
            modifier    = Modifier.fillMaxWidth(),
            placeholder = { Text(stringResource(R.string.search_placeholder)) },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
            singleLine  = true,
            shape       = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                focusedLeadingIconColor   = MaterialTheme.colorScheme.primary,
                unfocusedLeadingIconColor = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
            )
        )
        Spacer(Modifier.height(28.dp))
        Text(
            text  = stringResource(R.string.browse_categories),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(Modifier.height(14.dp))

        val cats = listOf(
            R.string.cat_quran, R.string.cat_madih,
            R.string.cat_children, R.string.cat_educational,
            R.string.cat_ramadan, R.string.cat_various
        )
        cats.chunked(2).forEachIndexed { rowIdx, row ->
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                row.forEachIndexed { colIdx, res ->
                    val gradIdx = rowIdx * 2 + colIdx
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(88.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .background(Brush.linearGradient(categoryGradients[gradIdx])),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text  = stringResource(res),
                            style = MaterialTheme.typography.titleSmall,
                            color = Color.White,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
            if (rowIdx < cats.chunked(2).lastIndex) Spacer(Modifier.height(12.dp))
        }
        Spacer(Modifier.height(90.dp))
    }
}
EOF

# ── 12. ProfileScreen.kt ──────────────────────────────────────────
cat > $PKG/ui/screens/ProfileScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.xstudio.waqar.R

@Composable
fun ProfileScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        listOf(
                            MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                            Color.Transparent
                        )
                    )
                )
                .padding(vertical = 36.dp),
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.12f))
                        .border(2.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.35f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(46.dp)
                    )
                }
                Spacer(Modifier.height(16.dp))
                Text(
                    text  = stringResource(R.string.app_name),
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    text  = stringResource(R.string.profile_version, "1.0"),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.45f)
                )
            }
        }

        Spacer(Modifier.height(4.dp))
        HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))
        Spacer(Modifier.height(8.dp))

        Text(
            text  = stringResource(R.string.settings),
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 10.dp)
        )

        SettingsItem(
            title    = stringResource(R.string.pref_appearance),
            subtitle = stringResource(R.string.pref_appearance_sub),
            icon     = Icons.Default.Settings
        )
        SettingsItem(
            title    = stringResource(R.string.pref_language),
            subtitle = stringResource(R.string.pref_language_sub),
            icon     = Icons.Default.Favorite
        )
        SettingsItem(
            title    = stringResource(R.string.about),
            subtitle = stringResource(R.string.about_sub),
            icon     = Icons.Default.Info
        )
        Spacer(Modifier.height(90.dp))
    }
}

@Composable
private fun SettingsItem(
    title: String,
    subtitle: String,
    icon: ImageVector,
    onClick: () -> Unit = {}
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        onClick  = onClick,
        color    = Color.Transparent
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(RoundedCornerShape(13.dp))
                    .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(20.dp)
                )
            }
            Spacer(Modifier.width(14.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text  = title,
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                    text  = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                )
            }
        }
    }
}
EOF

# ── 13. MainActivity.kt ───────────────────────────────────────────
cat > $PKG/MainActivity.kt << 'EOF'
package com.xstudio.waqar

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.xstudio.waqar.ui.screens.MainScreen
import com.xstudio.waqar.ui.theme.WaqarTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen().setOnExitAnimationListener { view ->
            view.iconView.animate()
                .scaleX(1.15f).scaleY(1.15f).alpha(0f)
                .setDuration(400L)
                .withEndAction { view.remove() }
                .start()
        }
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            WaqarTheme {
                MainScreen()
            }
        }
    }
}
EOF

# ── Git ────────────────────────────────────────────────────────────
git add .
git commit -m "feat: full UI - bottom nav, 3 screens, WaqarFont, RTL, dark/light themes, fix APK size"
git push

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📌 لإصلاح مشكلة تحديث الحزمة نهائياً:"
echo ""
echo "شغّل هذا مرة واحدة على جهازك:"
echo ""
echo "  keytool -genkeypair -v \\"
echo "    -keystore debug.keystore \\"
echo "    -storepass android -alias androiddebugkey -keypass android \\"
echo "    -keyalg RSA -keysize 2048 -validity 10000 \\"
echo "    \"-dname CN=Android Debug,O=Android,C=US\""
echo ""
echo "  base64 debug.keystore"
echo ""
echo "ثم اذهب إلى: GitHub → Settings → Secrets → Actions"
echo "وأضف secret جديد اسمه: DEBUG_KEYSTORE_B64"
echo "وضع فيه ناتج الأمر السابق"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
