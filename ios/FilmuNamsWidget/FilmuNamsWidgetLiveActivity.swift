//
//  FilmuNamsWidgetLiveActivity.swift
//  FilmuNamsWidget
//
//  Created by Sofia Dyshlovaya on 07/05/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FilmuNamsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FilmuNamsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FilmuNamsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FilmuNamsWidgetAttributes {
    fileprivate static var preview: FilmuNamsWidgetAttributes {
        FilmuNamsWidgetAttributes(name: "World")
    }
}

extension FilmuNamsWidgetAttributes.ContentState {
    fileprivate static var smiley: FilmuNamsWidgetAttributes.ContentState {
        FilmuNamsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FilmuNamsWidgetAttributes.ContentState {
         FilmuNamsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FilmuNamsWidgetAttributes.preview) {
   FilmuNamsWidgetLiveActivity()
} contentStates: {
    FilmuNamsWidgetAttributes.ContentState.smiley
    FilmuNamsWidgetAttributes.ContentState.starEyes
}
