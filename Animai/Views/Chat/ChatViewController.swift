//
//  ChatViewController.swift
//  Animai
//
//  Created by XCODE on 13/08/26.
//

import UIKit
import Combine

final class ChatViewController: UIViewController {
    
    private let viewModel = ChatViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet private weak var headerView: UIView!
    
    @IBOutlet private weak var assistantImageView: UIImageView!
    
    @IBOutlet private weak var assistantNameLabel: UILabel!
    
    @IBOutlet private weak var connectionStatusLabel: UILabel!
    
    @IBOutlet private weak var optionsButton: UIButton!
    
    @IBOutlet private weak var messagesTableView: UITableView!
    
    @IBOutlet private weak var messageInputView: UIView!
    
    @IBOutlet private weak var messageTextField: UITextField!
    
    @IBOutlet private weak var sendButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        bindViewModel()
        messageTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !TokenManager.shared.hasValidSession() {
            AppNavigator.handleSessionExpired(from: self)
            return
        }

        Task {
            await viewModel.fetchHistory()
        }
    }

    private func setupUI() {
        // Estilos de la entrada de texto
        messageTextField.layer.cornerRadius = 18
        messageTextField.layer.masksToBounds = true
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.borderColor = AppTheme.separator.cgColor
        messageTextField.backgroundColor = .white

        // Añadir padding izquierdo al texto
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        messageTextField.leftView = paddingView
        messageTextField.leftViewMode = .always

        // El botón 'sendButton' ya tiene su imagen 'image_Send' configurada en el Storyboard
        sendButton.tintColor = AppTheme.primaryBlue
    }
    
    
    @IBAction private func sendButtonTapped(_ sender: UIButton) {
        sendCurrentMessage()
        
    }
    
    
    @IBAction private func optionsButtonTapped(_ sender: UIButton) {
    }
    
    
    private func setupTableView() {
        
        messagesTableView.dataSource = self
        
        
        let assistantNib = UINib(
            nibName: "AssistantMessageTableViewCell",
            bundle: nil
        )

        let userNib = UINib(
            nibName: "UserMessageTableViewCell",
            bundle: nil
        )

        messagesTableView.register(
            assistantNib,
            forCellReuseIdentifier: AssistantMessageTableViewCell.identifier
        )

        messagesTableView.register(
            userNib,
            forCellReuseIdentifier: UserMessageTableViewCell.identifier
        )
    }
    
    private func bindViewModel() {
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messagesTableView.reloadData()
                self?.scrollToLastMessage()
            }
            .store(in: &cancellables)
    }
    
    
    private func scrollToLastMessage() {
        guard viewModel.numberOfMessages > 0 else {
            return
        }

        let lastIndexPath = IndexPath(
            row: viewModel.numberOfMessages - 1,
            section: 0
        )

        messagesTableView.scrollToRow(
            at: lastIndexPath,
            at: .bottom,
            animated: true
        )
    }
    
    
    private func sendCurrentMessage() {
        let text = messageTextField.text ?? ""
        viewModel.messageText = text
        messageTextField.text = ""
        Task {
            await viewModel.sendMessage()
        }
    }
    
    
}

extension ChatViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.numberOfMessages
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let message = viewModel.message(at: indexPath.row)

        switch message.sender {
        case .assistant:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AssistantMessageTableViewCell.identifier,
                for: indexPath
            ) as? AssistantMessageTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(with: message.text)
            return cell

        case .user:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserMessageTableViewCell.identifier,
                for: indexPath
            ) as? UserMessageTableViewCell else {
                return UITableViewCell()
            }

            cell.configure(with: message.text)
            return cell
        }
    }
}


extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCurrentMessage()
        return true
    }
}
