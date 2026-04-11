package com.xstudio.waqar.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.xstudio.waqar.R

val WaqarFont = FontFamily(Font(R.font.waqarfont))

val WaqarTypography = Typography(
    displaySmall  = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 32.sp, lineHeight = 40.sp),
    headlineLarge = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 28.sp, lineHeight = 36.sp),
    headlineMedium= TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Bold,   fontSize = 24.sp, lineHeight = 32.sp),
    headlineSmall = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 20.sp, lineHeight = 28.sp),
    titleLarge    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 18.sp, lineHeight = 26.sp),
    titleMedium   = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.SemiBold,fontSize = 16.sp, lineHeight = 24.sp),
    titleSmall    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 14.sp, lineHeight = 20.sp),
    bodyLarge     = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 16.sp, lineHeight = 24.sp),
    bodyMedium    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 14.sp, lineHeight = 20.sp),
    bodySmall     = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Normal,  fontSize = 12.sp, lineHeight = 16.sp),
    labelLarge    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 14.sp, lineHeight = 20.sp),
    labelMedium   = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 12.sp, lineHeight = 16.sp),
    labelSmall    = TextStyle(fontFamily = WaqarFont, fontWeight = FontWeight.Medium,  fontSize = 11.sp, lineHeight = 16.sp),
)
