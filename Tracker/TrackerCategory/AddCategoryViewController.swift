import UIKit

final class AddCategoryViewController: UIViewController {
    
    // MARK: - Modes
    enum Mode {
        case create
        case edit(originalName: String)
    }
    
    // MARK: - Properties
    var mode: Mode = .create
    
    // Колбэк для создания новой категории
    var onCategoryAdded: ((String) -> Void)?
    // Колбэк для переименования: (старое имя, новое имя)
    var onCategoryRenamed: ((String, String) -> Void)?
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Localizable.AddCategory.title
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = Localizable.AddCategory.placeholder
        field.backgroundColor = .backgroundDay // в светлой теме остается как было
        field.layer.cornerRadius = 16
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.font = UIFont.systemFont(ofSize: 17)
        field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        field.returnKeyType = .done
        field.clearButtonMode = .whileEditing
        field.delegate = self
        return field
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localizable.Common.done, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestureRecognizer()
        applyMode()
        applyTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme()
        // Пересчитываем внешний вид кнопки по текущему состоянию
        updateDoneButtonAppearance(enabled: doneButton.isEnabled)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        [titleLabel, textField, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func applyTheme() {
        view.backgroundColor = .systemBackground
        titleLabel.textColor = .label
        
        // Поле ввода: светлая — как было, темная — системный заполнитель
        if traitCollection.userInterfaceStyle == .dark {
            textField.backgroundColor = .tertiarySystemFill
            textField.keyboardAppearance = .dark
        } else {
            textField.backgroundColor = .backgroundDay
            textField.keyboardAppearance = .light
        }
        textField.textColor = .label
        textField.tintColor = .label
        textField.attributedPlaceholder = NSAttributedString(
            string: Localizable.AddCategory.placeholder,
            attributes: [.foregroundColor: UIColor.secondaryLabel]
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func applyMode() {
        switch mode {
        case .create:
            titleLabel.text = Localizable.AddCategory.title
            textField.text = ""
            textField.placeholder = Localizable.AddCategory.placeholder
            doneButton.isEnabled = false
            updateDoneButtonAppearance(enabled: false)
            
        case .edit(let originalName):
            titleLabel.text = NSLocalizedString("editCategory.title", comment: "Edit category title")
            textField.text = originalName
            validate(text: originalName)
        }
    }
    
    private func updateDoneButtonAppearance(enabled: Bool) {
        if enabled {
            if traitCollection.userInterfaceStyle == .dark {
                doneButton.backgroundColor = .white
                doneButton.setTitleColor(.black, for: .normal)
            } else {
                doneButton.backgroundColor = .black
                doneButton.setTitleColor(.white, for: .normal)
            }
        } else {
            doneButton.backgroundColor = .ypGray
            doneButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func validate(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .create:
            let enabled = !trimmed.isEmpty
            doneButton.isEnabled = enabled
            updateDoneButtonAppearance(enabled: enabled)
        case .edit(let originalName):
            let enabled = !trimmed.isEmpty && trimmed != originalName
            doneButton.isEnabled = enabled
            updateDoneButtonAppearance(enabled: enabled)
        }
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        validate(text: textField.text ?? "")
    }
    
    @objc private func doneButtonTapped() {
        guard let text = textField.text else { return }
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        switch mode {
        case .create:
            onCategoryAdded?(name)
        case .edit(let originalName):
            onCategoryRenamed?(originalName, name)
        }
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if doneButton.isEnabled {
            doneButtonTapped()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 38
    }
}
