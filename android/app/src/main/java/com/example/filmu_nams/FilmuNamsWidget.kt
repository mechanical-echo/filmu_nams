package com.example.filmu_nams

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.io.File
import kotlin.math.min

class FilmuNamsWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.filmu_nams_widget)

            val ticketsJson = widgetData.getString("tickets_data", "[]")
            val tickets = JSONArray(ticketsJson)
 
            views.removeAllViews(R.id.ticket_container)

            for (i in 0 until min(3, tickets.length())) {
                val ticket = tickets.getJSONObject(i)
                val title = ticket.optString("movieTitle", "Filma")
                val date = ticket.optString("formattedDate", "")
                val time = ticket.optString("formattedTime", "")
                val seat = ticket.optString("seat", "")
                val hall = ticket.optInt("hall", 0)

                val ticketView = RemoteViews(context.packageName, R.layout.ticket_view)
                ticketView.setTextViewText(R.id.ticket_title, title)
                ticketView.setTextViewText(R.id.ticket_time, "$date • $time")
                ticketView.setTextViewText(R.id.ticket_seat, "Vieta $seat, ${hall}. zāle")

                val posterFile = File(context.filesDir, "ticket_$i.jpg")
                if (posterFile.exists()) {
                    val bitmap = BitmapFactory.decodeFile(posterFile.absolutePath)
                    ticketView.setImageViewBitmap(R.id.ticket_poster, bitmap)
                }

                views.addView(R.id.ticket_container, ticketView)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
