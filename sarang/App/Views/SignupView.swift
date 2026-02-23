import SwiftUI
import FirebaseAuth

struct SignupView: View {
    // MARK: - Form State
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage: AlertError?

    @EnvironmentObject var sessionManager: SessionManager

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
        // MARK: - Error Alert
        .alert(item: $errorMessage) { (alertError: AlertError) in
            Alert(
                title: Text("Error"),
                message: Text(alertError.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Signup Function
    private func signUp() {
        errorMessage = nil
        isLoading = true

        AuthService.shared.signUp(
            email: email,
            password: password,
            username: username,
            displayName: displayName
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let user):
                    sessionManager.currentUser = user
                    if let authUser = Auth.auth().currentUser {
                        sessionManager.authState = .authenticated(authUser)
                    }
                case .failure(let error):
                    switch error {
                    case .firebase(let code):
                        errorMessage = AlertError(message: code.localizedDescription)
                    case .unknown(let msg):
                        errorMessage = AlertError(message: msg)
                    }
                }
            }
        }
    }
}
