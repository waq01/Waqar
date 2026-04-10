package com.xstudio.waqar.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.xstudio.waqar.R

private val categoryGradients = listOf(
    listOf(Color(0xFF1B5E20), Color(0xFF00897B)),
    listOf(Color(0xFF4A148C), Color(0xFF7B1FA2)),
    listOf(Color(0xFFE65100), Color(0xFFFF7043)),
    listOf(Color(0xFF0D47A1), Color(0xFF1976D2)),
    listOf(Color(0xFF827717), Color(0xFFF9A825)),
    listOf(Color(0xFF212121), Color(0xFF616161)),
)

@Composable
fun ExploreScreen() {
    var query by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp)
    ) {
        Spacer(Modifier.height(28.dp))
        Text(
            text  = stringResource(R.string.explore),
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(Modifier.height(16.dp))
        OutlinedTextField(
            value       = query,
            onValueChange = { query = it },
            modifier    = Modifier.fillMaxWidth(),
            placeholder = { Text(stringResource(R.string.search_placeholder)) },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
            singleLine  = true,
            shape       = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline,
                focusedLeadingIconColor   = MaterialTheme.colorScheme.primary,
                unfocusedLeadingIconColor = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
            )
        )
        Spacer(Modifier.height(28.dp))
        Text(
            text  = stringResource(R.string.browse_categories),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Spacer(Modifier.height(14.dp))

        val cats = listOf(
            R.string.cat_quran, R.string.cat_madih,
            R.string.cat_children, R.string.cat_educational,
            R.string.cat_ramadan, R.string.cat_various
        )
        cats.chunked(2).forEachIndexed { rowIdx, row ->
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                row.forEachIndexed { colIdx, res ->
                    val gradIdx = rowIdx * 2 + colIdx
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(88.dp)
                            .clip(RoundedCornerShape(18.dp))
                            .background(Brush.linearGradient(categoryGradients[gradIdx])),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text  = stringResource(res),
                            style = MaterialTheme.typography.titleSmall,
                            color = Color.White,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
            if (rowIdx < cats.chunked(2).lastIndex) Spacer(Modifier.height(12.dp))
        }
        Spacer(Modifier.height(90.dp))
    }
}
