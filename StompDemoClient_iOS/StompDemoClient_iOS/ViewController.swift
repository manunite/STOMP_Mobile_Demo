//
//  ViewController.swift
//  Test_STOMP
//
//  Created by heogj123 on 2020/12/11.
//

import UIKit
import StompClientLib
import SnapKit

class ViewController: UIViewController {
    
    struct StompSendDTO {
        var name : String? = ""
        var message : String? = ""
        var dictionary: [String: Any] {
            return ["name": name, "message": message]
        }
        var nsDictionary: NSDictionary {
            return dictionary as NSDictionary
        }
    }
    
    private let AppTitle: UILabel = {
        let label = UILabel()
        label.text = "STOMP Tester"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private let textField_websocketAddress: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let textField_subscribe: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let textField_sendMessage: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let uilabel_websocketAddress: UILabel = {
        let label = UILabel()
        label.text = "Websocket Address"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let uilabel_subscribe: UILabel = {
        let label = UILabel()
        label.text = "Subscribe Topic"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let uiButton_Connect: UIButton = {
        let button = UIButton()
        button.setTitle("Connect", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let uiButton_Disconnect: UIButton = {
        let button = UIButton()
        button.setTitle("Disconnect", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let uiButton_SendMessage: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let socketClient = StompClientLib()
    
    private let tableView = UITableView()
    private var dataArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(AppTitle)
        self.view.addSubview(uilabel_websocketAddress)
        self.view.addSubview(textField_websocketAddress)
        self.view.addSubview(uilabel_subscribe)
        self.view.addSubview(textField_subscribe)
        
        self.view.addSubview(uiButton_Connect)
        self.view.addSubview(uiButton_Disconnect)
        
        self.view.addSubview(textField_sendMessage)
        self.view.addSubview(uiButton_SendMessage)
        
        self.view.addSubview(tableView)
        tableView.allowsSelection = false
        
        uiButton_Connect.addTarget(self, action: #selector(doConnect(_:)), for: .touchUpInside)
        uiButton_Disconnect.addTarget(self, action: #selector(doDisconnect(_:)), for: .touchUpInside)
        uiButton_SendMessage.addTarget(self, action: #selector(sendMessage(_:)), for: .touchUpInside)
        
        textField_websocketAddress.text = "ws://localhost:80/testserver/websocket"
        textField_subscribe.text = "/topic/chat"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        setConstraints()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setConstraints() {
        AppTitle.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        uilabel_websocketAddress.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(AppTitle.snp.bottom).offset(20)
        }
        
        textField_websocketAddress.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(uilabel_websocketAddress.snp.bottom).offset(5)
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        
        uilabel_subscribe.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(textField_websocketAddress.snp.bottom).offset(20)
        }
        
        textField_subscribe.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(uilabel_subscribe.snp.bottom).offset(5)
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        
        uiButton_Connect.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.5)
            make.top.equalTo(textField_subscribe.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        uiButton_Disconnect.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(1.5)
            make.top.equalTo(textField_subscribe.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        textField_sendMessage.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.safeAreaLayoutGuide).dividedBy(2)
            make.top.equalTo(uiButton_Connect.snp.bottom).offset(15)
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
        }
        
        uiButton_SendMessage.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.left.equalTo(textField_sendMessage.snp.right).offset(20)
            make.centerY.equalTo(textField_sendMessage)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(textField_sendMessage.snp.bottom).offset(15)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    @objc func doConnect(_ sender: AnyObject?) {
        guard let wsURL = textField_websocketAddress.text else {
            return
        }
        guard let url = NSURL(string: wsURL) else {
            return
        }
        
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self as StompClientLibDelegate, connectionHeaders: ["heart-beat": "1000,1000"])
//        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self as StompClientLibDelegate)
    }
    
    @objc func doDisconnect(_ sender: AnyObject?) {
        socketClient.disconnect()
    }
    
    @objc func sendMessage(_ sender: AnyObject?) {
        let dto = StompSendDTO(name: "Input Name", message: "Input Message")
        socketClient.sendJSONForDict(dict: dto.nsDictionary, toDestination: "/app/chat")
    }

}

extension ViewController: StompClientLibDelegate {
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        dataArr.append("\(hour):\(minute):\(second)->" + (stringBody ?? "nullData"))
        tableView.reloadData()
        scrollToBottom()
    }
    
    func scrollToBottom(){
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.dataArr.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        dataArr.append("Websocket onDisconnected!!")
        tableView.reloadData()
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        dataArr.append("Websocket onConnected!!")
        tableView.reloadData()

        let topic = self.textField_subscribe.text ?? ""
        socketClient.subscribe(destination: topic)
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        
    }
    
    func serverDidSendPing() {
        NSLog("pong")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")! as UITableViewCell
        
        cell.textLabel?.text = dataArr[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
}

