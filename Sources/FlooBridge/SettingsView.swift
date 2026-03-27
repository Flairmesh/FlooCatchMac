import SwiftUI

struct SettingsView: View {
    @ObservedObject var serial: SerialManager

    var body: some View {
        Form {
            Section(L10n.t("serial")) {
                Stepper(value: $serial.baudRate, in: 9_600...921_600, step: 9_600) {
                    Text(L10n.f("baud_rate_format", serial.baudRate))
                }
                Toggle(L10n.t("append_carriage_return"), isOn: $serial.appendCarriageReturn)
                Toggle(L10n.t("append_newline"), isOn: $serial.appendNewline)
            }

            Section(L10n.t("next")) {
                Text(L10n.t("next_description"))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
