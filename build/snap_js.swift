import Cocoa
import WebKit
let a = CommandLine.arguments
let url = URL(string: a[1])!, out = a[2], w = Int(a[3])!, h = Int(a[4])!, js = a[5], root = a[6]
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: h), configuration: WKWebViewConfiguration())
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h), styleMask: [.borderless], backing: .buffered, defer: false)
win.contentView = web
class D: NSObject, WKNavigationDelegate {
  func webView(_ wv: WKWebView, didFinish n: WKNavigation!) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      wv.evaluateJavaScript(js) { _, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
          let c = WKSnapshotConfiguration(); c.rect = NSRect(x: 0, y: 0, width: w, height: h)
          wv.takeSnapshot(with: c) { img, _ in
            if let img = img, let t = img.tiffRepresentation, let rep = NSBitmapImageRep(data: t), let png = rep.representation(using: .png, properties: [:]) { try? png.write(to: URL(fileURLWithPath: out)) }
            print("ok"); exit(0)
          }
        }
      }
    }
  }
}
let d = D(); web.navigationDelegate = d
web.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: root))
app.run()
