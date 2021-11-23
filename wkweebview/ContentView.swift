//
//  ContentView.swift
//  wkweebview
//
//  Created by Mike on 2021/10/18.
//

import SwiftUI
import WebKit


struct ContentView: View {
    let url :String
    
    // MARK: showAlert가 true면 알림창이 뜬다
    @State var showAlert: Bool = false
    
    // MARK: alert에 표시할 내용
    @State var alertMessage: String = "error"
    
    // MARK: 웹뷰 확인/취소 작업을 처리하기 위한 핸드러를 받아오는 변수
    @State var confirmHandler: (Bool) -> Void = {_ in }
    var body: some View {
        WebView(webView: WKWebView(), request: URLRequest(url: URL(string: url)!), showAlert: self.$showAlert, alertMessage: self.$alertMessage, confirmHandler: self.$confirmHandler)
            .alert(isPresented: self.$showAlert) { () -> Alert in
                var alert = Alert(title: Text(alertMessage))
                if(self.showAlert == true) {
                    alert = Alert(title: Text("알림"), message: Text(alertMessage), primaryButton: .default(Text("OK"), action: {
                        confirmHandler(true)
                    }), secondaryButton: .cancel({
                        confirmHandler(false)
                    }))
                }
                return alert;
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(url:"")
    }
}

// WebView의 세부 내용을 설정한다
struct WebView: UIViewRepresentable {
    let webView: WKWebView
    let request: URLRequest
    
    //MARK:  아래의 3가지 변수는 위에서 선언한 변수 3가지와 동일
    
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var confirmHandler: (Bool) -> Void
    
    // MARK: Coodinator를 이용하여 alert, confirm, 그 외에 링크 이벤트를 처리한다
    
    class Coodinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        
        var parent: WebView
        var webViewPop : WKWebView?
        //        public func WebView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        //                print("window.open 호출")
        //                let frame = UIScreen.main.bounds
        //                //파라미터로 받은 configuration
        //                webViewPop = WKWebView(frame: frame, configuration: configuration)
        //
        //                //오토레이아웃 처리
        //                webViewPop?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //
        //                webViewPop?.navigationDelegate = self
        //                webViewPop?.uiDelegate = self
        //
        //                webView.addSubview(webViewPop!)
        //
        //                return webViewPop!
        //            }
        //
        //            // Javascript close() 코드 호출이 되면 아래 코드가 실행 됨
        //            public func webViewDidClose(_ webView: WKWebView) {
        //                print("window.close 호출")
        //                webViewPop?.removeFromSuperview()
        //                webViewPop = nil
        //
        //                webView.removeFromSuperview()
        //            }
        // MARK: 역시 맨 위에서 선언한 3가지 변수이다. 이 작업은 맨 처음 선언한 변수들은 해당 클레스에서 사용할수 있도록 연결시켜주는 작업이다
        var showAlert: Binding<Bool>
        var alertMessage: Binding<String>
        var confirmHandler: Binding<(Bool) -> Void>
        
        init(_ parent: WebView, showAlert: Binding<Bool>, alertMessage: Binding<String>, confirmHandler: Binding<(Bool) -> Void>) {
            self.parent = parent
            self.showAlert = showAlert
            self.alertMessage = alertMessage
            self.confirmHandler = confirmHandler
        }
        
        // MARK: 웹 사이트에서 alert이나 confirm이 발생하면 해당 함수가 실행되어 세부 내용을 맨 처음 선언한 alertMessage와 showAlert, confirmHandler에 할당한다. confirmHandler는 사용자가 confirm창에서 "예/아니오"를 선택했을 경우에 대해 처리하는 핸들러이다.
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            completionHandler()
            
        }
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? { if navigationAction.targetFrame == nil { webView.load(navigationAction.request) };
            return nil
            
        }
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            
            self.confirmHandler.wrappedValue = completionHandler
        }
        // MARK: url scheme 체크
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               url.scheme != "http" && url.scheme != "https" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
        func openURLToAppStore(urlPath : String){
            if let url = URL(string: urlPath),
               UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coodinator {
        return Coodinator(self, showAlert: self.$showAlert, alertMessage: self.$alertMessage, confirmHandler: self.$confirmHandler)
    }
    
    //MARK:  뷰를 생성할때 위에서 선언한 클래스를 할당한다.
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        
        // 뒤로가기 제스쳐 사용 여부
        webView.allowsBackForwardNavigationGestures = true
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.load(request)
        reload()
        return webView
    }
    
    // MARK: 만일, 해당 앱이 다른 앱이나 사파리, 크롬 등의 앱을 왔다 갔다 해야 한다면, 해당 부분을 주석처리 하지 않으면 앱이 켜질때마다 웹 뷰가 새로고침된다.
    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        //        webView.uiDelegate = context.coordinator
        //        webView.allowsBackForwardNavigationGestures = true
        //        webView.load(request)
    }
    
    // MARK: 리다이렉트, 리로드, 뒤로가기, 앞으로가기를 사용하기 위한 함수
    func redirect(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
    }
    
    func reload() {
        webView.reload()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward(){
        webView.goForward()
    }
}
