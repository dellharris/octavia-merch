import Cocoa
import WebKit
let args = CommandLine.arguments
let url = URL(string: args[1])!
let out = args[2]
let w = Int(args[3])!, h = Int(args[4])!
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let cfg = WKWebViewConfiguration()
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: h), configuration: cfg)
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h), styleMask: [.borderless], backing: .buffered, defer: false)
win.contentView = web
class D: NSObject, WKNavigationDelegate {
  func webView(_ wv: WKWebView, didFinish n: WKNavigation!) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
      let c = WKSnapshotConfiguration(); c.rect = NSRect(x: 0, y: 0, width: w, height: h)
      wv.takeSnapshot(with: c) { img, err in
        guard let img = img, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) else { print("snapshot failed \(String(describing: err))"); exit(1) }
        try! png.write(to: URL(fileURLWithPath: out)); print("ok"); exit(0)
      }
    }
  }
  func webView(_ wv: WKWebView, didFail n: WKNavigation!, withError e: Error) { print("fail \(e)"); exit(2) }
}
let d = D(); web.navigationDelegate = d
web.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: "/Users/dellgod/octavia-merch/"))
app.run()
