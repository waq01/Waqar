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
