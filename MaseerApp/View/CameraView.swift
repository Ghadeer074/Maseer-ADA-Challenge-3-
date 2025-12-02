import SwiftUI

struct SurroundingsMainScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {

            // BACKGROUND IMAGE
            Image("Image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // CLOSE BUTTON
            VStack {
                HStack {
                    Spacer()

                    Text("إغلاق")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(
                            BlurView(style: .systemThinMaterialDark)
                                .opacity(0.85)
                        )
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                }
                .padding(.top, 45)
                .padding(.trailing, 25)

                Spacer()
            }

            // BOTTOM GLASS SHEET
            VStack {
                Spacer()

                ZStack {
                    // REAL BLUR
                    BlurView(style: .systemUltraThinMaterialDark)
                        .opacity(0.90)

                    // EXTRA DARK MILK GLASS TINT
                    Color.black.opacity(0.25)

                }
                .frame(maxWidth: .infinity)
                .frame(height: 360)                // ← HEIGHT WORKS NOW
                .clipShape(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                )
                .overlay(
                    // All text inside overlay (this fixes clipping issues)
                    VStack(alignment: .trailing, spacing: 14) {

                        Text("جاري إنتاج معلومات محيطك..")
                            .foregroundColor(.white)
                            .font(.headline)

                        Text("""
أمامك على بُعد خطوتين شجرة خضراء متوسطة الطول، وعلى \
بعد ثمانية خطوات هناك مجموعة كراسي بيضاء، مُقسّمة حول \
طاولتين رخامية بيضاء أيضًا. \
الطريق الرئيسي على بُعد خمسة عشر خطوة منك.
""")
                            .foregroundColor(.white)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(25)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}


struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    SurroundingsMainScreen()
}
