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
                    AuthState.Checking    -> Box(
                        Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)
                    )
                    AuthState.SignedOut   -> AuthScreen(authViewModel)
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
