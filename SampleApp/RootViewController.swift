//
//  Copyright © Uber Technologies, Inc. All rights reserved.
//

import Cyborg
import UIKit

class RootViewController: ViewController<ImportView> {
    
    let theme: Theme
    let resources: Resources
    let preferences: Preferences
    
    init(preferences: Preferences) {
        self.preferences = preferences
        theme = preferences.theme
        resources = preferences.resources
        super.init(viewCreator: ImportView.init)
        title = "Import"
        navigationItem.prompt = "Copy paste the VectorDrawable code into the text view"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem
            .setRightBarButton(UIBarButtonItem(title: "Theme",
                                               style: .plain,
                                               target: self,
                                               action: #selector(editThemeTapped)),
                               animated: false)
        specializedView
            .importButton
            .addTarget(self,
                       action: #selector(importButtonTapped),
                       for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        specializedView.textView.becomeFirstResponder()
    }
    
    @objc
    func importButtonTapped() {
        if let data = (specializedView.textView.text ?? "").data(using: .utf8) {
            switch VectorDrawable.create(from: data) {
            case .ok(let drawable):
                navigationController
                    .orAssert("This view controller requires a navigation controller to function correctly")?
                    .pushViewController(DisplayViewController(drawable: drawable,
                                                              theme: theme,
                                                              resources: resources),
                                        animated: true)
            case .error(let error):
                showError(message: error)
            }
        } else {
            showError(message: "Couldn't convert the text to UTF-8.")
        }
    }
    
    @objc
    func editThemeTapped() {
        navigationController
            .orAssert("This view controller requires a navigation controller to function correctly")?
            .pushViewController(ThemeEditorViewController(preferences: preferences),
                                animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
        )
        present(alert, animated: true, completion: nil)
    }
    
}

class ImportView: View {
    
    let importButton: UIButton = {
        let button = Button()
        button.setTitle("Import", for: .normal)
        return button
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = UIFont(name: "Menlo-Regular", size: bodyFont.pointSize) ?? bodyFont
        return textView
    }()
    
    private var observer: AnyObject?
    
    override init() {
        super.init()
        backgroundColor = .white
        addSubview(textView)
        addSubview(importButton)
        textView.translatesAutoresizingMaskIntoConstraints = false
        importButton.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = 10
        let importButtonBottomConstraint = importButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: padding)
        observer = importButtonBottomConstraint.moveWithKeyboard(in: self)
        NSLayoutConstraint
            .activate([
                importButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                importButtonBottomConstraint,
                textView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
                textView.bottomAnchor.constraint(equalTo: importButton.bottomAnchor, constant: padding),
                textView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor)
                ])
    }
    
}

class Button: UIButton {
    
    // TODO: add touch feedback, make this better resemble Apple's tinted buttons
    
    init() {
        super.init(frame: .zero)
        setTitleColor(.white, for: .normal)
        backgroundColor = tintColor
        layer.cornerRadius = 5
    }
    
    @available(*, unavailable, message: "NSCoder and Interface Builder is not supported. Use Programmatic layout.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var original = super.intrinsicContentSize
        original.width += 20
        return original
    }

}
