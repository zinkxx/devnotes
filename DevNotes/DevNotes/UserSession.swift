import Foundation
import SwiftUI
import Combine

final class UserSession: ObservableObject {

    static let shared = UserSession()

    // Yayınlar
    @Published var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "isProUser")
            if isPro != oldValue {
                proStatusDidChangeSubject.send(isPro)
            }
        }
    }

    // PRO durum değişimlerini dinlemek isteyenler için subject
    let proStatusDidChangeSubject = PassthroughSubject<Bool, Never>()

    // Limit ayarı (konfigüre edilebilir ve kalıcı)
    @Published var freeNoteLimit: Int {
        didSet {
            UserDefaults.standard.set(freeNoteLimit, forKey: "freeNoteLimit")
        }
    }

    private init() {
        self.isPro = UserDefaults.standard.bool(forKey: "isProUser")
        let storedLimit = UserDefaults.standard.integer(forKey: "freeNoteLimit")
        self.freeNoteLimit = storedLimit > 0 ? storedLimit : 3
    }

    // Not oluşturma izni
    func canCreateNote(currentCount: Int) -> Bool {
        isPro || currentCount < freeNoteLimit
    }

    // UI katmanında kolay kullanım için yardımcı: izin yoksa paywall/prompt tetikleme
    func guardCanCreateNote(
        currentCount: Int,
        onAllowed: () -> Void,
        onBlocked: () -> Void
    ) {
        if canCreateNote(currentCount: currentCount) {
            onAllowed()
        } else {
            onBlocked()
        }
    }

    // Örnek: Paywall tetikleme yardımcıları
    func presentPaywall(haptics: Bool = true) {
        if haptics {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        NotificationCenter.default.post(name: .shouldPresentPaywall, object: nil)
    }

    // Limit güncelleme (ör. uzaktan konfigürasyondan)
    func updateFreeNoteLimit(to newValue: Int) {
        freeNoteLimit = max(1, newValue)
    }

    // Pro durumunu yükseltme / düşürme
    func setPro(_ value: Bool) {
        isPro = value
    }
}
extension Notification.Name {
    static let shouldPresentPaywall = Notification.Name("UserSession.shouldPresentPaywall")
}

