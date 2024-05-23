//  DetailViewController.swift
//  DictionaryApp
//
//  Created by Zeynep Özcan on 19.05.2024.
//

import Foundation
import UIKit
import DictionaryAPI

protocol DetailViewControllerProtocol: AnyObject {
    func displayWordDetails(_ wordElement: WordElement)
    func displayError(_ error: String)
    func showWordDetail(word: String)
}

class DetailViewController: UIViewController {
    var presenter: DetailPresenterProtocol?

    private let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let phoneticLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        return label
    }()
    
    private let partOfSpeechScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let partOfSpeechStackView: UIStackView = {
        let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .center //?
            stackView.distribution = .fillProportionally
            stackView.spacing = 10
            return stackView
    }()
    
    private let meaningsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        return textView
    }()
    
    private let definitionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presentingViewController != nil {
            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
            backButton.addTarget(self, action: #selector(dismissDetail), for: .touchUpInside)
            backButton.frame = CGRect(x: 0, y: 40, width: 60, height: 60)
            backButton.tintColor = .gray
            view.addSubview(backButton)
        }
    }
    
    @objc private func dismissDetail() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.addSubview(wordLabel)
            view.addSubview(phoneticLabel)
            view.addSubview(partOfSpeechScrollView)
            partOfSpeechScrollView.addSubview(partOfSpeechStackView)
            view.addSubview(meaningsTextView)
            
            wordLabel.translatesAutoresizingMaskIntoConstraints = false
            phoneticLabel.translatesAutoresizingMaskIntoConstraints = false
            partOfSpeechScrollView.translatesAutoresizingMaskIntoConstraints = false
            partOfSpeechStackView.translatesAutoresizingMaskIntoConstraints = false
            meaningsTextView.translatesAutoresizingMaskIntoConstraints = false
            definitionLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                wordLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                phoneticLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 8),
                phoneticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                phoneticLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                
                partOfSpeechScrollView.topAnchor.constraint(equalTo: phoneticLabel.bottomAnchor, constant: 16),
                partOfSpeechScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                partOfSpeechScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                partOfSpeechScrollView.heightAnchor.constraint(equalToConstant: 50),
                
                partOfSpeechStackView.topAnchor.constraint(equalTo: partOfSpeechScrollView.topAnchor),
                partOfSpeechStackView.leadingAnchor.constraint(equalTo: partOfSpeechScrollView.leadingAnchor),
                partOfSpeechStackView.trailingAnchor.constraint(equalTo: partOfSpeechScrollView.trailingAnchor),
                partOfSpeechStackView.bottomAnchor.constraint(equalTo: partOfSpeechScrollView.bottomAnchor),
                partOfSpeechStackView.heightAnchor.constraint(equalTo: partOfSpeechScrollView.heightAnchor),
                
                meaningsTextView.topAnchor.constraint(equalTo: partOfSpeechScrollView.bottomAnchor, constant: 16),
                meaningsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                meaningsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                meaningsTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
    }
    
    private func createPartOfSpeechButtons(for partsOfSpeech: [String]) {
        partOfSpeechStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for part in partsOfSpeech {
            let button = UIButton(type: .system)
            button.setTitle(part, for: .normal)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 15
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.addTarget(self, action: #selector(partOfSpeechButtonTapped(_:)), for: .touchUpInside)
            partOfSpeechStackView.addArrangedSubview(button)
        }
    }

    @objc private func partOfSpeechButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        // Tıklanan butona göre ilgili işlemi yap
    }

    func showError(_ error: String) {
        wordLabel.text = "Error: \(error)"
    }
}

extension DetailViewController: DetailViewControllerProtocol {
    func displayError(_ error: String) {
        definitionLabel.text = error
    }
    
    func displayWordDetails(_ word: WordElement) {
        wordLabel.text = word.word
        phoneticLabel.text = word.phonetic
        
        if let meanings = word.meanings {
            let partsOfSpeech = meanings.compactMap { $0.partOfSpeech }
            createPartOfSpeechButtons(for: partsOfSpeech)
        }
        
        let definitionsText = word.meanings?.compactMap { meaning in
            guard let partOfSpeech = meaning.partOfSpeech else { return nil }
            let definitions = meaning.definitions?.compactMap { $0.definition }.joined(separator: "\n")
            return "\(partOfSpeech): \(definitions ?? "")"
        }.joined(separator: "\n\n")
        
        meaningsTextView.text = definitionsText
    }
    
    func showWordDetail(word: String) {
        wordLabel.text = word
    }
}
