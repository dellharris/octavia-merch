import Cocoa
import WebKit
let a = CommandLine.arguments
let url = URL(string: a[1])!, mode = a[2], out = a[3]
let w = 612, h = 792
let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let web = WKWebView(frame: NSRect(x: 0, y: 0, width: w, height: h), configuration: WKWebViewConfiguration())
let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: w, height: h), styleMask: [.borderless], backing: .buffered, defer: false)
win.contentView = web
class D: NSObject, WKNavigationDelegate {
  func webView(_ wv: WKWebView, didFinish n: WKNavigation!) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      if mode == "pdf" {
        let c = WKPDFConfiguration(); c.rect = NSRect(x: 0, y: 0, width: w, height: h)
        wv.createPDF(configuration: c) { r in
          switch r { case .success(let d): try! d.write(to: URL(fileURLWithPath: out)); print("ok"); exit(0)
                     case .failure(let e): print("fail \(e)"); exit(1) } }
      } else {
        let c = WKSnapshotConfiguration(); c.rect = NSRect(x: 0, y: 0, width: w, height: h); c.snapshotWidth = 1632
        wv.takeSnapshot(with: c) { img, err in
          guard let img = img, let t = img.tiffRepresentation, let rep = NSBitmapImageRep(data: t), let png = rep.representation(using: .png, properties: [:]) else { print("fail"); exit(1) }
          try! png.write(to: URL(fileURLWithPath: out)); print("ok"); exit(0) }
      }
    }
  }
}
let d = D(); web.navigationDelegate = d
web.loadFileURL(url, allowingReadAccessTo: URL(fileURLWithPath: "/Users/dellgod/idu-house/clients/octavia-the-great/merch/"))
app.run()
