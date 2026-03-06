import SwiftUI

struct DedicationPopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 20) {
                // Bismillah
                Text("﷽")
                    .font(QiblatiTheme.arabicFont(size: 28))
                    .foregroundStyle(QiblatiTheme.goldGradient)

                // Gold divider
                Rectangle()
                    .fill(QiblatiTheme.gold.opacity(0.4))
                    .frame(height: 1)
                    .padding(.horizontal, 8)

                // Dedication text
                Text("أُعِدَّ هذا العمل ليكون صدقة جارية لروح جدتي «حسنية»، رحمها الله. وهو تطبيق مجاني بالكامل ولا يحتوي على أي إعلانات تجارية؛ فلا نبتغي منكم جزاءً ولا شكوراً، سوى دعوة صادقة لها بظهر الغيب.")
                    .font(QiblatiTheme.arabicBoldFont(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .environment(\.layoutDirection, .rightToLeft)

                // Gold divider
                Rectangle()
                    .fill(QiblatiTheme.gold.opacity(0.4))
                    .frame(height: 1)
                    .padding(.horizontal, 8)

                // Dismiss button
                Button(action: { withAnimation { isPresented = false } }) {
                    Text("اللهم اغفر لها وارحمها")
                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(QiblatiTheme.gold, lineWidth: 1.5)
                        )
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(QiblatiTheme.secondaryGreen)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.5), lineWidth: 1.5)
                    )
                    .shadow(color: QiblatiTheme.gold.opacity(0.2), radius: 20)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}
