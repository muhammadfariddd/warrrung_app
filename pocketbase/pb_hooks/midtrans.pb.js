// pocketbase/pb_hooks/midtrans.pb.js
// 
// File ini mengimplementasikan integrasi Payment Gateway Midtrans (Snap API & Webhook Notification)
// untuk backend PocketBase waRRRung.

// Helper untuk mengambil secret dari env atau secrets.json
// (Didefinisikan secara lokal di dalam callback handler untuk kepastian scope)

// ─── CUSTOM API ENDPOINTS ───────────────────────────────────────────────────────

// 1. ENDPOINT CHECKOUT MIDTRANS (POST /api/warrrung/midtrans/checkout)
routerAdd("POST", "/api/warrrung/midtrans/checkout", (e) => {
    function getSecret(key, defaultValue) {
        let val = $os.getenv(key);
        if (val) return val;
        try {
            const secrets = require(`${__hooks}/secrets.json`);
            if (secrets && secrets[key]) {
                return secrets[key];
            }
        } catch (e) { }
        return defaultValue;
    }

    // ─── KONFIGURASI MIDTRANS ───
    const MIDTRANS_SERVER_KEY = getSecret("MIDTRANS_SERVER_KEY", "your_midtrans_server_key_here");
    const MIDTRANS_CLIENT_KEY = getSecret("MIDTRANS_CLIENT_KEY", "your_midtrans_client_key_here");
    const IS_PRODUCTION = true; // Ubah ke true jika sudah Production

    const coreApiUrl = IS_PRODUCTION
        ? "https://api.midtrans.com/v2/charge"
        : "https://api.sandbox.midtrans.com/v2/charge";

    // Helper Pure JS Base64 Encoder
    function base64Encode(str) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
        let output = '';
        let i = 0;
        while (i < str.length) {
            let char1 = str.charCodeAt(i++);
            let char2 = str.charCodeAt(i++);
            let char3 = str.charCodeAt(i++);
            let enc1 = char1 >> 2;
            let enc2 = ((char1 & 3) << 4) | (char2 >> 4);
            let enc3 = ((char2 & 15) << 2) | (char3 >> 6);
            let enc4 = char3 & 63;
            if (isNaN(char2)) enc3 = enc4 = 64;
            else if (isNaN(char3)) enc4 = 64;
            output += chars.charAt(enc1) + chars.charAt(enc2) + chars.charAt(enc3) + chars.charAt(enc4);
        }
        return output;
    }

    try {
        const data = e.requestInfo().body || {};
        const userId = data.user_id;
        const outletId = data.outlet_id;
        const orderType = data.order_type; // 'delivery' atau 'pickup'
        const deliveryAddress = data.delivery_address || "";
        const subtotal = data.subtotal;
        const deliveryFee = data.delivery_fee || 0;
        const discountFee = data.discount_fee || 0;
        const totalPayment = data.total_payment;
        const paymentMethod = data.payment_method || "qris"; // 'qris', 'gopay', dll.
        const items = data.items || []; // Array dari item { product_id, quantity, notes, customizations }

        if (!userId || !outletId || !orderType || !totalPayment) {
            return e.json(400, { "message": "Parameter user_id, outlet_id, order_type, dan total_payment wajib diisi." });
        }

        // Ambil data User untuk info transaksi Midtrans
        let userRecord;
        try {
            userRecord = $app.findRecordById("users", userId);
        } catch (err) {
            return e.json(404, { "message": "User tidak ditemukan." });
        }

        // Ambil data Outlet
        let outletRecord;
        try {
            outletRecord = $app.findRecordById("outlets", outletId);
        } catch (err) {
            return e.json(404, { "message": "Outlet tidak ditemukan." });
        }

        // 1. Buat record order baru di collection 'orders'
        const ordersCollection = $app.findCollectionByNameOrId("orders");
        const orderRecord = new Record(ordersCollection);
        orderRecord.set("user_id", userId);
        orderRecord.set("outlet_id", outletId);
        orderRecord.set("order_type", orderType);
        orderRecord.set("status", "pending_payment");
        orderRecord.set("delivery_address", deliveryAddress);
        orderRecord.set("subtotal", subtotal);
        orderRecord.set("delivery_fee", deliveryFee);
        orderRecord.set("discount_fee", discountFee);
        orderRecord.set("total_payment", totalPayment);
        orderRecord.set("payment_method", "Midtrans_" + paymentMethod);
        orderRecord.set("payment_gateway_trx_id", "");

        try {
            $app.save(orderRecord);
        } catch (err) {
            return e.json(400, {
                "message": "Gagal menyimpan data pesanan (Order).",
                "details": err.message || err.toString()
            });
        }

        // 2. Simpan list item pesanan ke dalam collection 'order_items'
        const orderItemsCollection = $app.findCollectionByNameOrId("order_items");
        for (let item of items) {
            const itemRecord = new Record(orderItemsCollection);
            itemRecord.set("order_id", orderRecord.id);
            itemRecord.set("product_id", item.product_id);
            itemRecord.set("quantity", item.quantity);
            itemRecord.set("notes", item.notes || "");
            if (item.customizations) {
                // Simpan dalam format JSON/Array String ke selected_variants
                itemRecord.set("selected_variants", JSON.stringify(item.customizations));
            }
            try {
                $app.save(itemRecord);
            } catch (err) {
                try { $app.delete(orderRecord); } catch (_) { }
                return e.json(400, {
                    "message": "Gagal menyimpan item pesanan (Order Item).",
                    "details": err.message || err.toString()
                });
            }
        }

        // 3. Request ke Midtrans Core API
        const authHeader = "Basic " + base64Encode(MIDTRANS_SERVER_KEY + ":");

        let customerDetails = {
            "first_name": userRecord.get("name") || "Pelanggan waRRRung"
        };
        const userEmail = userRecord.get("email");
        if (userEmail && userEmail.trim() !== "") {
            customerDetails["email"] = userEmail;
        }
        const userPhone = userRecord.get("phone_number");
        if (userPhone && userPhone.trim() !== "") {
            customerDetails["phone"] = userPhone;
        }

        let payload = {
            "transaction_details": {
                "order_id": orderRecord.id,
                "gross_amount": Math.round(totalPayment)
            },
            "customer_details": customerDetails
        };

        let paymentPhone = "";
        if (userPhone && typeof userPhone === "string") {
            paymentPhone = userPhone.trim();
        }
        if (!paymentPhone || paymentPhone === "") {
            paymentPhone = "08123456789";
        }

        if (paymentMethod === "gopay") {
            payload["payment_type"] = "gopay";
            payload["gopay"] = {
                "enable_callback": true,
                "callback_url": "warrrung://payment-callback"
            };
        } else if (paymentMethod === "shopeepay") {
            payload["payment_type"] = "shopeepay";
            payload["shopeepay"] = {
                "callback_url": "warrrung://payment-callback"
            };
        } else if (paymentMethod === "qris") {
            payload["payment_type"] = "qris";
            payload["qris"] = {
                "acquirer": "gopay"
            };
        } else if (paymentMethod === "dana") {
            payload["payment_type"] = "dana";
            payload["dana"] = {
                "callback_url": "warrrung://payment-callback"
            };
        } else if (paymentMethod === "ovo") {
            payload["payment_type"] = "ovo";
            payload["ovo"] = {
                "phone_number": paymentPhone
            };
        } else {
            // Fallback ke QRIS jika tidak cocok
            payload["payment_type"] = "qris";
            payload["qris"] = {
                "acquirer": "gopay"
            };
        }

        const response = $http.send({
            url: coreApiUrl,
            method: "POST",
            headers: {
                "Authorization": authHeader,
                "Content-Type": "application/json",
                "Accept": "application/json"
            },
            body: JSON.stringify(payload)
        });

        const midtransResult = response.json;
        console.log("MIDTRANS CORE API RESPONSE: " + JSON.stringify(midtransResult));

        // Deteksi jika Core API gagal (baik karena channel tidak aktif 402, payload not supported 400, dll.)
        const isCoreApiFailed = (response.statusCode >= 400) ||
            (midtransResult && midtransResult.status_code && midtransResult.status_code !== "200" && midtransResult.status_code !== "201" && midtransResult.status_code !== "202");

        if (isCoreApiFailed) {
            console.log("FALLBACK: Core API gagal (Status: " + response.statusCode + "). Menggunakan Midtrans Snap...");

            const snapApiUrl = IS_PRODUCTION
                ? "https://app.midtrans.com/snap/v1/transactions"
                : "https://app.sandbox.midtrans.com/snap/v1/transactions";

            const snapPayload = {
                "transaction_details": {
                    "order_id": orderRecord.id,
                    "gross_amount": Math.round(totalPayment)
                },
                "customer_details": customerDetails,
                "enabled_payments": [paymentMethod]
            };

            const snapResponse = $http.send({
                url: snapApiUrl,
                method: "POST",
                headers: {
                    "Authorization": authHeader,
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify(snapPayload)
            });

            if (snapResponse.statusCode >= 400) {
                try { $app.delete(orderRecord); } catch (_) { }
                return e.json(snapResponse.statusCode, {
                    "message": "Gagal membuat transaksi di Midtrans Snap (Fallback).",
                    "details": snapResponse.json
                });
            }

            const snapResult = snapResponse.json;
            orderRecord.set("payment_gateway_trx_id", snapResult.token);
            $app.save(orderRecord);

            return e.json(200, {
                "order_id": orderRecord.id,
                "transaction_id": "",
                "payment_type": "snap", // Penanda ke Flutter untuk menggunakan Snap Webview
                "deeplink_url": "",
                "qr_code_url": "",
                "qr_string": "",
                "redirect_url": snapResult.redirect_url
            });
        }

        if (response.statusCode >= 400) {
            // Hapus record order jika gagal menghubungi Midtrans
            try {
                $app.delete(orderRecord);
            } catch (err) { }
            return e.json(response.statusCode, {
                "message": "Gagal membuat transaksi di Midtrans.",
                "details": response.json
            });
        }

        if (midtransResult.status_code && midtransResult.status_code !== "200" && midtransResult.status_code !== "201") {
            try {
                $app.delete(orderRecord);
            } catch (err) { }
            return e.json(400, {
                "message": "Gagal membuat transaksi di Midtrans: " + (midtransResult.status_message || ""),
                "status_code": midtransResult.status_code,
                "details": midtransResult
            });
        }

        // Simpan ID Transaksi Midtrans ke field payment_gateway_trx_id sebagai referensi
        orderRecord.set("payment_gateway_trx_id", midtransResult.transaction_id || "");
        $app.save(orderRecord);

        // Ekstrak URL deep link, QR, atau redirect_url dari response
        let deeplinkUrl = "";
        let qrCodeUrl = "";
        let qrString = "";
        let redirectUrl = "";

        if (midtransResult.actions) {
            for (let action of midtransResult.actions) {
                if (action.name === "deeplink-redirect") {
                    deeplinkUrl = action.url;
                } else if (action.name === "generate-qr-code") {
                    qrCodeUrl = action.url;
                }
            }
        }

        if (midtransResult.qr_string) {
            qrString = midtransResult.qr_string;
        }

        if (midtransResult.redirect_url) {
            redirectUrl = midtransResult.redirect_url;
        }

        return e.json(200, {
            "order_id": orderRecord.id,
            "transaction_id": midtransResult.transaction_id || "",
            "payment_type": payload.payment_type,
            "deeplink_url": deeplinkUrl,
            "qr_code_url": qrCodeUrl,
            "qr_string": qrString,
            "redirect_url": redirectUrl
        });

    } catch (err) {
        return e.json(500, { "message": "Terjadi kesalahan di server: " + err.message });
    }
});

// 2. ENDPOINT WEBHOOK NOTIFIKASI MIDTRANS (POST /api/warrrung/midtrans/webhook)
routerAdd("POST", "/api/warrrung/midtrans/webhook", (e) => {
    function getSecret(key, defaultValue) {
        let val = $os.getenv(key);
        if (val) return val;
        try {
            const secrets = require(`${__hooks}/secrets.json`);
            if (secrets && secrets[key]) {
                return secrets[key];
            }
        } catch (e) { }
        return defaultValue;
    }

    // ─── KONFIGURASI MIDTRANS ───
    const MIDTRANS_SERVER_KEY = getSecret("MIDTRANS_SERVER_KEY", "your_midtrans_server_key_here");

    try {
        const body = e.requestInfo().body || {};
        const orderId = body.order_id;
        const statusCode = body.status_code;
        const grossAmount = body.gross_amount;
        const signatureKey = body.signature_key;
        const transactionStatus = body.transaction_status;
        const transactionId = body.transaction_id;

        if (!orderId || !statusCode || !grossAmount || !signatureKey) {
            return e.json(400, { "message": "Payload webhook tidak lengkap." });
        }

        // 1. Verifikasi Kunci Signature dari Midtrans
        // Formula: SHA512(order_id + status_code + gross_amount + ServerKey)
        const verificationString = orderId + statusCode + grossAmount + MIDTRANS_SERVER_KEY;
        const computedSignature = $security.sha512(verificationString);

        if (computedSignature !== signatureKey) {
            return e.json(403, { "message": "Verifikasi signature gagal. Notifikasi ditolak." });
        }

        // 2. Dapatkan record order berdasarkan ID
        let orderRecord;
        try {
            orderRecord = $app.findRecordById("orders", orderId);
        } catch (err) {
            return e.json(404, { "message": "Order " + orderId + " tidak ditemukan." });
        }

        // 3. Konversi status transaksi Midtrans ke status waRRRung app
        let nextStatus = orderRecord.get("status");

        if (transactionStatus === "settlement") {
            nextStatus = "processing"; // Lunas & Sedang Diproses
        } else if (transactionStatus === "capture") {
            if (body.fraud_status === "accept") {
                nextStatus = "processing";
            } else if (body.fraud_status === "challenge") {
                nextStatus = "pending_payment";
            }
        } else if (transactionStatus === "pending") {
            nextStatus = "pending_payment"; // Menunggu Pembayaran
        } else if (transactionStatus === "deny" || transactionStatus === "expire" || transactionStatus === "cancel") {
            nextStatus = "cancelled"; // Batal / Gagal
        }

        orderRecord.set("status", nextStatus);
        // Simpan ID Transaksi asli Midtrans
        orderRecord.set("payment_gateway_trx_id", transactionId);
        $app.save(orderRecord);

        return e.json(200, { "message": "Status pesanan berhasil diperbarui.", "status": nextStatus });

    } catch (err) {
        return e.json(500, { "message": "Kesalahan pemrosesan webhook: " + err.message });
    }
});
