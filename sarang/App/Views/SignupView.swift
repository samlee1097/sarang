import SwiftUI
import FirebaseAuth

struct AlertError: Identifiable {
    let id = UUID()
    let message: String
}

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage: AlertError?

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Username", text: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Display Name", text: $displayName)
                .autocapitalization(.words)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isLoading {
                ProgressView()
            }

            Button(action: signUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.cornerRadius(8))
                    .foregroundColor(.white)
            }
            .disabled(isLoading)
        }
        .padding()
        .alert(item: $errorMessage) { alertError in
            Alert(title: Text("Error"),
                  message: Text(alertError.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func signUp() {
        errorMessage = nil
        isLoading = true

        AuthService.shared.signUp(email: email, password: password, username: username, displayName: displayName) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    print("Signup success!")
                    // Optionally, navigate to next screen or dismiss this view
                case .failure(let error):
                    switch error {
                    case .firebase(let authErrorCode):
                        errorMessage = AlertError(message: firebaseErrorMessage(authErrorCode))
                    case .unknown(let msg):
                        errorMessage = AlertError(message: msg)
                    }
                }
            }
        }
    }

    private func firebaseErrorMessage(_ errorCode: AuthErrorCode) -> String {
        switch errorCode {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .wrongPassword:
            return "Incorrect password."
        case .userNotFound:
            return "There is no user corresponding to this email."
        case .networkError:
            return "Network error. Please try again."
        default:
            return errorCode.errorMessage
        }
    }
}

private extension AuthErrorCode {
    var errorMessage: String {
        return self.localizedDescription
    }
}
