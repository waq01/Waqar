package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.xstudio.waqar.auth.AuthViewModel

@Composable
fun AuthScreen(viewModel: AuthViewModel) {
    Column(
        modifier            = Modifier.fillMaxSize().padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("تسجيل الدخول", style = MaterialTheme.typography.headlineLarge)
        Spacer(Modifier.height(32.dp))
        Button(onClick = { viewModel.signInAsGuest() }, modifier = Modifier.fillMaxWidth()) {
            Text("دخول كضيف")
        }
    }
}
