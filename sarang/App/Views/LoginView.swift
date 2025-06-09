import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isLoading = false

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
        .alert(isPresented: Binding<Bool>(
            get: { sessionManager.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    sessionManager.clearError()
                }
            }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(sessionManager.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    sessionManager.clearError()
                }
            )
        }
    }

    private func login() {
        sessionManager.clearError()
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    sessionManager.setError(error.localizedDescription)
                }
            }
        }
    }

    private func signUp() {
        sessionManager.clearError()
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    sessionManager.setError(error.localizedDescription)
                }
            }
        }
    }
}
