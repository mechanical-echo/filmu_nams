//
//  FilmuNamsWidgetBundle.swift
//  FilmuNamsWidget
//
//  Created by Sofia Dyshlovaya on 07/05/2025.
//

import WidgetKit
import SwiftUI

@main
struct FilmuNamsWidgetBundle: WidgetBundle {
    var body: some Widget {
        FilmuNamsWidget()
        FilmuNamsWidgetControl()
        FilmuNamsWidgetLiveActivity()
    }
}
