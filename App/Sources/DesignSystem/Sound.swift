import AVFoundation
import Foundation

// Optional sounds (round 4): a very soft page turn and a very soft card chime.
//
// Off by default; switched on in the "Aa" panel and remembered in `reader-memory.json`.
// Both sounds are our own, made by `tools/make_sounds.py` (plain arithmetic, no samples from
// anywhere else) and bundled as small WAV files in `App/Resources/Sounds`.
//
// The audio session category is `.ambient`: the sounds obey the silent switch, never stop a
// family's music or audiobook, and are never played in the background. Nothing is recorded
// and no microphone is used.

/// Plays the reader's two sounds. One instance for the app; main actor only.
@MainActor
final class ReaderSound {
    enum Effect: String, CaseIterable {
        /// A page turns.
        case page = "page-turn"
        /// A tap-to-see or character card opens.
        case card = "card-open"

        /// How loud, 0…1. Quiet on purpose.
        var volume: Float {
            switch self {
            case .page: return 0.45
            case .card: return 0.5
            }
        }
    }

    static let shared = ReaderSound()

    private var players: [Effect: AVAudioPlayer] = [:]
    private var missing: Set<Effect> = []
    private var sessionReady = false

    private init() {}

    /// The bundled file of an effect, if it is in the app.
    static func url(for effect: Effect, in bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: effect.rawValue, withExtension: "wav")
    }

    /// Plays `effect` when sounds are switched on. Does nothing — and touches no audio API —
    /// when they are off, so an app that never switches sounds on never opens an audio session.
    func play(_ effect: Effect, enabled: Bool) {
        guard enabled, let player = player(for: effect) else { return }
        prepareSession()
        player.currentTime = 0
        player.play()
    }

    private func prepareSession() {
        guard !sessionReady else { return }
        sessionReady = true
        // Ambient: respects the silent switch and mixes with whatever else is playing.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    }

    private func player(for effect: Effect) -> AVAudioPlayer? {
        if let ready = players[effect] {
            return ready
        }
        if missing.contains(effect) {
            return nil
        }
        guard let url = ReaderSound.url(for: effect), let made = try? AVAudioPlayer(contentsOf: url) else {
            missing.insert(effect)
            return nil
        }
        made.volume = effect.volume
        made.prepareToPlay()
        players[effect] = made
        return made
    }
}
