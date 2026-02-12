//
//  SettingsViewModel.swift
//  Travel
//
//  Created by Данила Спиридонов on 12.02.2026.
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
}
