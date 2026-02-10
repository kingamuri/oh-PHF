import SwiftUI

/// Applies a Liquid Glass background to a text input field.
/// Strips the system border via `.plain` style and applies a glass background.
///
/// Usage: `TextField("...", text: $binding).glassField()`
extension View {
    func glassField() -> some View {
        self
            .textFieldStyle(.plain)
            .padding(10)
            .glassBackground(.regular, in: RoundedRectangle(cornerRadius: 8))
    }
}
