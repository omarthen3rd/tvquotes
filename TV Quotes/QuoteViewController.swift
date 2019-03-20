//
//  ViewController.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit

// swiftlint: disable line_length

extension NSMutableAttributedString {

    func boldTextIn(_ range: NSRange, size: CGFloat) {

        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font: UIFont(name: "NotoSerif-Bold", size: size)]
            addAttributes(attrs as [NSAttributedString.Key: Any], range: range)
        }

    }

    func setSizeForText(_ textToFind: String, with font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedString.Key.font: font]
            addAttributes(attrs, range: range)
        }

    }

}

extension UITextView {

    func centerVertically() {

        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset

    }

    func textExceedsBounds() -> Bool {
        let textHeight = self.contentSize.height
        return textHeight > self.bounds.height
    }

}

extension UILabel {

    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }

}

class QuoteViewController: UIViewController {

    public var viewModel: QuoteViewModel!
    var quoteTextView = UITextView()
    var quoterLabel = UILabel()
    
    var browseButton = UIButton()
    var favouriteButton = UIButton()
    var shuffleButton = UIButton()

    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createUI()

    }

    func createUI() {

        self.view.backgroundColor = UIColor.coolGray
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }

        quoteTextView = UITextView(frame: CGRect(x: 16, y: 60, width: UIScreen.main.bounds.width - 32, height: view.bounds.height * 0.8))
        quoteTextView.attributedText = viewModel.getQuoteString()
        quoteTextView.isEditable = false
        quoteTextView.isSelectable = true
        quoteTextView.backgroundColor = .clear
        quoteTextView.textColor = .white

        DispatchQueue.main.async {
            self.quoteTextView.centerVertically()
        }

        let labelY = (quoteTextView.bounds.size.height + quoteTextView.bounds.origin.y + 20)

        quoterLabel = UILabel(frame: CGRect(x: 16, y: labelY, width: UIScreen.main.bounds.width - 32, height: 40))
        quoterLabel.attributedText = viewModel.getQuoterString()
        quoterLabel.textColor = UIColor(red: 0.32, green: 0.64, blue: 0.99, alpha: 1.0)
        quoterLabel.textAlignment = .center

        // create the 3 buttons
        browseButton = createButton(with: #imageLiteral(resourceName: "browse"))
        favouriteButton = createButton(with: #imageLiteral(resourceName: "happyHeart"))
        shuffleButton = createButton(with: #imageLiteral(resourceName: "shuffle"))

        shuffleButton.addTarget(self, action: #selector(self.random(_:)), for: UIControl.Event.touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [browseButton, favouriteButton, shuffleButton])
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stackView)
        self.view.addSubview(quoteTextView)
        self.view.addSubview(quoterLabel)

        quoteTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        quoteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        quoteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true

        quoterLabel.topAnchor.constraint(equalTo: quoteTextView.bottomAnchor, constant: 10).isActive = true
        quoterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        quoterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        quoterLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: 10).isActive = true

        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true

    }

    func createButton(with: UIImage) -> UIButton {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.heightAnchor.constraint(equalToConstant: 10).isActive = true
        button.widthAnchor.constraint(equalToConstant: 10).isActive = true
        button.setImage(with.withRenderingMode(.alwaysTemplate), for: [])
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.imageView?.tintColor = UIColor(red: 0.32, green: 0.64, blue: 0.99, alpha: 1.0)
        button.tintColor = UIColor(red: 0.32, green: 0.64, blue: 0.99, alpha: 1.0)
        return button

    }

    @objc func random(_ sender: UIButton) {

        shuffleButton.setImage(#imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate), for: [])
        self.quoteTextView.attributedText = self.viewModel.getQuoteString(true)
        self.quoteTextView.textColor = .white
        self.quoterLabel.attributedText = self.viewModel.getQuoterString(true)
        DispatchQueue.main.async {
            self.quoteTextView.centerVertically()
        }

    }

}
