#!/bin/bash
set -e

PKG=app/src/main/java/com/xstudio/waqar

cat > $PKG/MainActivity.kt << 'EOF'
package com.xstudio.waqar

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.xstudio.waqar.ui.screens.MainScreen
import com.xstudio.waqar.ui.theme.WaqarTheme

class MainActivity : ComponentActivity() {

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
                MainScreen()
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

cat > $PKG/ui/screens/MainScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
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
    val navController       = rememberNavController()
    val navBackStackEntry   by navController.currentBackStackEntryAsState()
    val currentDestination  = navBackStackEntry?.destination
    val isDark              = isSystemInDarkTheme()

    val navBackground = if (isDark) Color(0xFF000000) else Color(0xFFFFFFFF)
    val dividerColor  = if (isDark)
        Color.White.copy(alpha = 0.10f)
    else
        Color.Black.copy(alpha = 0.08f)

    Scaffold(
        bottomBar = {
            Column {
                HorizontalDivider(
                    thickness = 0.5.dp,
                    color     = dividerColor
                )
                NavigationBar(
                    modifier       = Modifier.height(58.dp),
                    tonalElevation = 0.dp,
                    containerColor = navBackground,
                    windowInsets   = WindowInsets(0, 0, 0, 0),
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
                                    restoreState    = true
                                }
                            },
                            icon = {
                                Icon(
                                    imageVector        = screen.icon,
                                    contentDescription = stringResource(screen.labelRes)
                                )
                            },
                            label = {
                                Text(
                                    text  = stringResource(screen.labelRes),
                                    style = MaterialTheme.typography.labelSmall
                                )
                            },
                            alwaysShowLabel = true,
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
        },
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
    ) { innerPadding ->
        NavHost(
            navController       = navController,
            startDestination    = Screen.Home.route,
            modifier            = Modifier.padding(innerPadding),
            enterTransition     = { fadeIn(tween(180)) },
            exitTransition      = { fadeOut(tween(180)) },
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

git add .
git commit -m "fix: re-hide bars on focus, YouTube-style nav divider dark/light"
git push

echo "✅ تم: status bar لا يرجع عند العودة، فاصل بوتوم ناف داكن/فاتح"
