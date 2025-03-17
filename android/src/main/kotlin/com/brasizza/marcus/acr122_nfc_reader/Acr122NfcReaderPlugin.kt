package com.brasizza.marcus.acr122_nfc_reader

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.acs.smartcard.Reader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class Acr122NfcReaderPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var usbManager: UsbManager? = null
    private var permissionIntent: PendingIntent? = null
    private var device: UsbDevice? = null
    private var nfcReaderClass: NfcReaderClass? = null;

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "acr122_nfc_reader")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "requestPermission" -> {
                // Validate arguments
                val vendorId: Int? = call.argument("vendorId")
                val productId: Int? = call.argument("productId")
                if (vendorId == null || productId == null) {
                    return result.error(
                        "INVALID_ARGUMENTS",
                        "vendorId and productId are required",
                        null
                    )
                }
                // Get the USB device based on vendor and product IDs
                val deviceList = getUsbDevices()
                SimpleLog.d("DEVICES", deviceList.toString())
                device = deviceList?.values?.firstOrNull { usbDevice ->
                    SimpleLog.d(
                        "DEVICES",
                        "${usbDevice.vendorId} == $vendorId, ${usbDevice.manufacturerName}"
                    )
                    usbDevice.vendorId == vendorId && usbDevice.productId == productId
                }
                SimpleLog.d("DEVICE_FOUND", device.toString())
                if (device != null) {
                    requestUsbPermission(device!!, result)
                } else {
                    result.error("NO_USB_DEVICE", "Nenhum dispositivo USB encontrado", null)
                }
            }

            "getCardState" -> {
                var state = nfcReaderClass?.getCardState();
                result.success(state);

            }

            "auth" -> {
                val password: String? = call.argument("password")
                val block: Int? = call.argument("block")
                if (password != null) {
                    var auth = nfcReaderClass?.auth(password, block!!, 0);
                    SimpleLog.d("epoc", auth.toString());
                    result.success(auth);
                }
            }

            "powerOn" -> {
                nfcReaderClass?.powerOn();
                result.success(true);
            }

            "protocol" -> {
                val args = call.arguments as? Map<String, Any>
                val slot = (args?.get("slot") as? Int) ?: 0
                val protocol =
                    (args?.get("protocol") as? Int) ?: (Reader.PROTOCOL_T0 or Reader.PROTOCOL_T1)
                var protocolSent = nfcReaderClass?.setProtocol(slot, protocol);

                result.success(protocolSent);
            }

            "read" -> {
                val args = call.arguments as? Map<String, Any>
                val slot = (args?.get("slot") as? Int) ?: 0
                val command = (args?.get("command")) as List<Int>

              var response =   nfcReaderClass?.read(slot, command)
                result.success(response);


            }


            else -> result.notImplemented()
        }
    }

    /**
     * Request USB permission asynchronously without blocking the main thread.
     */
    private fun requestUsbPermission(device: UsbDevice, result: Result) {
        val currentActivity =
            activity ?: return result.error("NO_ACTIVITY", "Nenhuma Activity encontrada", null)
        usbManager = currentActivity.getSystemService(Context.USB_SERVICE) as UsbManager

        // If permission is already granted, return immediately.
        if (usbManager?.hasPermission(device) == true) {
            SimpleLog.d("USB", "Permissão já concedida.")
            nfcReaderClass = NfcReaderClass(usbManager!!, device);

            return result.success(true)
        }

        permissionIntent = PendingIntent.getBroadcast(
            currentActivity, 0,
            Intent(UsbManager.EXTRA_ACCESSORY),
            PendingIntent.FLAG_IMMUTABLE
        )

        // Use a Handler from the main looper.
        val handler = Handler(Looper.getMainLooper())
        var isCompleted = false
        SimpleLog.d("USB", "Registering broadcast receiver and posting delayed check.")
        // Register the BroadcastReceiver.
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (isCompleted) return
                SimpleLog.d("USB", "BroadcastReceiver triggered.")
                try {
                    context.unregisterReceiver(this)
                } catch (e: IllegalArgumentException) {
                    SimpleLog.e("USB", "Receiver já foi desregistrado.")
                }
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                SimpleLog.d("USB", "Permission via broadcast: $granted")
                if (granted) {
                    nfcReaderClass = NfcReaderClass(usbManager!!, device);

                    isCompleted = true
                    result.success(true)

                }
            }
        }
        currentActivity.registerReceiver(receiver, IntentFilter(UsbManager.EXTRA_ACCESSORY))

        // Request permission.
        usbManager?.requestPermission(device, permissionIntent)

        // Delayed callback to check the permission after 1 second.
        handler.postDelayed({
            if (!isCompleted) {
                isCompleted = true
                SimpleLog.d("USB", "Delayed check executing.")
                try {
                    currentActivity.unregisterReceiver(receiver)
                } catch (e: IllegalArgumentException) {
                    SimpleLog.e("USB", "Receiver já foi desregistrado.")
                }
                val permissionGranted = usbManager?.hasPermission(device) ?: false
                SimpleLog.d("USB", "Permission check after delay: $permissionGranted")
                nfcReaderClass = NfcReaderClass(usbManager!!, device);
                result.success(permissionGranted)
            } else {
                SimpleLog.d("USB", "Delayed check skipped because result is already completed.")
            }
        }, 1000)
    }


    /**
     * Returns the list of USB devices.
     */
    private fun getUsbDevices(): HashMap<String, UsbDevice>? {
        return usbManager?.deviceList
    }

    // ActivityAware implementations
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
