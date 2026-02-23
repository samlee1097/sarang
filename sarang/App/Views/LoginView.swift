import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSignup = false
    @State private var errorMessage: AlertError?
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login").font(.largeTitle).bold()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if isLoading { ProgressView() }
            
            Button("Login", action: login)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.cornerRadius(8))
                .foregroundColor(.white)
                .disabled(isLoading)
            
            Button("Don't have an account? Sign Up") {
                showSignup = true
            }
            .foregroundColor(.blue)
            .sheet(isPresented: $showSignup) {
                SignupView().environmentObject(sessionManager)
            }
        }
        .padding()
        .alert(item: $errorMessage) { alert in
            Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error as NSError? {
                    errorMessage = AlertError(message: error.localizedDescription)
                    return
                }
                
                guard let fbUser = result?.user else {
                    errorMessage = AlertError(message: "Login succeeded but no user returned")
                    return
                }
                
                // Fetch AppUser from Firestore using the Firebase UID
                UserService().getUser(userId: fbUser.uid) { fetchResult in
                    DispatchQueue.main.async {
                        switch fetchResult {
                        case .success(let appUser):
                            // Only mark authenticated once Firestore AppUser is fetched
                            sessionManager.authState = .authenticated(appUser)
                        case .failure(let err):
                            errorMessage = AlertError(message: "Failed to fetch AppUser: \(err)")
                            // Optionally, sign out Firebase user if AppUser is missing
                            try? Auth.auth().signOut()
                        }
                    }
                }
            }
        }
    }
}
