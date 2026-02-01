package com.hainanmandi.founderevents.ui.screens.myevents

import androidx.compose.material3.Badge
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

@Composable
fun StatusBadge(status: String) {
    val (backgroundColor, textColor, label) = when (status) {
        "PUBLISHED" -> Triple(
            Color(0xFF4CAF50).copy(alpha = 0.1f),
            Color(0xFF4CAF50),
            "PUBLISHED"
        )
        "DRAFT" -> Triple(
            MaterialTheme.colorScheme.surfaceVariant,
            MaterialTheme.colorScheme.onSurfaceVariant,
            "DRAFT"
        )
        "CANCELLED" -> Triple(
            MaterialTheme.colorScheme.errorContainer,
            MaterialTheme.colorScheme.onErrorContainer,
            "CANCELLED"
        )
        "COMPLETED" -> Triple(
            Color(0xFF2196F3).copy(alpha = 0.1f),
            Color(0xFF2196F3),
            "COMPLETED"
        )
        else -> Triple(
            MaterialTheme.colorScheme.surfaceVariant,
            MaterialTheme.colorScheme.onSurfaceVariant,
            status
        )
    }

    Badge(
        containerColor = backgroundColor,
        contentColor = textColor
    ) {
        Text(label, fontSize = 10.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun VisibilityBadge(visibility: String) {
    val (backgroundColor, textColor, label) = when (visibility) {
        "PUBLIC" -> Triple(
            Color(0xFF4CAF50).copy(alpha = 0.1f),
            Color(0xFF4CAF50),
            "LISTED"
        )
        "UNLISTED" -> Triple(
            Color(0xFFFF9800).copy(alpha = 0.1f),
            Color(0xFFFF9800),
            "UNLISTED"
        )
        else -> Triple(
            MaterialTheme.colorScheme.surfaceVariant,
            MaterialTheme.colorScheme.onSurfaceVariant,
            visibility
        )
    }

    Badge(
        containerColor = backgroundColor,
        contentColor = textColor
    ) {
        Text(label, fontSize = 10.sp, fontWeight = FontWeight.Bold)
    }
}