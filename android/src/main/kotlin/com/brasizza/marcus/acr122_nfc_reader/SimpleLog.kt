package com.brasizza.marcus.acr122_nfc_reader

import android.util.Log

class SimpleLog {
    companion object {
        // Toggle this flag to enable or disable logging globally.
        var isLoggingEnabled = true

        fun d(tag: String, message: String) {
            if (isLoggingEnabled) Log.d(tag, message)
        }

        fun e(tag: String, message: String) {
            if (isLoggingEnabled) Log.e(tag, message)
        }

        fun i(tag: String, message: String) {
            if (isLoggingEnabled) Log.i(tag, message)
        }

        fun w(tag: String, message: String) {
            if (isLoggingEnabled) Log.w(tag, message)
        }
    }
}
