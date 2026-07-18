import SwiftUI

struct DedicationPopup: View {
    @Binding var isPresented: Bool

    @State private var appeared = false
    @State private var heartBeat = false

    var body: some View {
        ZStack {
            // ── Backdrop: deep dim + soft emerald haze ──────────────────────
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .background(.ultraThinMaterial.opacity(0.4))
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // ── Card ────────────────────────────────────────────────────────
            VStack(spacing: 0) {
                // Bismillah with travelling shimmer
                Text("﷽")
                    .font(QiblatiTheme.arabicFont(size: 30))
                    .foregroundStyle(QiblatiTheme.goldGradient)
                    .goldShimmer()
                    .padding(.top, 26)
                    .padding(.bottom, 10)

                OrnamentalDivider(width: 180, starSize: 8)

                // Dedication body
                Text("أُعِدَّ هذا العمل ليكون صدقة جارية لروح")
                    .font(QiblatiTheme.arabicBoldFont(size: 17))
                    .foregroundColor(QiblatiTheme.ivory)
                    .multilineTextAlignment(.center)
                    .lineSpacing(9)
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.top, 16)

                // The honored names
                HStack(spacing: 12) {
                    nameChip("جدتي", "حسنية")
                    heartIcon
                    nameChip("جدي", "محسن فوزي")
                }
                .padding(.top, 14)

                Text("رحمهما الله. وهو تطبيق مجاني بالكامل ولا يحتوي على أي إعلانات تجارية؛ فلا نبتغي منكم جزاءً ولا شكوراً، سوى دعوة صادقة لهما بظهر الغيب.")
                    .font(QiblatiTheme.arabicBoldFont(size: 16))
                    .foregroundColor(QiblatiTheme.ivory.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineSpacing(9)
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.top, 14)

                OrnamentalDivider(width: 180, starSize: 8)
                    .padding(.top, 16)

                // Dismiss dua button
                Button(action: dismiss) {
                    Text("اللهم اغفر لهما وارحمهما")
                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(QiblatiTheme.gold.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(QiblatiTheme.gold.opacity(0.7), lineWidth: 1.2)
                                )
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 22)
            .background(cardFrame)
            .overlay(cornerOrnaments)
            .padding(.horizontal, 30)
            .scaleEffect(appeared ? 1 : 0.86)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.4)) {
                heartBeat = true
            }
        }
        .transition(.opacity)
    }

    // MARK: - Pieces

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.22)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }

    private func nameChip(_ relation: String, _ name: String) -> some View {
        VStack(spacing: 3) {
            Text(relation)
                .font(QiblatiTheme.arabicFont(size: 12))
                .foregroundColor(QiblatiTheme.gold.opacity(0.65))
            Text("«\(name)»")
                .font(QiblatiTheme.arabicBoldFont(size: 21))
                .foregroundStyle(QiblatiTheme.goldGradient)
                .shadow(color: QiblatiTheme.gold.opacity(0.35), radius: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(QiblatiTheme.abyssGreen.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(QiblatiTheme.gold.opacity(0.35), lineWidth: 0.8)
                )
        )
    }

    private var heartIcon: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 15))
            .foregroundStyle(QiblatiTheme.goldGradient)
            .scaleEffect(heartBeat ? 1.22 : 1.0)
            .shadow(color: QiblatiTheme.gold.opacity(0.5), radius: 8)
    }

    private var cardFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            QiblatiTheme.surfaceLight.opacity(0.6),
                            QiblatiTheme.secondaryGreen,
                            QiblatiTheme.abyssGreen,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 16)
                .shadow(color: QiblatiTheme.gold.opacity(0.18), radius: 24)

            // Double gold frame
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(QiblatiTheme.gold.opacity(0.55), lineWidth: 1.4)
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .strokeBorder(QiblatiTheme.gold.opacity(0.25), lineWidth: 0.7)
                .padding(4)
        }
    }

    /// Four eight-pointed stars pinned to the card corners.
    private var cornerOrnaments: some View {
        ZStack {
            cornerStar(at: .topLeading)
            cornerStar(at: .topTrailing)
            cornerStar(at: .bottomLeading)
            cornerStar(at: .bottomTrailing)
        }
        .accessibilityHidden(true)
    }

    private func cornerStar(at alignment: Alignment) -> some View {
        EightPointedStar()
            .fill(QiblatiTheme.goldVerticalGradient)
            .frame(width: 15, height: 15)
            .shadow(color: QiblatiTheme.gold.opacity(0.6), radius: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .padding(.horizontal, -7)
            .padding(.vertical, -7)
    }
}

#Preview {
    DedicationPopup(isPresented: .constant(true))
}
