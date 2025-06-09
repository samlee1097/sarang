import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isLoading = false
    @State private var showSignup = false
    
    private var isShowingError: Binding<Bool> {
        Binding<Bool>(
            get: { sessionManager.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    sessionManager.errorMessage = nil
                }
            }
        )
    }
    
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
            
            Button(action: {
                showSignup = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
                    .environmentObject(sessionManager)
            }
        }
        .padding()
        .alert(isPresented: isShowingError) {
            Alert(
                title: Text("Error"),
                message: Text(sessionManager.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    sessionManager.errorMessage = nil
                }
            )
        }
    }
    
    private func login() {
        sessionManager.errorMessage = nil
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    sessionManager.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
