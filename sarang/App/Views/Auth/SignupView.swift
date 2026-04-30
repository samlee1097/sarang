import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage: AlertError?
    
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign Up").font(.largeTitle).bold()
                
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
                
                if isLoading { ProgressView() }
                
                Button("Sign Up", action: signUp)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.cornerRadius(8))
                    .foregroundColor(.white)
                    .disabled(isLoading)
            }
            .padding()
            .alert(item: $errorMessage) { alert in
                Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error as NSError? {
                    errorMessage = AlertError(message: error.localizedDescription)
                    return
                }
                
                guard let fbUser = result?.user else {
                    errorMessage = AlertError(message: "Signup succeeded but no user returned")
                    return
                }
                
                // Create Firestore user
                let appUser = AppUser(
                    id: fbUser.uid,
                    username: username,
                    email: email,
                    display_name: displayName,
                    profile_image_url: "default_profile",
                    onboarding_completed: false,
                    created_at: Date(),
                    updated_at: Date()
                )
                
                UserService().addUser(user: appUser) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            sessionManager.authState = .authenticated(appUser)
                        case .failure(let error):
                            errorMessage = AlertError(message: "Signup succeeded but failed to save user: \(error)")
                        }
                    }
                }
            }
        }
    }
}
