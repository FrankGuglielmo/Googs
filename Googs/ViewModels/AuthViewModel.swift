import Foundation
import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: User?
    @Published private(set) var displayName: String?
    @Published private(set) var email: String?
    @Published private(set) var photoURL: URL?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        
        // Observe authentication state on the main thread
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        authService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.displayName = user?.displayName
                self?.email = user?.email
                self?.photoURL = user?.photoURL
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

@MainActor
class EmailViewModel: ObservableObject {
    @Published var emails: [Email] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var hasMoreEmails = true
    
    private let backendAPI = BackendAPI.shared
    private var nextCursor: Int?
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>? = nil
    
    init() {
        isLoading = true
        // Listen for authentication changes
        backendAPI.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if !isAuthenticated {
                    // Only clear data when user logs out
                    self?.emails = []
                    self?.nextCursor = nil
                    self?.errorMessage = nil
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    func loadEmails() async {
        // Cancel any existing load task
        loadTask?.cancel()
        await MainActor.run { self.isLoading = true }
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            guard self.backendAPI.isAuthenticated else {
                self.errorMessage = "Not authenticated"
                await MainActor.run { self.isLoading = false }
                return
            }
            await MainActor.run { self.errorMessage = nil }
            do {
                let result = try await self.backendAPI.fetchEmailsWithCursor(cursor: nil, limit: 20)
                await MainActor.run {
                    self.emails = result.emails.map { self.convertToEmail($0) }
                    self.nextCursor = result.nextCursor
                    self.hasMoreEmails = self.nextCursor != nil
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
        await loadTask?.value
    }
    
    func loadMoreEmails() async {
        guard hasMoreEmails, let cursor = nextCursor, !isLoading else { return }
        
        isLoading = true
        
        do {
            let result = try await backendAPI.fetchEmailsWithCursor(cursor: cursor, limit: 20)
            let newEmails = result.emails.map { convertToEmail($0) }
            emails.append(contentsOf: newEmails)
            nextCursor = result.nextCursor
            hasMoreEmails = nextCursor != nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func markAsRead(emailId: Int, isRead: Bool) async {
        do {
            let updatedEmail = try await backendAPI.markEmailAsRead(emailId: emailId, isRead: isRead)
            if let index = emails.firstIndex(where: { $0.backendId == updatedEmail.id }) {
                emails[index].isRead = isRead
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func convertToEmail(_ emailResponse: EmailResponse) -> Email {
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.date(from: emailResponse.date ?? "") ?? Date()
        
        return Email(
            id: UUID(),
            backendId: emailResponse.id,
            sender: emailResponse.sender ?? "Unknown",
            subject: emailResponse.subject ?? "No Subject",
            preview: emailResponse.snippet ?? "",
            content: emailResponse.snippet ?? "",
            timestamp: timestamp,
            isStarred: emailResponse.labels?.contains("STARRED") ?? false,
            priority: determinePriority(from: emailResponse),
            category: determineCategory(from: emailResponse),
            hasAttachments: emailResponse.hasAttachments ?? false,
            attachmentCount: 0, // TODO: Extract from metadata
            isRead: emailResponse.isRead
        )
    }
    
    private func determinePriority(from emailResponse: EmailResponse) -> Email.Priority {
        if emailResponse.labels?.contains("IMPORTANT") ?? false {
            return .high
        } else if emailResponse.labels?.contains("PROMOTIONS") ?? false {
            return .promotional
        } else {
            return .normal
        }
    }
    
    private func determineCategory(from emailResponse: EmailResponse) -> Email.Category {
        // Simple heuristic - could be improved with ML
        let sender = emailResponse.sender?.lowercased() ?? ""
        let subject = emailResponse.subject?.lowercased() ?? ""
        
        let workKeywords = ["work", "office", "company", "business", "project", "meeting", "report"]
        let hasWorkKeywords = workKeywords.contains { keyword in
            sender.contains(keyword) || subject.contains(keyword)
        }
        
        return hasWorkKeywords ? .work : .personal
    }
} 
