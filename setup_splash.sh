mkdir -p app/src/main/java/com/xstudio/waqar/ui/theme
mkdir -p app/src/main/java/com/xstudio/waqar/ui/screens

cat > app/src/main/java/com/xstudio/waqar/ui/theme/Color.kt << 'EOF'
package com.xstudio.waqar.ui.theme
import androidx.compose.ui.graphics.Color
val PrimaryPurple = Color(0xFF9B59B6)
val DarkBg = Color(0xFF000000)
val LightBg = Color(0xFFFFFFFF)
EOF

cat > app/src/main/java/com/xstudio/waqar/ui/theme/Type.kt << 'EOF'
package com.xstudio.waqar.ui.theme
import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
val Typography = Typography(
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )
)
EOF

cat > app/src/main/java/com/xstudio/waqar/ui/theme/Theme.kt << 'EOF'
package com.xstudio.waqar.ui.theme
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
private val DarkColors = darkColorScheme(
    background = Color(0xFF000000),
    surface = Color(0xFF0D0D0D),
    primary = Color(0xFF9B59B6),
    onBackground = Color(0xFFFFFFFF),
    onSurface = Color(0xFFFFFFFF)
)
private val LightColors = lightColorScheme(
    background = Color(0xFFFFFFFF),
    surface = Color(0xFFF5F5F5),
    primary = Color(0xFF9B59B6),
    onBackground = Color(0xFF000000),
    onSurface = Color(0xFF000000)
)
@Composable
fun WaqarTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        typography = Typography,
        content = content
    )
}
EOF

cat > app/src/main/java/com/xstudio/waqar/ui/screens/SplashScreen.kt << 'EOF'
package com.xstudio.waqar.ui.screens
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.res.painterResource
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import com.xstudio.waqar.R
@Composable
fun SplashScreen(onFinish: () -> Unit) {
    val alpha = remember { Animatable(0f) }
    val scale = remember { Animatable(0.85f) }
    LaunchedEffect(Unit) {
        launch {
            alpha.animateTo(1f, animationSpec = tween(900, easing = EaseOut))
        }
        scale.animateTo(
            targetValue = 1f,
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioMediumBouncy,
                stiffness = Spring.StiffnessLow
            )
        )
        delay(2000)
        onFinish()
    }
    val logo = if (isSystemInDarkTheme()) R.drawable.ic_app_dark else R.drawable.ic_app
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(id = logo),
            contentDescription = null,
            modifier = Modifier
                .fillMaxWidth(0.72f)
                .alpha(alpha.value)
                .scale(scale.value)
        )
    }
}
EOF

cat > app/src/main/java/com/xstudio/waqar/MainActivity.kt << 'EOF'
package com.xstudio.waqar
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import com.xstudio.waqar.ui.screens.SplashScreen
import com.xstudio.waqar.ui.theme.WaqarTheme
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            WaqarTheme {
                var showSplash by remember { mutableStateOf(true) }
                if (showSplash) {
                    SplashScreen(onFinish = { showSplash = false })
                }
            }
        }
    }
}
EOF
