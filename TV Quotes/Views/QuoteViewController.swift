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
            let attrs = [NSAttributedString.Key.font: UIFont(name: "NewYorkSmall-Bold", size: size)]
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
        contentInset.top = positiveTopOffset
        contentInset.left = 20
        contentInset.right = 20

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
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor.white
        }

        quoteTextView = UITextView()
        quoteTextView.attributedText = viewModel.getQuoteString()
        quoteTextView.isEditable = false
        quoteTextView.isSelectable = true
        quoteTextView.backgroundColor = .clear
    
        if #available(iOS 13.0, *) {
            quoteTextView.textColor = UIColor.label
        } else {
            quoteTextView.textColor = UIColor.black
        }

        DispatchQueue.main.async {
            self.quoteTextView.centerVertically()
        }

        quoterLabel = UILabel()
        quoterLabel.attributedText = viewModel.getQuoterString()
        quoterLabel.textColor = UIColor.systemBlue
        quoterLabel.textAlignment = .center

        // create the 3 buttons
        if #available(iOS 13.0, *) {
            // use sf symbols
            browseButton = createButton(with: UIImage(systemName: "list.dash")!)
            favouriteButton = createButton(with: UIImage(systemName: "heart")!)
            shuffleButton = createButton(with: UIImage(systemName: "shuffle")!)
        } else {
            browseButton = createButton(with: #imageLiteral(resourceName: "browse"))
            favouriteButton = createButton(with: #imageLiteral(resourceName: "happyHeart"))
            shuffleButton = createButton(with: #imageLiteral(resourceName: "shuffle"))
        }

        shuffleButton.addTarget(self, action: #selector(self.random(_:)), for: UIControl.Event.touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [browseButton, favouriteButton, shuffleButton])
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        let mainVerticalStack = UIStackView(arrangedSubviews: [quoteTextView, quoterLabel, stackView])
        mainVerticalStack.alignment = .fill
        mainVerticalStack.axis = .vertical
        mainVerticalStack.distribution = .fill
        mainVerticalStack.spacing = 10

        self.view.addSubview(mainVerticalStack)

        let safeArea = view.safeAreaLayoutGuide
        mainVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStack.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true
        mainVerticalStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0).isActive = true
        mainVerticalStack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0).isActive = true
        mainVerticalStack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0).isActive = true

        stackView.heightAnchor.constraint(equalToConstant: 40).isActive = true

    }

    func createButton(with: UIImage) -> UIButton {

        let button = UIButton()
        button.bounds.size.height = 40
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.setImage(with.withRenderingMode(.alwaysTemplate), for: [])
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor.systemBlue
        button.tintColor = UIColor.systemBlue
        return button

    }

    @objc func random(_ sender: UIButton) {

        if #available(iOS 13.0, *) {
            let arrow = UIImage(systemName: "arrow.right")!
            shuffleButton.setImage(arrow.withRenderingMode(.alwaysTemplate), for: [])
        } else {
            shuffleButton.setImage(#imageLiteral(resourceName: "next").withRenderingMode(.alwaysTemplate), for: [])
        }
        self.quoteTextView.attributedText = self.viewModel.getQuoteString(true)
        if #available(iOS 13.0, *) {
            quoteTextView.textColor = UIColor.label
        } else {
            quoteTextView.textColor = UIColor.black
        }
        self.quoterLabel.attributedText = self.viewModel.getQuoterString(true)
        DispatchQueue.main.async {
            self.quoteTextView.centerVertically()
        }

    }

}
