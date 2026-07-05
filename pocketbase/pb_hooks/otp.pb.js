// pocketbase/pb_hooks/otp.pb.js
// 
// File ini menangani sistem login berbasis Email + OTP Gmail untuk backend PocketBase waRRRung.

// Helper untuk mengambil secret dari env atau secrets.json
function getSecret(key, defaultValue) {
    let val = $os.getenv(key);
    if (val) return val;

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

// 1. ENDPOINT REQUEST OTP (POST /api/warrrung/request-otp)
routerAdd("POST", "/api/warrrung/request-otp", (e) => {
    function getSecret(key, defaultValue) {
        let val = $os.getenv(key);
        if (val) return val;
        try {
            const secrets = require(`${__hooks}/secrets.json`);
            if (secrets && secrets[key]) {
                return secrets[key];
            }
        } catch (e) {}
        return defaultValue;
    }

    const data = e.requestInfo().body || {};
    let email = data.email;

    if (!email || email.trim() === "" || !email.includes("@")) {
        return e.json(400, { "message": "Email wajib diisi dengan format yang valid." });
    }

    email = email.trim().toLowerCase();

    try {
        // 1. Cari user berdasarkan email
        let userRecord;
        try {
            userRecord = $app.findAuthRecordByEmail("users", email);
        } catch (err) {
            // Jika user belum terdaftar, otomatis buat user baru (Registrasi on-the-fly)
            const usersCollection = $app.findCollectionByNameOrId("users");
            userRecord = new Record(usersCollection);
            userRecord.set("email", email);
            userRecord.set("name", email.split('@')[0]); // Gunakan prefix email sebagai nama default
            userRecord.set("points", 0);
            userRecord.set("role", "customer");
            
            const randomPassword = $security.randomString(30);
            userRecord.setPassword(randomPassword);

            $app.save(userRecord);
        }

        // 2. Buat OTP acak 4-digit
        const otp = Math.floor(1000 + Math.random() * 9000).toString();

        // 3. Hapus OTP lama untuk email ini jika ada
        try {
            const oldOtps = $app.findRecordsByFilter("otps", "email = {:email}", "", 100, 0, { email: email });
            for (let record of oldOtps) {
                $app.delete(record);
            }
        } catch (err) {}

        // 4. Simpan OTP baru ke database
        const otpsCollection = $app.findCollectionByNameOrId("otps");
        const otpRecord = new Record(otpsCollection);
        otpRecord.set("email", email);
        otpRecord.set("phone_number", email); // Set phone_number to email to satisfy the required database constraint
        otpRecord.set("otp_code", otp);
        // Berlaku 5 menit
        const expDate = new Date();
        expDate.setMinutes(expDate.getMinutes() + 5);
        otpRecord.set("expired_at", expDate.toISOString());
        $app.save(otpRecord);

        // 5. Kirim email OTP menggunakan konfigurasi SMTP di Mail Settings
        try {
            const message = new MailerMessage({
                from: {
                    address: $app.settings().meta.senderAddress,
                    name:    $app.settings().meta.senderName || "waRRRung",
                },
                to: [{ address: email }],
                subject: "Kode OTP waRRRung Anda",
                html: "🔐 Kode OTP Anda untuk masuk ke waRRRung adalah: <b>" + otp + "</b><br><br>Kode ini berlaku selama 5 menit. Jangan bagikan kode ini kepada siapa pun.",
            });
            $app.newMailClient().send(message);
        } catch (mailErr) {
            console.log("[EMAIL OTP FAIL] Gagal mengirim email: " + mailErr.message);
        }

        // 6. Selalu log ke konsol agar memudahkan debugging lokal tanpa membuka email
        console.log("[EMAIL OTP SUCCESS] Kode OTP untuk " + email + " adalah: " + otp);

        return e.json(200, { "message": "Kode OTP telah dikirim ke email Anda. Silakan periksa inbox atau folder spam." });

    } catch (err) {
        return e.json(500, { "message": "Terjadi kesalahan di server: " + err.message });
    }
});

// 2. ENDPOINT VERIFY OTP (POST /api/warrrung/verify-otp)
routerAdd("POST", "/api/warrrung/verify-otp", (e) => {
    const data = e.requestInfo().body || {};
    let email = data.email;
    const otpCode = data.otp;

    if (!email || !otpCode) {
        return e.json(400, { "message": "Email dan kode OTP wajib diisi." });
    }

    email = email.trim().toLowerCase();

    try {
        // 1. Cari data OTP di collection 'otps'
        let otpRecord;
        try {
            const records = $app.findRecordsByFilter("otps", "email = {:email} && otp_code = {:otp}", "", 1, 0, { email: email, otp: otpCode });
            if (records && records.length > 0) {
                otpRecord = records[0];
            }
        } catch (err) {}

        if (!otpRecord) {
            return e.json(400, { "message": "Kode OTP salah atau tidak ditemukan." });
        }

        // 2. Cek apakah OTP sudah kedaluwarsa
        const expiredAt = new Date(otpRecord.get("expired_at"));
        const now = new Date();
        if (now > expiredAt) {
            $app.delete(otpRecord);
            return e.json(400, { "message": "Kode OTP sudah kedaluwarsa. Silakan minta kode baru." });
        }

        // 3. OTP Valid: Hapus record OTP dan cari user
        $app.delete(otpRecord);

        const userRecord = $app.findAuthRecordByEmail("users", email);

        // 4. Generate token JWT resmi dari PocketBase untuk Flutter
        const token = userRecord.newAuthToken();

        return e.json(200, {
            "token": token,
            "record": {
                "id": userRecord.id,
                "collectionId": userRecord.collection().id,
                "collectionName": userRecord.collection().name,
                "email": userRecord.get("email"),
                "name": userRecord.get("name"),
                "points": userRecord.get("points"),
                "role": userRecord.get("role")
            }
        });

    } catch (err) {
        return e.json(400, { "message": "Proses verifikasi gagal: " + err.message });
    }
});
