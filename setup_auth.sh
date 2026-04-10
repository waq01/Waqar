#!/bin/bash
set -e

PKG=app/src/main/java/com/xstudio/waqar
mkdir -p $PKG/auth

# ── 1. Root build.gradle ──────────────────────────────────────────────
cat > build.gradle << 'EOF'
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        maven { url 'https://jitpack.io' }
        maven { url "https://plugins.gradle.org/m2/" }
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.4.0-alpha07'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.1'
    }
}

allprojects {
    repositories {
        google()
        maven { url 'https://jitpack.io' }
        maven { url "https://plugins.gradle.org/m2/" }
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# ── 2. app/build.gradle ───────────────────────────────────────────────
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.gms.google-services'
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

    kotlinOptions { jvmTarget = '17' }

    buildFeatures { compose true }

    composeOptions { kotlinCompilerExtensionVersion '1.5.10' }
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

    implementation platform('com.google.firebase:firebase-bom:33.1.0')
    implementation 'com.google.firebase:firebase-auth-ktx'

    implementation 'androidx.credentials:credentials:1.3.0'
    implementation 'androidx.credentials:credentials-play-services-auth:1.3.0'
    implementation 'com.google.android.libraries.identity.googleid:googleid:1.1.1'

    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.7.3'
    implementation 'androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0'
    implementation 'androidx.lifecycle:lifecycle-runtime-compose:2.7.0'
}
EOF

# ── 3. AndroidManifest.xml ────────────────────────────────────────────
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.Waqar.Splash">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# ── 4. strings.xml (English) ──────────────────────────────────────────
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
    <string name="auth_tagline">Listen and enjoy Islamic Nasheeds</string>
    <string name="auth_sign_in_google">Continue with Google</string>
    <string name="auth_continue_guest">Continue as Guest</string>
    <string name="auth_or">or</string>
    <string name="web_client_id">55355514951-jtt20bj49lf344f9d7c9q17ql77omcb0.apps.googleusercontent.com</string>
</resources>
EOF

# ── 5. strings.xml (Arabic) ───────────────────────────────────────────
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
    <string name="auth_tagline">استمع وتذوّق الأناشيد الإسلامية</string>
    <string name="auth_sign_in_google">المتابعة بـ Google</string>
    <string name="auth_continue_guest">متابعة كضيف</string>
    <string name="auth_or">أو</string>
    <string name="web_client_id">55355514951-jtt20bj49lf344f9d7c9q17ql77omcb0.apps.googleusercontent.com</string>
</resources>
EOF

# ── 6. Google icon vector ─────────────────────────────────────────────
cat > app/src/main/res/drawable/ic_google.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path android:fillColor="#4285F4"
        android:pathData="M22.56,12.25c0,-0.78 -0.07,-1.53 -0.2,-2.25H12v4.26h5.92c-0.26,1.37 -1.04,2.53 -2.21,3.31v2.77h3.57c2.08,-1.92 3.28,-4.74 3.28,-8.09z"/>
    <path android:fillColor="#34A853"
        android:pathData="M12,23c2.97,0 5.46,-0.98 7.28,-2.66l-3.57,-2.77c-0.98,0.66 -2.23,1.06 -3.71,1.06 -2.86,0 -5.29,-1.93 -6.16,-4.53H2.18v2.84C3.99,20.53 7.7,23 12,23z"/>
    <path android:fillColor="#FBBC05"
        android:pathData="M5.84,14.09c-0.22,-0.66 -0.35,-1.36 -0.35,-2.09s0.13,-1.43 0.35,-2.09V7.07H2.18C1.43,8.55 1,10.22 1,12s0.43,3.45 1.18,4.93l2.85,-2.22 0.81,-0.62z"/>
    <path android:fillColor="#EA4335"
        android:pathData="M12,5.38c1.62,0 3.06,0.56 4.21,1.64l3.15,-3.15C17.45,2.09 14.97,1 12,1 7.7,1 3.99,3.47 2.18,7.07l3.66,2.84c0.87,-2.6 3.3,-4.53 6.16,-4.53z"/>
</vector>
EOF

# ── 7. AuthViewModel.kt ───────────────────────────────────────────────
cat > $PKG/auth/AuthViewModel.kt << 'EOF'
package com.xstudio.waqar.auth

import android.app.Activity
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.xstudio.waqar.R
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

sealed class AuthState {
    object Checking  : AuthState()
    object SignedOut : AuthState()
    data class SignedIn(val user: FirebaseUser) : AuthState()
}

data class AuthUiState(
    val isLoading: Boolean = false,
    val error: String?     = null
)

class AuthViewModel : ViewModel() {

    private val auth = FirebaseAuth.getInstance()

    private val _authState = MutableStateFlow<AuthState>(AuthState.Checking)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        val user = auth.currentUser
        _authState.value = if (user != null) AuthState.SignedIn(user) else AuthState.SignedOut
    }

    fun signInWithGoogle(activity: Activity) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val credentialManager = CredentialManager.create(activity)
                val googleIdOption = GetGoogleIdOption.Builder()
                    .setFilterByAuthorizedAccounts(false)
                    .setServerClientId(activity.getString(R.string.web_client_id))
                    .setAutoSelectEnabled(false)
                    .build()
                val request = GetCredentialRequest.Builder()
                    .addCredentialOption(googleIdOption)
                    .build()
                val result     = credentialManager.getCredential(activity, request)
                val credential = result.credential
                if (credential is CustomCredential &&
                    credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
                ) {
                    val googleToken        = GoogleIdTokenCredential.createFrom(credential.data)
                    val firebaseCredential = GoogleAuthProvider.getCredential(googleToken.idToken, null)
                    val authResult         = auth.signInWithCredential(firebaseCredential).await()
                    _authState.value = AuthState.SignedIn(authResult.user!!)
                    _uiState.update { it.copy(isLoading = false) }
                } else {
                    _uiState.update { it.copy(isLoading = false, error = "فشل تسجيل الدخول") }
                }
            } catch (e: GetCredentialCancellationException) {
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "فشل تسجيل الدخول، حاول مرة أخرى") }
            }
        }
    }

    fun signInAsGuest() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val result = auth.signInAnonymously().await()
                _authState.value = AuthState.SignedIn(result.user!!)
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "فشل الدخول كضيف") }
            }
        }
    }

    fun clearError() = _uiState.update { it.copy(error = null) }
}
EOF

# ── 8. AuthScreen.kt ──────────────────────────────────────────────────
cat > $PKG/ui/screens/AuthScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import android.app.Activity
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xstudio.waqar.R
import com.xstudio.waqar.auth.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(viewModel: AuthViewModel) {
    val uiState  by viewModel.uiState.collectAsStateWithLifecycle()
    val context  = LocalContext.current
    val activity = context as Activity
    val isDark   = isSystemInDarkTheme()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    if (isDark)
                        listOf(Color(0xFF06091A), Color(0xFF000000))
                    else
                        listOf(Color(0xFFF4F7FF), Color(0xFFFFFFFF))
                )
            )
    ) {
        Column(
            modifier            = Modifier
                .fillMaxSize()
                .padding(horizontal = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {

            Spacer(Modifier.weight(1.8f))

            Image(
                painter            = painterResource(
                    if (isDark) R.drawable.ic_app_dark else R.drawable.ic_app
                ),
                contentDescription = null,
                modifier           = Modifier.size(92.dp)
            )

            Spacer(Modifier.height(22.dp))

            Text(
                text  = stringResource(R.string.app_name),
                style = MaterialTheme.typography.displaySmall,
                color = MaterialTheme.colorScheme.primary
            )

            Spacer(Modifier.height(10.dp))

            Text(
                text      = stringResource(R.string.auth_tagline),
                style     = MaterialTheme.typography.bodyMedium,
                color     = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.48f),
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.weight(2f))

            AnimatedVisibility(visible = uiState.error != null) {
                Text(
                    text      = uiState.error.orEmpty(),
                    style     = MaterialTheme.typography.bodySmall,
                    color     = MaterialTheme.colorScheme.error,
                    textAlign = TextAlign.Center,
                    modifier  = Modifier.padding(bottom = 14.dp)
                )
            }

            Surface(
                modifier        = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .clip(RoundedCornerShape(16.dp)),
                color           = Color.White,
                shadowElevation = 3.dp,
                onClick         = { if (!uiState.isLoading) viewModel.signInWithGoogle(activity) }
            ) {
                Box(contentAlignment = Alignment.Center) {
                    if (uiState.isLoading) {
                        CircularProgressIndicator(
                            modifier    = Modifier.size(22.dp),
                            color       = Color(0xFF4285F4),
                            strokeWidth = 2.dp
                        )
                    } else {
                        Row(
                            verticalAlignment     = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Icon(
                                painter            = painterResource(R.drawable.ic_google),
                                contentDescription = null,
                                tint               = Color.Unspecified,
                                modifier           = Modifier.size(20.dp)
                            )
                            Spacer(Modifier.width(10.dp))
                            Text(
                                text       = stringResource(R.string.auth_sign_in_google),
                                style      = MaterialTheme.typography.labelLarge,
                                color      = Color(0xFF1F1F1F),
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                HorizontalDivider(
                    modifier = Modifier.weight(1f),
                    color    = MaterialTheme.colorScheme.outline.copy(alpha = 0.25f)
                )
                Text(
                    text     = stringResource(R.string.auth_or),
                    style    = MaterialTheme.typography.labelSmall,
                    color    = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.38f),
                    modifier = Modifier.padding(horizontal = 14.dp)
                )
                HorizontalDivider(
                    modifier = Modifier.weight(1f),
                    color    = MaterialTheme.colorScheme.outline.copy(alpha = 0.25f)
                )
            }

            Spacer(Modifier.height(20.dp))

            OutlinedButton(
                onClick  = { viewModel.signInAsGuest() },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp),
                shape    = RoundedCornerShape(16.dp),
                border   = BorderStroke(
                    1.dp,
                    MaterialTheme.colorScheme.outline.copy(alpha = 0.35f)
                ),
                enabled  = !uiState.isLoading
            ) {
                Text(
                    text  = stringResource(R.string.auth_continue_guest),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.65f)
                )
            }

            Spacer(Modifier.height(44.dp))
        }
    }
}
EOF

# ── 9. MainActivity.kt ────────────────────────────────────────────────
cat > $PKG/MainActivity.kt << 'EOF'
package com.xstudio.waqar

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xstudio.waqar.auth.AuthState
import com.xstudio.waqar.auth.AuthViewModel
import com.xstudio.waqar.ui.screens.AuthScreen
import com.xstudio.waqar.ui.screens.MainScreen
import com.xstudio.waqar.ui.theme.WaqarTheme

class MainActivity : ComponentActivity() {

    private val authViewModel: AuthViewModel by viewModels()
    private lateinit var insetsController: WindowInsetsControllerCompat

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

        insetsController = WindowInsetsControllerCompat(window, window.decorView).apply {
            systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
        hideSystemBars()

        setContent {
            WaqarTheme {
                val authState by authViewModel.authState.collectAsStateWithLifecycle()
                when (authState) {
                    AuthState.Checking   -> Box(
                        Modifier
                            .fillMaxSize()
                            .background(MaterialTheme.colorScheme.background)
                    )
                    AuthState.SignedOut  -> AuthScreen(authViewModel)
                    is AuthState.SignedIn -> MainScreen()
                }
            }
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) hideSystemBars()
    }

    private fun hideSystemBars() {
        insetsController.hide(
            WindowInsetsCompat.Type.statusBars() or WindowInsetsCompat.Type.navigationBars()
        )
    }
}
EOF

git add .
git commit -m "feat: Google Sign-In + Anonymous auth, AuthScreen, INTERNET permission"
git push

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ تم!"
echo ""
echo "⚠️  مهم: نزّل google-services.json من جديد"
echo "Project Settings → Your apps → google-services.json"
echo "وضعه في app/ بدل القديم"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
