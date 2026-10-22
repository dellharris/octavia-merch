import Cocoa
import WebKit
let a = CommandLine.arguments
let url = URL(string: a[1])!, prefix = a[2], w = Int(a[3])!, h = Int(a[4])!, count = Int(a[5])!
let root = a[6]
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: h), configuration: WKWebViewConfiguration())
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h), styleMask: [.borderless], backing: .buffered, defer: false)
win.contentView = web
var idx = 1
func snap() {
  if idx > count { print("done"); exit(0) }
  web.evaluateJavaScript("location.hash='#\(idx)'") { _, _ in
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      let c = WKSnapshotConfiguration(); c.rect = NSRect(x: 0, y: 0, width: w, height: h)
      web.takeSnapshot(with: c) { img, _ in
        if let img = img, let t = img.tiffRepresentation, let rep = NSBitmapImageRep(data: t), let png = rep.representation(using: .png, properties: [:]) {
          try? png.write(to: URL(fileURLWithPath: "\(prefix)\(idx).png"))
        }
        idx += 1; snap()
      }
    }
  }
}
class D: NSObject, WKNavigationDelegate {
  func webView(_ wv: WKWebView, didFinish n: WKNavigation!) { DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { snap() } }
}
let d = D(); web.navigationDelegate = d
web.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: root))
app.run()
