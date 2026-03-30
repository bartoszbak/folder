import SwiftUI

// MARK: - App Icon Model

struct AppIconOption: Identifiable {
    let id: String         // nil-able icon name passed to setAlternateIconName
    let displayName: String
    let assetName: String  // UIImage(named:) key — same as the appiconset name

    /// The icon name passed to UIApplication.setAlternateIconName(_:).
    /// nil means "restore default icon".
    var iconName: String? { id == "default" ? nil : id }
}

// MARK: - Available Icon Options

extension AppIconOption {
    static let all: [AppIconOption] = [
        AppIconOption(id: "default",         displayName: "Default",  assetName: "AppIcon"),
        AppIconOption(id: "AppIcon-Classic",  displayName: "Classic",  assetName: "AppIcon-Classic"),
        AppIconOption(id: "AppIcon-Minimal",  displayName: "Minimal",  assetName: "AppIcon-Minimal"),
        AppIconOption(id: "AppIcon-Gradient", displayName: "Gradient", assetName: "AppIcon-Gradient"),
    ]
}

// MARK: - AppIconPickerView

struct AppIconPickerView: View {
    /// Persisted selection across launches.
    @AppStorage("selectedAppIconID") private var selectedIconID: String = "default"

    @State private var isChanging = false
    @State private var changeError: String?

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(AppIconOption.all) { option in
                    IconCell(
                        option: option,
                        isSelected: selectedIconID == option.id,
                        isChanging: isChanging
                    ) {
                        guard selectedIconID != option.id else { return }
                        applyIcon(option)
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't Change Icon", isPresented: Binding(
            get: { changeError != nil },
            set: { if !$0 { changeError = nil } }
        )) {
            Button("OK", role: .cancel) { changeError = nil }
        } message: {
            if let msg = changeError { Text(msg) }
        }
    }

    // MARK: - Actions

    private func applyIcon(_ option: AppIconOption) {
        guard UIApplication.shared.supportsAlternateIcons else {
            changeError = "Alternate icons are not supported on this device."
            return
        }
        isChanging = true
        UIApplication.shared.setAlternateIconName(option.iconName) { error in
            DispatchQueue.main.async {
                isChanging = false
                if let error {
                    changeError = error.localizedDescription
                } else {
                    selectedIconID = option.id
                }
            }
        }
    }
}

// MARK: - IconCell

private struct IconCell: View {
    let option: AppIconOption
    let isSelected: Bool
    let isChanging: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    iconPreview
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white, .blue)
                            .background(Circle().fill(Color(.systemBackground)).padding(2))
                            .offset(x: 4, y: 4)
                    }
                }
                Text(option.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .disabled(isChanging)
        .opacity(isChanging && !isSelected ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    @ViewBuilder
    private var iconPreview: some View {
        if let uiImage = UIImage(named: option.assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.blue : Color.primary.opacity(0.12),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                )
        } else {
            // Fallback when the PNG hasn't been dropped in yet
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color.blue : Color.primary.opacity(0.12),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AppIconPickerView()
    }
}
