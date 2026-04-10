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
