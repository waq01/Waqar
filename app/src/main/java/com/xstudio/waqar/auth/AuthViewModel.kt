package com.xstudio.waqar.auth

import android.app.Activity
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.xstudio.waqar.R
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

sealed class AuthState {
    object Checking  : AuthState()
    object SignedOut : AuthState()
    data class SignedIn(val user: FirebaseUser) : AuthState()
}

data class AuthUiState(
    val isLoading: Boolean = false,
    val error: String?     = null
)

class AuthViewModel : ViewModel() {

    private val auth = FirebaseAuth.getInstance()

    private val _authState = MutableStateFlow<AuthState>(AuthState.Checking)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        val user = auth.currentUser
        _authState.value = if (user != null) AuthState.SignedIn(user) else AuthState.SignedOut
    }

    fun signInWithGoogle(activity: Activity) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val token = getGoogleIdToken(activity, filterByAuthorized = true)
                    ?: getGoogleIdToken(activity, filterByAuthorized = false)
                    ?: run {
                        _uiState.update { it.copy(isLoading = false, error = "لا يوجد حساب Google على الجهاز") }
                        return@launch
                    }

                val firebaseCredential = GoogleAuthProvider.getCredential(token, null)
                val authResult = auth.signInWithCredential(firebaseCredential).await()
                _authState.value = AuthState.SignedIn(authResult.user!!)
                _uiState.update { it.copy(isLoading = false) }

            } catch (e: GetCredentialCancellationException) {
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: NoCredentialException) {
                _uiState.update { it.copy(isLoading = false, error = "لا يوجد حساب Google على الجهاز") }
            } catch (e: GetCredentialException) {
                _uiState.update { it.copy(isLoading = false, error = "خطأ: ${e.type} - ${e.message}") }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "${e::class.simpleName}: ${e.message}") }
            }
        }
    }

    private suspend fun getGoogleIdToken(activity: Activity, filterByAuthorized: Boolean): String? {
        return try {
            val credentialManager = CredentialManager.create(activity)
            val option = GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(filterByAuthorized)
                .setServerClientId(activity.getString(R.string.web_client_id))
                .setAutoSelectEnabled(false)
                .build()
            val request = GetCredentialRequest.Builder()
                .addCredentialOption(option)
                .build()
            val result = credentialManager.getCredential(activity, request)
            val credential = result.credential
            if (credential is CustomCredential &&
                credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
            ) {
                GoogleIdTokenCredential.createFrom(credential.data).idToken
            } else null
        } catch (e: NoCredentialException) {
            null
        } catch (e: GetCredentialCancellationException) {
            throw e
        } catch (e: Exception) {
            if (filterByAuthorized) null else throw e
        }
    }

    fun signInAsGuest() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val result = auth.signInAnonymously().await()
                _authState.value = AuthState.SignedIn(result.user!!)
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "فشل الدخول كضيف") }
            }
        }
    }

    fun clearError() = _uiState.update { it.copy(error = null) }
}
