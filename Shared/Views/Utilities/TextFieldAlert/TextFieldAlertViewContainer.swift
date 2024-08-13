//
//  TextFieldAlertViewContainer.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/7/21.
//

import SwiftUI
import Combine

struct TextFieldAlertViewContainer<Container: View>: View {
    
    // MARK: Private Properties
    
    private var content: () -> Container
    private let title: String
    private let message: String
    private var text: Binding<String>
    private var isPresented: Binding<Bool>
    private let onPositiveAction: () -> Void
    
    // MARK: Init
    
    init(@ViewBuilder content: @escaping () -> Container, title: String,
         message: String, text: Binding<String>, isPresented: Binding<Bool>, onPositiveAction: @escaping () -> Void) {
        self.content = content
        self.title = title
        self.message = message
        self.text = text
        self.isPresented = isPresented
        self.onPositiveAction = onPositiveAction
    }
    
    // MARK: View
    
    var body: some View {
        #if os(iOS)
        ZStack {
            if isPresented.wrappedValue {
                TextFieldAlert(title: title, message: message, text: self.text,
                               isPresented: isPresented, onPositiveAction: onPositiveAction)
                    .dismissable(isPresented)
            }
            content()
        }
        #elseif os(OSX)
        content()
            .sheet(isPresented: isPresented) {
                TextFieldAlertView(title: title, message: message, text: self.text, isShowing: isPresented, onPositiveAction: onPositiveAction)
                    .introspectTextField { textField in
                        textField.becomeFirstResponder()
                    }
            }
        #endif
    }
}

#if os(iOS)
struct TextFieldAlert {
  
    // MARK: Properties
  
    let title: String
    let message: String?
    @Binding var text: String
    var isPresented: Binding<Bool>? = nil
    let onPositiveAction: () -> Void
  
    // MARK: Modifiers
  
    func dismissable(_ isPresented: Binding<Bool>) -> TextFieldAlert {
        TextFieldAlert(title: title, message: message, text: $text,
                       isPresented: isPresented, onPositiveAction: onPositiveAction)
    }
}

extension TextFieldAlert: UIViewControllerRepresentable {
  
    typealias UIViewControllerType = UITextFieldAlertViewController
  
    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlert>) -> UIViewControllerType {
        UITextFieldAlertViewController(title: title, message: message, text: $text,
                                       isPresented: isPresented, onPositiveAction: onPositiveAction)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<TextFieldAlert>) {
        // no update needed
    }
}

// MARK: - UITextFieldAlertViewController

final class UITextFieldAlertViewController: UIViewController {

    // MARK: Private Properties
    
    private let alertTitle: String
    private let message: String?
    @Binding private var text: String
    private var isPresented: Binding<Bool>?
    private let onPositiveButton: () -> Void
    private var subscription: AnyCancellable?
    
    // MARK: Init
    
    init(title: String, message: String?, text: Binding<String>,
         isPresented: Binding<Bool>?, onPositiveAction: @escaping () -> Void) {
        self.alertTitle = title
        self.message = message
        self._text = text
        self.isPresented = isPresented
        self.onPositiveButton = onPositiveAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle
      
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }

    private func presentAlertController() {
        guard subscription == nil else { return } // present only once
        
        let alertViewController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alertViewController.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.text
            textField.clearButtonMode = .always
          
            self.subscription = NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: textField)
                .map { ($0.object as? UITextField)?.text ?? "" }
                .assign(to: \.text, on: self)
        }

        alertViewController.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.isPresented?.wrappedValue = false
            self?.onPositiveButton()
        })
        
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // Called when user taps outside
            self?.isPresented?.wrappedValue = false
        })
        
        present(alertViewController, animated: true, completion: nil)
    }
}
#endif
