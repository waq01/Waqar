package com.xstudio.waqar.ui.navigation

sealed class Screen(val route: String) {
    object Home    : Screen("home")
    object Explore : Screen("explore")
    object Profile : Screen("profile")
}
