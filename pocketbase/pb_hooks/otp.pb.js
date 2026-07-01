// pocketbase/pb_hooks/otp.pb.js
// 
// File ini mencakup 5 opsi implementasi:
// OPSI A: Menggunakan Twilio Verify API (Rekomendasi - Skala Industri)
// OPSI B: Menggunakan Fonnte.com (Rekomendasi jika ingin menggunakan nomor WhatsApp pribadi Anda sendiri)
// OPSI C: LOCAL_MOCK (100% GRATIS & MANDIRI untuk pengembangan/testing lokal tanpa token external)
// OPSI D: META_WABA (Official WhatsApp Cloud API Resmi dari Meta)
// OPSI E: LOCAL_GATEWAY (Node.js Gateway berjalan lokal di port 3000 menggunakan Baileys)

// Helper untuk mengambil secret dari env atau secrets.json
function getSecret(key, defaultValue) {
    // 1. Coba dari environment variable
    let val = $os.getenv(key);
    if (val) return val;

    // 2. Coba dari pb_hooks/secrets.json
    try {
        const secrets = require(`${__hooks}/secrets.json`);
        if (secrets && secrets[key]) {
            return secrets[key];
        }
    } catch (e) {
        // file tidak ditemukan atau error parsing
    }

    return defaultValue;
}

// ─── CUSTOM API ENDPOINTS ───────────────────────────────────────────────────────

// 1. ENDPOINT REQUEST OTP (POST /api/warrierung/request-otp)
routerAdd("POST", "/api/warrierung/request-otp", (e) => {
    // ─── KONFIGURASI backend ───
    const ACTIVE_OPTION = 'TELEGRAM'; // Pilihan: 'TELEGRAM', 'LOCAL_MOCK', 'TWILIO', 'FONNTE', 'META_WABA', 'LOCAL_GATEWAY'

    // 1. Konfigurasi Twilio Verify
    const TWILIO_ACCOUNT_SID = getSecret("TWILIO_ACCOUNT_SID", "your_twilio_account_sid_here");
    const TWILIO_AUTH_TOKEN = getSecret("TWILIO_AUTH_TOKEN", "your_twilio_auth_token_here");
    const TWILIO_VERIFY_SERVICE_SID = getSecret("TWILIO_VERIFY_SERVICE_SID", "your_twilio_verify_service_sid_here");

    // 2. Konfigurasi Fonnte
    const FONNTE_API_TOKEN = 'your_fonnte_token_here'; 

    // 3. Konfigurasi Official WhatsApp Cloud API Meta (Opsi D)
    const META_PHONE_NUMBER_ID = '1145767515289452'; 
    const META_ACCESS_TOKEN = getSecret("META_ACCESS_TOKEN", "your_meta_access_token_here");

    // Helper Pure JS Base64 Encoder karena Goja tidak menyediakan base64 secara global
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

    const data = {
        phone_number: ""
    };
    try {
        e.bindBody(data);
    } catch (err) {}
    let phoneNumber = data.phone_number;

    if (!phoneNumber) {
        return e.json(400, { "message": "Nomor handphone wajib diisi." });
    }

    // Format nomor ke E.164 (+62...) dan hapus spasi
    phoneNumber = phoneNumber.trim().replace(/\s+/g, '');
    if (!phoneNumber.startsWith("+")) {
        if (phoneNumber.startsWith("0")) {
            phoneNumber = "+62" + phoneNumber.substring(1);
        } else {
            phoneNumber = "+" + phoneNumber;
        }
    }

    if (ACTIVE_OPTION === 'TELEGRAM') {
        // --- OPSI F: TELEGRAM BOT OTP ---
        try {
            // Cari user berdasarkan nomor HP untuk mendapatkan telegram_chat_id
            let userRecord;
            let telegramChatId = "";
            try {
                userRecord = $app.findFirstRecordByData("users", "phone_number", phoneNumber);
                telegramChatId = userRecord.get("telegram_chat_id");
            } catch (err) {
                // User belum terdaftar / nomor tidak ditemukan
            }

            let isFallback = false;
            if (!telegramChatId || telegramChatId.trim() === "") {
                isFallback = true;
            }

            const otp = isFallback ? "1234" : Math.floor(1000 + Math.random() * 9000).toString(); // 4 digit
            
            // Simpan OTP sementara di database
            const otpsCollection = $app.findCollectionByNameOrId("otps");
            
            // Hapus OTP lama untuk nomor ini jika ada
            try {
                const oldOtps = $app.findRecordsByFilter("otps", "phone_number = {:phone}", "", 100, 0, { phone: phoneNumber });
                for (let record of oldOtps) {
                    $app.delete(record);
                }
            } catch (err) {}

            const otpRecord = new Record(otpsCollection);
            otpRecord.set("phone_number", phoneNumber);
            otpRecord.set("otp_code", otp);
            // Expired dalam 5 menit
            const expDate = new Date();
            expDate.setMinutes(expDate.getMinutes() + 5);
            otpRecord.set("expired_at", expDate.toISOString());
            $app.save(otpRecord);

            if (isFallback) {
                // Jika fallback, tidak perlu menembak API Telegram. Langsung sukses.
                console.log("[OTP FALLBACK] Nomor " + phoneNumber + " menggunakan OTP default: 1234");
                return e.json(200, { "message": "OTP dikirim. (Gunakan 1234 jika Telegram belum terhubung)" });
            }

            // Kirim OTP ke Telegram via Bot API
            const BOT_TOKEN = getSecret("TELEGRAM_BOT_TOKEN", "your_telegram_bot_token_here");
            const response = $http.send({
                url: "https://api.telegram.org/bot" + BOT_TOKEN + "/sendMessage",
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    chat_id: telegramChatId,
                    text: "Kode verifikasi waRRRung Anda adalah: *" + otp + "*\n\nKode ini berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.",
                    parse_mode: "Markdown"
                })
            });

            if (response.statusCode >= 400) {
                return e.json(response.statusCode, { 
                    "message": "Gagal mengirim OTP melalui Telegram. Silakan coba kembali.",
                    "details": response.json
                });
            }

            return e.json(200, { "message": "OTP berhasil dikirim ke Telegram." });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Telegram request-otp: " + err.message });
        }
    } else if (ACTIVE_OPTION === 'LOCAL_GATEWAY') {
        // --- OPSI E: LOCAL SELF-HOSTED GATEWAY (Node.js di port 3000) ---
        try {
            const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4 digit
            
            // Simpan OTP sementara di database
            const otpsCollection = $app.findCollectionByNameOrId("otps");
            
            // Hapus OTP lama untuk nomor ini jika ada
            try {
                const oldOtps = $app.findRecordsByFilter("otps", "phone_number = {:phone}", "", 100, 0, { phone: phoneNumber });
                for (let record of oldOtps) {
                    $app.delete(record);
                }
            } catch (err) {}

            const otpRecord = new Record(otpsCollection);
            otpRecord.set("phone_number", phoneNumber);
            otpRecord.set("otp_code", otp);
            // Expired dalam 5 menit
            const expDate = new Date();
            expDate.setMinutes(expDate.getMinutes() + 5);
            otpRecord.set("expired_at", expDate.toISOString());
            $app.save(otpRecord);

            // Kirim request ke WhatsApp gateway lokal kita
            const response = $http.send({
                url: "http://127.0.0.1:3000/send",
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    number: phoneNumber,
                    message: `Kode verifikasi waRRRung Anda adalah: ${otp}. Kode ini berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.`
                })
            });

            if (response.statusCode >= 400) {
                return e.json(response.statusCode, { 
                    "message": "Gagal mengirim OTP melalui Local WhatsApp Gateway. Pastikan server lokal Anda di port 3000 sudah berjalan dan terhubung.",
                    "details": response.json
                });
            }

            return e.json(200, { "message": "OTP berhasil dikirim ke WhatsApp via Local Gateway." });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Local Gateway request-otp: " + err.message });
        }
    } else if (ACTIVE_OPTION === 'LOCAL_MOCK') {
        // --- OPSI C: LOCAL MOCK FLOW (100% GRATIS & MANDIRI) ---
        try {
            const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4 digit
            
            // Simpan OTP sementara di database
            const otpsCollection = $app.findCollectionByNameOrId("otps");
            
            // Hapus OTP lama untuk nomor ini jika ada
            try {
                const oldOtps = $app.findRecordsByFilter("otps", "phone_number = {:phone}", "", 100, 0, { phone: phoneNumber });
                for (let record of oldOtps) {
                    $app.delete(record);
                }
            } catch (err) {
                // acuhkan jika tidak ada
            }

            const otpRecord = new Record(otpsCollection);
            otpRecord.set("phone_number", phoneNumber);
            otpRecord.set("otp_code", otp);
            // Expired dalam 5 menit
            const expDate = new Date();
            expDate.setMinutes(expDate.getMinutes() + 5);
            otpRecord.set("expired_at", expDate.toISOString());
            $app.save(otpRecord);

            // Log OTP ke console PocketBase secara jelas agar developer bisa membacanya di terminal
            console.log("\n============================================================");
            console.log(`[OTP WA DEVELOPMENT] Kode OTP untuk ${phoneNumber} adalah: ${otp}`);
            console.log("============================================================\n");

            return e.json(200, { 
                "message": "[DEV MODE] OTP berhasil dibuat. Silakan cek console PocketBase untuk menyalin kode OTP.",
                "otp_code": otp
            });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Local Mock request-otp: " + err.message });
        }
    } else if (ACTIVE_OPTION === 'TWILIO') {
        // --- OPSI A: TWILIO VERIFY ---
        try {
            const twilioAuthHeader = "Basic " + base64Encode(TWILIO_ACCOUNT_SID + ":" + TWILIO_AUTH_TOKEN);
            const response = $http.send({
                url: `https://verify.twilio.com/v2/Services/${TWILIO_VERIFY_SERVICE_SID}/Verifications`,
                method: "POST",
                headers: {
                    "Authorization": twilioAuthHeader,
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: `To=${encodeURIComponent(phoneNumber)}&Channel=whatsapp`
            });

            if (response.statusCode >= 400) {
                return e.json(response.statusCode, { 
                    "message": "Gagal mengirim OTP melalui Twilio.",
                    "details": response.json
                });
            }

            return e.json(200, { "message": "OTP berhasil dikirim ke WhatsApp via Twilio." });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Twilio request-otp: " + err.message });
        }
    } else if (ACTIVE_OPTION === 'META_WABA') {
        // --- OPSI D: OFFICIAL WHATSAPP CLOUD API META ---
        try {
            const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4 digit
            
            // Simpan OTP sementara di database
            const otpsCollection = $app.findCollectionByNameOrId("otps");
            
            // Hapus OTP lama untuk nomor ini jika ada
            try {
                const oldOtps = $app.findRecordsByFilter("otps", "phone_number = {:phone}", "", 100, 0, { phone: phoneNumber });
                for (let record of oldOtps) {
                    $app.delete(record);
                }
            } catch (err) {}

            const otpRecord = new Record(otpsCollection);
            otpRecord.set("phone_number", phoneNumber);
            otpRecord.set("otp_code", otp);
            // Expired dalam 5 menit
            const expDate = new Date();
            expDate.setMinutes(expDate.getMinutes() + 5);
            otpRecord.set("expired_at", expDate.toISOString());
            $app.save(otpRecord);

            const response = $http.send({
                url: `https://graph.facebook.com/v17.0/${META_PHONE_NUMBER_ID}/messages`,
                method: "POST",
                headers: {
                    "Authorization": "Bearer " + META_ACCESS_TOKEN,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    messaging_product: "whatsapp",
                    to: phoneNumber,
                    type: "template",
                    template: {
                        name: "otp_verifikasi_warrrung", // Sesuaikan nama template yang terdaftar di Meta Developer Console
                        language: { code: "id" },
                        components: [
                            {
                                type: "body",
                                parameters: [
                                    {
                                        type: "text",
                                        text: otp
                                    }
                                ]
                            }
                        ]
                    }
                })
            });

            if (response.statusCode >= 400) {
                return e.json(response.statusCode, { 
                    "message": "Gagal mengirim OTP melalui Meta Cloud API.",
                    "details": response.json
                });
            }

            return e.json(200, { "message": "OTP berhasil dikirim ke WhatsApp via Meta Cloud API." });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Meta Cloud API request-otp: " + err.message });
        }
    } else {
        // --- OPSI B: FONNTE (NOMOR PRIBADI) ---
        try {
            const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4 digit
            
            // Simpan OTP sementara di database
            const otpsCollection = $app.findCollectionByNameOrId("otps");
            
            // Hapus OTP lama untuk nomor ini jika ada
            try {
                const oldOtps = $app.findRecordsByFilter("otps", "phone_number = {:phone}", "", 100, 0, { phone: phoneNumber });
                for (let record of oldOtps) {
                    $app.delete(record);
                }
            } catch (err) {
                // acuhkan jika tidak ada
            }

            const otpRecord = new Record(otpsCollection);
            otpRecord.set("phone_number", phoneNumber);
            otpRecord.set("otp_code", otp);
            // Expired dalam 5 menit
            const expDate = new Date();
            expDate.setMinutes(expDate.getMinutes() + 5);
            otpRecord.set("expired_at", expDate.toISOString());
            $app.save(otpRecord);

            // Kirim pesan WhatsApp menggunakan API Fonnte
            const response = $http.send({
                url: "https://api.fonnte.com/send",
                method: "POST",
                headers: {
                    "Authorization": FONNTE_API_TOKEN,
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: `target=${encodeURIComponent(phoneNumber)}&message=${encodeURIComponent(`Kode verifikasi waRRRung Anda adalah: ${otp}. Kode ini berlaku selama 5 menit.`)}`
            });

            if (response.statusCode >= 400) {
                return e.json(response.statusCode, { 
                    "message": "Gagal mengirim OTP melalui Fonnte.",
                    "details": response.json
                });
            }

            return e.json(200, { "message": "OTP berhasil dikirim ke WhatsApp via Fonnte." });
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Fonnte request-otp: " + err.message });
        }
    }
});

// 2. ENDPOINT VERIFY OTP (POST /api/warrierung/verify-otp)
routerAdd("POST", "/api/warrierung/verify-otp", (e) => {
    // ─── KONFIGURASI backend ───
    const ACTIVE_OPTION = 'TELEGRAM'; // Pilihan: 'TELEGRAM', 'LOCAL_MOCK', 'TWILIO', 'FONNTE', 'META_WABA', 'LOCAL_GATEWAY'

    // 1. Konfigurasi Twilio Verify
    const TWILIO_ACCOUNT_SID = getSecret("TWILIO_ACCOUNT_SID", "your_twilio_account_sid_here");
    const TWILIO_AUTH_TOKEN = getSecret("TWILIO_AUTH_TOKEN", "your_twilio_auth_token_here");
    const TWILIO_VERIFY_SERVICE_SID = getSecret("TWILIO_VERIFY_SERVICE_SID", "your_twilio_verify_service_sid_here");

    // 2. Konfigurasi Fonnte (Untuk menggunakan nomor WA Pribadi Anda)
    const FONNTE_API_TOKEN = 'your_fonnte_token_here'; 

    // Helper Pure JS Base64 Encoder karena Goja tidak menyediakan base64 secara global
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

    const data = {
        phone_number: "",
        otp: ""
    };
    try {
        e.bindBody(data);
    } catch (err) {}
    let phoneNumber = data.phone_number;
    const otpCode = data.otp;

    if (!phoneNumber || !otpCode) {
        return e.json(400, { "message": "Nomor handphone dan kode OTP wajib diisi." });
    }

    // Format nomor ke E.164 (+62...) dan hapus spasi
    phoneNumber = phoneNumber.trim().replace(/\s+/g, '');
    if (!phoneNumber.startsWith("+")) {
        if (phoneNumber.startsWith("0")) {
            phoneNumber = "+62" + phoneNumber.substring(1);
        } else {
            phoneNumber = "+" + phoneNumber;
        }
    }

    let isOtpValid = false;

    if (ACTIVE_OPTION === 'TWILIO') {
        // --- OPSI A: TWILIO VERIFY CHECK ---
        try {
            const twilioAuthHeader = "Basic " + base64Encode(TWILIO_ACCOUNT_SID + ":" + TWILIO_AUTH_TOKEN);
            const response = $http.send({
                url: `https://verify.twilio.com/v2/Services/${TWILIO_VERIFY_SERVICE_SID}/VerificationCheck`,
                method: "POST",
                headers: {
                    "Authorization": twilioAuthHeader,
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: `To=${encodeURIComponent(phoneNumber)}&Code=${encodeURIComponent(otpCode)}`
            });

            if (response.statusCode < 400) {
                const verificationResult = response.json;
                if (verificationResult.status === "approved") {
                    isOtpValid = true;
                }
            }
        } catch (err) {
            return e.json(500, { "message": "Kesalahan Twilio verify-otp: " + err.message });
        }
    } else {
        // --- OPSI B, C, D & E (FONNTE, LOCAL_MOCK, META_WABA, LOCAL_GATEWAY) VERIFY CHECK ---
        try {
            // Cari data OTP di collection 'otps'
            const record = $app.findFirstRecordByData("otps", "phone_number", phoneNumber);
            if (record) {
                const dbOtp = record.get("otp_code");
                const expiredAtStr = record.get("expired_at");
                const expiredAt = new Date(expiredAtStr);
                const now = new Date();

                if (dbOtp === otpCode && now < expiredAt) {
                    isOtpValid = true;
                    // Hapus record OTP setelah berhasil digunakan
                    $app.delete(record);
                }
            }
        } catch (err) {
            return e.json(400, { "message": "Kode OTP salah atau tidak ditemukan." });
        }
    }

    if (!isOtpValid) {
        return e.json(400, { "message": "Kode OTP salah atau sudah kedaluwarsa." });
    }

    // OTP Valid! Cari atau buat user baru di collection `users` PocketBase
    let userRecord;
    try {
        userRecord = $app.findFirstRecordByData("users", "phone_number", phoneNumber);
    } catch (err) {
        // Jika record tidak ditemukan, buat user baru
        const usersCollection = $app.findCollectionByNameOrId("users");
        userRecord = new Record(usersCollection);
        userRecord.set("phone_number", phoneNumber);
        // Set placeholder email karena email di PocketBase users collection bersifat required & unique
        userRecord.set("email", phoneNumber.replace("+", "") + "@warrrung.id");
        userRecord.set("name", "Sahabat waRRRung");
        userRecord.set("points", 0);
        userRecord.set("role", "customer");
        
        // Set password acak untuk keamanan
        const randomPassword = $security.randomString(30);
        userRecord.setPassword(randomPassword);

        $app.save(userRecord);
    }

    // Generate token JWT resmi dari PocketBase untuk Flutter
    const token = userRecord.newAuthToken();

    return e.json(200, {
        "token": token,
        "record": {
            "id": userRecord.id,
            "collectionId": userRecord.collection().id,
            "collectionName": userRecord.collection().name,
            "phone_number": userRecord.get("phone_number"),
            "name": userRecord.get("name"),
            "points": userRecord.get("points"),
            "role": userRecord.get("role")
        }
    });
});
