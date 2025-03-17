package com.brasizza.marcus.acr122_nfc_reader

import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import com.acs.smartcard.Reader
import com.acs.smartcard.ReaderException
import org.json.JSONObject

class NfcReaderClass(
    private val usbManager: UsbManager,
    private val device: UsbDevice,

    ) {
    private var reader: Reader = Reader(usbManager)

    init {
        try {
            reader.open(device)
        } catch (e: ReaderException) {
            print(e.printStackTrace());
        }
    }

    fun read(slot: Int?, command: List<Int>?): String? {
        val mySlot = (slot ?: 0);

        val commandList = command as? List<Int> ?: throw Exception("Command Vazio")
        val command = ByteArray(commandList.size) { i ->
            commandList[i].toByte()
        }
        val response = ByteArray(300)
        try {
            val responseLength =
                reader?.transmit(mySlot, command, command.size, response, response.size) ?: 0

            return (response.copyOf(responseLength)
                .toString(Charsets.UTF_8)
                .filter { it.isLetterOrDigit() || it.isWhitespace() })
        } catch (e: ReaderException) {
            print(e.printStackTrace());
            return  ""
        }
    }

    fun setProtocol(slot: Int?, protocol: Int?): Int? {
        val mySlot = (slot) ?: 0
        val myProtocol = (protocol) ?: (Reader.PROTOCOL_T0 or Reader.PROTOCOL_T1)
        try {
          return   reader?.setProtocol(mySlot, myProtocol)
        } catch (e: ReaderException) {
            print(e.printStackTrace());
            return 0;
        }
    }

    fun powerOn(): Boolean {
        try {
            reader.power(0, Reader.CARD_WARM_RESET)
            return true;
        } catch (e: ReaderException) {
            return true;
        }
    }

    fun getCardState(): Int? {
        try {
            var state = reader?.getState(0);
            return state;

        } catch (e: ReaderException) {
            print(e.printStackTrace())
           return 0 ;
        }

    }

    /**
     * Converts a hexadecimal string to a byte array.
     * Assumes that the input is valid and contains an even number of characters.
     */
    private fun hexStringToByteArray(s: String): ByteArray {
        if (s.length % 2 != 0) return ByteArray(0)
        val data = ByteArray(s.length / 2)
        for (i in data.indices) {
            val index = i * 2
            data[i] = s.substring(index, index + 2).toInt(16).toByte()
        }
        return data
    }


    fun auth(password: String, block: Int, slot: Int): String {
        val json = JSONObject()
        try {
            // Validate password length
            if (password.length != 12) {
                json.put("status", "error")
                json.put("errorCode", "INVALID_KEY")
                json.put("message", "Password is invalid")
                return json.toString()
            }

            // Convert password hex string to a byte array (6 bytes)
            val keyBytes = hexStringToByteArray(password)

            // Build load key command: FF 82 00 00 06 <key>
            val loadKeyCmd = ByteArray(11)
            loadKeyCmd[0] = 0xFF.toByte()
            loadKeyCmd[1] = 0x82.toByte()
            loadKeyCmd[2] = 0x00.toByte()  // Use volatile memory
            loadKeyCmd[3] = 0x00.toByte()  // Key slot 0
            loadKeyCmd[4] = 0x06.toByte()  // Key length: 6 bytes
            System.arraycopy(keyBytes, 0, loadKeyCmd, 5, 6)

            val response = ByteArray(300)
            var responseLength = reader.control(
                slot,
                Reader.IOCTL_CCID_ESCAPE,
                loadKeyCmd,
                loadKeyCmd.size,
                response,
                response.size
            )

            if (responseLength <= 0) {
                json.put("status", "error")
                json.put("errorCode", "LOAD_KEY_FAILED")
                json.put("message", "No valid response for load key")
                return json.toString()
            }

            // Build MIFARE authentication command:
            // FF 86 00 00 05 01 00 <block> 60 00
            val authCmd = ByteArray(10)
            authCmd[0] = 0xFF.toByte()
            authCmd[1] = 0x86.toByte()
            authCmd[2] = 0x00.toByte()
            authCmd[3] = 0x00.toByte()
            authCmd[4] = 0x05.toByte()
            authCmd[5] = 0x01.toByte()
            authCmd[6] = 0x00.toByte()
            authCmd[7] = block.toByte()
            authCmd[8] = 0x60.toByte()  // Key type: 0x60 for Key A
            authCmd[9] = 0x00.toByte()  // Key slot 0

            responseLength = reader.control(
                slot,
                Reader.IOCTL_CCID_ESCAPE,
                authCmd,
                authCmd.size,
                response,
                response.size
            )

            if (responseLength <= 0) {
                json.put("status", "error")
                json.put("errorCode", "AUTH_FAILED")
                json.put("message", "No valid response for authentication")
                return json.toString()
            }

            // Trim the response to the actual length and convert to a hex string.
            val trimmedResponse = response.copyOf(responseLength)
            val hexResponse = trimmedResponse.joinToString("") { String.format("%02X", it) }

            // Extract the status word (last two bytes of the response)
            val statusWord = if (responseLength >= 2) {
                trimmedResponse.copyOfRange(responseLength - 2, responseLength)
                    .joinToString("") { String.format("%02X", it) }
            } else {
                ""
            }

            // Check status word for success (9000) and build JSON accordingly.
            if (statusWord == "9000") {
                json.put("status", "success")
                json.put("data", hexResponse)
            } else {
                json.put("status", "error")
                json.put("errorCode", statusWord)
                json.put("message", "Authentication failed with status: $statusWord")
            }
            return json.toString()
        } catch (e: ReaderException) {
            json.put("status", "error")
            json.put("errorCode", "READER_EXCEPTION")
            json.put("message", e.message)
            return json.toString()
        } catch (e: Exception) {
            json.put("status", "error")
            json.put("errorCode", "EXCEPTION")
            json.put("message", e.message)
            return json.toString()
        }
    }


}
