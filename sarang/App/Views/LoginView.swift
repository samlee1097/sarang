import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // MARK: - Form State
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSignup = false
    @State private var errorMessage: AlertError?

    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isLoading {
                ProgressView()
            }

            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.cornerRadius(8))
                    .foregroundColor(.white)
            }
            .disabled(isLoading)

            Button(action: { showSignup = true }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
                    .environmentObject(sessionManager)
            }
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

    // MARK: - Login Function
    private func login() {
        errorMessage = nil
        isLoading = true

        AuthService.shared.login(email: email, password: password) { result in
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
