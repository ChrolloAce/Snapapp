import SwiftUI
import WebKit

struct GIFImage: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.load(name)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(name)
    }
}

private extension WKWebView {
    func load(_ gifName: String) {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif") else { return }
        let data = try? Data(contentsOf: url)
        let base64String = data?.base64EncodedString(options: .lineLength64Characters)
        
        let html = """
        <html>
        <body style="margin: 0; background-color: transparent;">
            <img src="data:image/gif;base64,\(base64String ?? "")"
                style="width: 100%; height: 100%; object-fit: contain;">
        </body>
        </html>
        """
        
        loadHTMLString(html, baseURL: nil)
    }
} 