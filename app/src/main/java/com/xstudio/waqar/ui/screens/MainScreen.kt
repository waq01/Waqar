package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.xstudio.waqar.ui.navigation.Screen

@Composable
fun MainScreen() {
    val navController = rememberNavController()
    val currentRoute  = navController.currentBackStackEntryAsState().value?.destination?.route

    Scaffold(
        bottomBar = {
            NavigationBar {
                listOf(Screen.Home, Screen.Explore, Screen.Profile).forEach { screen ->
                    NavigationBarItem(
                        selected = currentRoute == screen.route,
                        onClick  = { navController.navigate(screen.route) { launchSingleTop = true } },
                        icon     = { Text(screen.route.first().uppercaseChar().toString()) },
                        label    = { Text(screen.route) }
                    )
                }
            }
        }
    ) { padding ->
        NavHost(
            navController    = navController,
            startDestination = Screen.Home.route,
            modifier         = Modifier.padding(padding)
        ) {
            composable(Screen.Home.route)    { HomeScreen() }
            composable(Screen.Explore.route) { ExploreScreen() }
            composable(Screen.Profile.route) { ProfileScreen() }
        }
    }
}
