import SwiftUI

struct SitePickerView: View {
    @Environment(WordPressAuthManager.self) private var auth
    @State private var loadError: String?
    @State private var pendingPrivateSite: WordPressSite?

    var body: some View {
        NavigationStack {
            Group {
                if auth.isFetchingSites {
                    ProgressView("Loading your sites…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = loadError {
                    ContentUnavailableView {
                        Label("Couldn't Load Sites", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") { Task { await loadSites() } }
                    }
                } else if auth.sites.isEmpty {
                    ContentUnavailableView(
                        "No Sites Found",
                        systemImage: "globe.slash",
                        description: Text("No WordPress.com sites were found for your account.")
                    )
                } else {
                    List(auth.sites) { site in
                        Button {
                            if site.isPrivate {
                                pendingPrivateSite = site
                            } else {
                                auth.selectSite(site)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                SiteFavicon(urlString: site.iconURL)
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(site.name)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color(.label))
                                        if site.isPrivate {
                                            Image(systemName: "lock.fill")
                                                .font(.caption)
                                                .foregroundStyle(Color(.secondaryLabel))
                                        }
                                    }
                                    Text(site.url)
                                        .font(.footnote)
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .foregroundStyle(Color(.label))
                    }
                }
            }
            .navigationTitle("Choose a Site")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        auth.logout()
                    }
                }
            }
        }
        .task { await loadSites() }
        .alert("Private Site", isPresented: Binding(
            get: { pendingPrivateSite != nil },
            set: { if !$0 { pendingPrivateSite = nil } }
        )) {
            Button("Select Anyway") {
                if let site = pendingPrivateSite { auth.selectSite(site) }
                pendingPrivateSite = nil
            }
            Button("Cancel", role: .cancel) { pendingPrivateSite = nil }
        } message: {
            Text("WordPress.com disables API access for private sites. You won't be able to view or post content until you switch the site visibility to Coming Soon in WordPress.com Settings.")
        }
    }

    private func loadSites() async {
        loadError = nil
        do {
            try await auth.fetchSites()
        } catch {
            loadError = error.localizedDescription
        }
    }
}

// MARK: - Favicon

private struct SiteFavicon: View {
    let urlString: String?

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholderIcon
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholderIcon: some View {
        Image(systemName: "globe")
            .font(.system(size: 18))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
    }
}
