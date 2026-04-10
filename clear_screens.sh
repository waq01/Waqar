#!/bin/bash
set -e

PKG=app/src/main/java/com/xstudio/waqar

cat > $PKG/ui/screens/HomeScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun HomeScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    )
}
EOF

cat > $PKG/ui/screens/ExploreScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun ExploreScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    )
}
EOF

cat > $PKG/ui/screens/ProfileScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun ProfileScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    )
}
EOF

git add .
git commit -m "chore: clear all demo content from screens"
git push

echo "✅ تم تفريغ HomeScreen و ExploreScreen و ProfileScreen"
