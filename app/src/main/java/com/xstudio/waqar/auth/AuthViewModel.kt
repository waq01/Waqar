package com.xstudio.waqar.auth

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
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
        _authState.value = auth.currentUser
            ?.let { AuthState.SignedIn(it) }
            ?: AuthState.SignedOut
    }

    fun buildSignInIntent(activity: Activity): Intent =
        buildClient(activity).signInIntent

    fun handleSignInResult(data: Intent?) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val account    = GoogleSignIn.getSignedInAccountFromIntent(data).getResult(ApiException::class.java)
                val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                val result     = auth.signInWithCredential(credential).await()
                _authState.value = AuthState.SignedIn(result.user!!)
                _uiState.update { it.copy(isLoading = false) }
            } catch (e: ApiException) {
                val msg = when (e.statusCode) {
                    10    -> "تحقق من SHA-1 في Firebase (كود 10)"
                    12501 -> null
                    else  -> "فشل تسجيل الدخول (كود ${e.statusCode})"
                }
                _uiState.update { it.copy(isLoading = false, error = msg) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = "${e::class.simpleName}: ${e.message}") }
            }
        }
    }

    fun setLoading() = _uiState.update { it.copy(isLoading = true, error = null) }

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

    fun signOut(activity: Activity) {
        viewModelScope.launch {
            buildClient(activity).signOut().await()
            auth.signOut()
            _authState.value = AuthState.SignedOut
        }
    }

    fun clearError() = _uiState.update { it.copy(error = null) }

    private fun buildClient(activity: Activity): GoogleSignInClient {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(activity.getString(R.string.web_client_id))
            .requestEmail()
            .build()
        return GoogleSignIn.getClient(activity, gso)
    }
}
