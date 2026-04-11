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
