//
//  SettingsView.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 05/05/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            }
            
            // show the alert to the user that says:
            // "We're going to delete your account. This is absolutely permanent, you can't restore yopur data, there is no going back. Are you sure?"
            // Then if they confirm it, it's good to tell the user to resign into his account, so that he get reauthenticated, and then delete an account
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }

            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
//            unwrapping Bool? value
//            if let user = viewModel.authUser, user.isAnonymous {
//
//            }
            // unwrapping Bool? value
            if viewModel.authUser?.isAnonymous == true  {
                anonymousSection
            }
            
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}



extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET!")
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED!")
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
                
                // Error Domain=FIRAuthErrorDomain Code=17014 "This operation is sensitive and requires recent authentication. Log in again before retrying this request." UserInfo={NSLocalizedDescription=This operation is sensitive and requires recent authentication. Log in again before retrying this request., FIRAuthErrorUserInfoNameKey=ERROR_REQUIRES_RECENT_LOGIN} //
                
                // we should display some info for the user:
                // " In order to update your password you first need to sign back to your account (or sign in again)"
                // and then another screen would appear that says "Write your new password"
                // Then you will run try await viewModel.updatePassword() function
                // same thing with updating email
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED!")
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
    
    
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            }
            
            Button("Link Apple Account") {
//                Task {
//                    do {
//                        try await viewModel.linkAppleAccount()
//                        print("APPLE LINKED!")
//                    } catch {
//                        // error handling (displaying sth for the user)
//                        print(error)
//                    }
//                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED!")
                    } catch {
                        // error handling (displaying sth for the user)
                        print(error)
                    }
                }
            }
        } header: {
            Text("Create Account")
        }
    }
}
