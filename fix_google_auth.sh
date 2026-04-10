#!/bin/bash
set -e
PKG=app/src/main/java/com/xstudio/waqar

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 إصلاح Google Sign-In"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. dependency ─────────────────────────────────────────────────────
if ! grep -q "play-services-auth" app/build.gradle; then
    sed -i "s|implementation 'com.google.firebase:firebase-auth-ktx'|implementation 'com.google.firebase:firebase-auth-ktx'\n    implementation 'com.google.android.gms:play-services-auth:21.2.0'|" app/build.gradle
    echo "✅ أضفت play-services-auth"
else
    echo "⏭️  play-services-auth موجود"
fi

# ── 2. AuthViewModel.kt ───────────────────────────────────────────────
cat > $PKG/auth/AuthViewModel.kt << 'EOF'
package com.xstudio.waqar.auth

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
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
        _authState.value = auth.currentUser
            ?.let { AuthState.SignedIn(it) }
            ?: AuthState.SignedOut
    }

    // ── يُستدعى من AuthScreen قبل لانش الـ intent ────────────────────
    fun buildSignInIntent(activity: Activity): Intent =
        buildClient(activity).signInIntent

    // ── يُستدعى بعد رجوع الـ intent ──────────────────────────────────
    fun handleSignInResult(data: Intent?) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val account = GoogleSignIn
                    .getSignedInAccountFromIntent(data)
                    .getResult(ApiException::class.java)

                val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                val result     = auth.signInWithCredential(credential).await()
                _authState.value = AuthState.SignedIn(result.user!!)
                _uiState.update { it.copy(isLoading = false) }

            } catch (e: ApiException) {
                // كود 10 = SHA-1 غلط | كود 12501 = ألغى المستخدم
                val msg = when (e.statusCode) {
                    10     -> "تحقق من SHA-1 في Firebase (كود 10)"
                    12501  -> null   // ألغى → لا رسالة
                    else   -> "فشل تسجيل الدخول (كود ${e.statusCode})"
                }
                _uiState.update { it.copy(isLoading = false, error = msg) }

            } catch (e: Exception) {
                _uiState.update {
                    it.copy(isLoading = false, error = "${e::class.simpleName}: ${e.message}")
                }
            }
        }
    }

    fun setLoading() = _uiState.update { it.copy(isLoading = true, error = null) }

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

    fun signOut(activity: Activity) {
        viewModelScope.launch {
            buildClient(activity).signOut().await()
            auth.signOut()
            _authState.value = AuthState.SignedOut
        }
    }

    fun clearError() = _uiState.update { it.copy(error = null) }

    private fun buildClient(activity: Activity): GoogleSignInClient {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(activity.getString(R.string.web_client_id))
            .requestEmail()
            .build()
        return GoogleSignIn.getClient(activity, gso)
    }
}
EOF
echo "✅ AuthViewModel.kt"

# ── 3. AuthScreen.kt ──────────────────────────────────────────────────
cat > $PKG/ui/screens/AuthScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import android.app.Activity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
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

@Composable
fun AuthScreen(viewModel: AuthViewModel) {
    val uiState  by viewModel.uiState.collectAsStateWithLifecycle()
    val activity = LocalContext.current as Activity
    val isDark   = isSystemInDarkTheme()

    // ── Launcher ──────────────────────────────────────────────────────
    val launcher = rememberLauncherForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        viewModel.handleSignInResult(result.data)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    if (isDark) listOf(Color(0xFF06091A), Color(0xFF000000))
                    else        listOf(Color(0xFFF4F7FF), Color(0xFFFFFFFF))
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

            // ── رسالة الخطأ ───────────────────────────────────────────
            AnimatedVisibility(
                visible = uiState.error != null,
                enter   = fadeIn(),
                exit    = fadeOut()
            ) {
                Text(
                    text      = uiState.error.orEmpty(),
                    style     = MaterialTheme.typography.bodySmall,
                    color     = MaterialTheme.colorScheme.error,
                    textAlign = TextAlign.Center,
                    modifier  = Modifier.padding(bottom = 14.dp)
                )
            }

            // ── زر Google ─────────────────────────────────────────────
            Surface(
                modifier        = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .clip(RoundedCornerShape(16.dp)),
                color           = Color.White,
                shadowElevation = 3.dp,
                onClick         = {
                    if (!uiState.isLoading) {
                        viewModel.setLoading()
                        launcher.launch(viewModel.buildSignInIntent(activity))
                    }
                }
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

            // ── زر الضيف ──────────────────────────────────────────────
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
echo "✅ AuthScreen.kt"

# ── 4. push ───────────────────────────────────────────────────────────
git add .
git commit -m "fix: replace CredentialManager with legacy GoogleSignIn (EMUI compatible)"
git push

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ تم! انتظر الـ workflow وجرّب"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
