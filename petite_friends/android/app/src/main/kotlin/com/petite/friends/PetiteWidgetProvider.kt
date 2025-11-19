package com.petite.friends

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PetiteWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_layout
            ).apply {
                // Get data from SharedPreferences
                val widgetData = HomeWidgetPlugin.getData(context)
                val petName = widgetData.getString("pet_name", "펫")
                val petEmoji = widgetData.getString("pet_emoji", "🐱")
                val petHunger = widgetData.getInt("pet_hunger", 100)
                val petMood = widgetData.getInt("pet_mood", 100)
                val petHealth = widgetData.getInt("pet_health", 100)
                val petLevel = widgetData.getInt("pet_level", 1)
                val isSleeping = widgetData.getBoolean("pet_is_sleeping", false)
                val isSick = widgetData.getBoolean("pet_is_sick", false)
                val hearts = widgetData.getInt("currency_hearts", 0)
                val coins = widgetData.getInt("currency_coins", 0)

                // Update UI
                setTextViewText(R.id.widget_pet_name, petName)
                setTextViewText(R.id.widget_pet_emoji, petEmoji)
                setTextViewText(R.id.widget_pet_level, "Lv.$petLevel")

                // Status bars
                setProgressBar(R.id.widget_hunger_bar, 100, petHunger, false)
                setProgressBar(R.id.widget_mood_bar, 100, petMood, false)
                setProgressBar(R.id.widget_health_bar, 100, petHealth, false)

                // Currency
                setTextViewText(R.id.widget_hearts, "💙 $hearts")
                setTextViewText(R.id.widget_coins, "🪙 $coins")

                // Status message
                val statusMessage = when {
                    isSick -> "아파요 🤒"
                    isSleeping -> "자는 중 😴"
                    petHunger < 30 -> "배고파요 🍎"
                    petMood < 30 -> "심심해요 🎮"
                    petHealth < 50 -> "건강이 안좋아요 💊"
                    else -> "건강해요! ✨"
                }
                setTextViewText(R.id.widget_status_message, statusMessage)

                // Set click listeners
                val pendingIntent = HomeWidgetPlugin.getPendingIntentForUpdateWidget(
                    context,
                    PetiteWidgetProvider::class.java,
                    "open_app"
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
