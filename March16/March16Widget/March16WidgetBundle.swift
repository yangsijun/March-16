//
//  March16WidgetBundle.swift
//  March16Widget
//
//  Created by 양시준 on 12/7/25.
//

import WidgetKit
import SwiftUI

@main
struct March16WidgetBundle: WidgetBundle {
    var body: some Widget {
        March16Widget()
        if #available(iOS 18.0, *) {
            March16Control()
        }
    }
}
