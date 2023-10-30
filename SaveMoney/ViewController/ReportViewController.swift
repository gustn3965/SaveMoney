//
//  ReportViewController.swift
//  SaveMoney
//
//  Created by vapor on 2023/06/20.
//

import UIKit

var openAIKey: String = "secret key"

@MainActor class Wallet {
    var amount: Int
    init(amount: Int) {
        self.amount = amount
    }
    
    func spendMoney(_ money: Int) {
        self.amount -= money
    }
}

class ReportViewController: UIViewController {
    var ntMonth: NTMonth?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var gptTextView: UITextView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tempValueLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var session: SSEClient?
    
    var wallet: Wallet = Wallet(amount: 10000)
    
    var answer: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        
        guard let path = Bundle.main.path(forResource: "SecretKey", ofType: "json"),
              let jsonString = try? String(contentsOfFile: path),
              let jsonData = jsonString.data(using: .utf8),
              let secretKey = try? JSONDecoder().decode(SecretKey.self, from: jsonData)
              else {
            return
        }
        
        openAIKey = secretKey.openAIKey
        
        textView.text =  ntMonth?.report
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.view.endEditing(true)
    }
    
    @IBAction func clickAI(_ sender: Any) {
        let val = round(stepper.value * 10) / 10
//        answer = ""
//
//        session = SSEClient(content: ntMonth?.report ?? "", temp: val)
//        session?.delegate = self
//        session?.start()
        
        self.sendChatCompletionRequest()
        
        
        self.wallet.spendMoney(1000)
        

    }
    
    @IBAction func clickRefresh(_ sender: Any) {
        session?.contents.append(["role": "assistant", "content":answer])
        session?.contents.append(["role": "user", "content":"다른 의견으로 더 말해줘."])
        
        session?.start()
    }
    @IBAction func clickStepper(_ sender: Any) {
        let val = round(stepper.value * 10) / 10
        self.tempValueLabel.text = "\(val)"
    }
    
    
    func sendChatCompletionRequest() {
        // 1. URL 생성
        if let url = URL(string: "https://api.openai.com/v1/chat/completions") {
            // 2. URLRequest 생성
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // 3. HTTP 헤더 설정
            request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("text/plain", forHTTPHeaderField: "Accept")
            
            // 4. 요청 데이터 생성
            let requestData: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "user", "content": "오늘 날씨 알려줘"]
                ],
                "temperature": 0.7,
                "stream": false
            ]
            
            // 5. 요청 데이터를 JSON 형식으로 변환
            if let postData = try? JSONSerialization.data(withJSONObject: requestData) {
                // 6. 요청 데이터를 요청의 본문에 할당
                request.httpBody = postData
                
                // 7. URLSession 생성
                let session = URLSession.shared
                
                // 8. URLSessionDataTask 생성
                Task {
//                    let (data, response) = try await session.data(for: request)
                    let image = try await self.requestImage()
                    self.imageView.image = image
                }
                Task.init {
                    let image = try await self.requestImage()
                }
                
                Task.detached {
                    let image = try await self.requestImage()
                }
//
//                DispatchQueue.global().async {
//                    do {
//
//
//                        let image = try self.syncImage()
//                        DispatchQueue.main.async {
//                            self.imageView.image = image
//                        }
//
//
//                    } catch {
//                    }
//                }
                
                print("--------")
                return
                
                let task = session.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    // 9. 응답 처리
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            // HTTP 요청이 성공한 경우
                            if let responseData = data {
                                // responseData를 사용하여 응답 데이터 처리
                                if let responseString = String(data: responseData, encoding: .utf8) {
                                    print("Response: \(responseString)")
                                }
                            }
                        } else {
                            // HTTP 요청이 실패한 경우
                            print("Error: \(httpResponse.statusCode)")
                        }
                    }
                }
                
                // 10. 요청 시작
                task.resume()
            }
        }
    }
    
    func requestImage() async throws -> UIImage {
        do {
            let data = try Data(contentsOf: URL(string: "https://blog.kakaocdn.net/dn/69TT8/btqGbNFJF5p/zTavch0F8BlAqGaDKVMU41/img.jpg")!)
            await MainActor.run(body: {
                
            })
            print(data.count)
            return UIImage(data: data)!
                                
        } catch let error {
            throw error
        }
    }
    
    func syncImage() throws -> UIImage {
        do {
            let data = try Data(contentsOf: URL(string: "https://blog.kakaocdn.net/dn/69TT8/btqGbNFJF5p/zTavch0F8BlAqGaDKVMU41/img.jpg")!)
            print(data.count)
            return UIImage(data: data)!
                                
        } catch let error {
            throw error
        }
    
    }
    
//    func backgroundThreadImage() throws -> UIImage {
//        DispatchQueue.global().async {
//            do {
//                let data = try Data(contentsOf: URL(string: "https://blog.kakaocdn.net/dn/69TT8/btqGbNFJF5p/zTavch0F8BlAqGaDKVMU41/img.jpg")!)
//                print(data.count)
//                return UIImage(data: data)!
//
//            } catch let error {
//                throw error
//            }
//        }
//
//
//    }
}

extension ReportViewController: SSEClientDelegate {
    func sseclientDidReceiveString(string: String?) {
        if let string = string {
            gptTextView.text += string
            answer += string
        } else {
            gptTextView.text += "\n 끝."
        }
    }
    
    func sseclientDidReceiveEnd() {
        gptTextView.text += " 끝.\n\n\n\n\n"
    }
}


protocol SSEClientDelegate: NSObject {
    func sseclientDidReceiveString(string: String?)
    func sseclientDidReceiveEnd()
}

class SSEClient: NSObject, URLSessionDataDelegate {
    var url: URL = URL(string: "https://api.openai.com/v1/chat/completions")!
    var session: URLSession?
    var task: URLSessionDataTask?
    
    var delegate:SSEClientDelegate?
    
    var contents: [[String: String]]
    var temp: Double
    
    init(content: String, temp: Double) {
        self.contents = [["role": "user", "content":content]]
        self.temp = temp
    }
    
    deinit {
        print("SSEClient deinit...")
    }
    
    func start() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 60 // 선택 사항, 요청 타임아웃 설정
        
        session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 3. HTTP 헤더 설정 (선택 사항)
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 4. 요청 데이터 생성
        var messages: [Any] = []
        contents.forEach{ messages.append($0)}
                
        let jsonData: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": self.temp,
            "stream": true,
            "n": 1
        ]
        let postData = try! JSONSerialization.data(withJSONObject: jsonData)
        request.httpBody = postData
        
        task = session?.dataTask(with: request)
        task?.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // SSE 이벤트 수신

        print("🎉Event!")
        if let dataString = String(data: data, encoding: .utf8) {
            let components = dataString.components(separatedBy: "\n\n")
            
            for component in components {
                if let index = component.firstIndex(of: ":") {
                    let afterIndex = component.index(after: index)
                    let subString = component.suffix(from: afterIndex)
                    if let jsonData = subString.data(using: .utf8) {
                        DispatchQueue.main.async {
                            if let jsonObject = try? JSONDecoder().decode(Response.self, from: jsonData)
                            {
                                let value = jsonObject.choices.first?.delta.content
                                self.delegate?.sseclientDidReceiveString(string: value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // SSE 연결 종료
        if let error = error {
            print("SSE connection error: \(error.localizedDescription)")
        } else {
            print("SSE connection completed.")
        }
        
        DispatchQueue.main.async {
            self.delegate?.sseclientDidReceiveEnd()
        }
        
        
        // 재연결 논리를 추가하려면 여기에 적절한 로직을 구현할 수 있습니다.
    }
}

// JSON 데이터를 매칭할 Codable 구조체 정의
struct Response: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let index: Int
        let delta: Delta
        let finish_reason: String?
        
        struct Delta: Codable {
            let content: String
            let role: String?
        }
    }
}
