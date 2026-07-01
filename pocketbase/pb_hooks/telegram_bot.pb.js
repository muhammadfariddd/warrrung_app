// pocketbase/pb_hooks/telegram_bot.pb.js
// 
// File ini menangani webhook dari Telegram Bot untuk menghubungkan nomor HP user
// dengan Chat ID Telegram mereka agar bisa menerima kode OTP login gratis.

routerAdd("POST", "/api/telegram-webhook", (e) => {
    const BOT_TOKEN = "8597945420:AAG_3Dy3bXSbtA93jckUZtCpt94sMcqbwNE";
    const telegramApiUrl = "https://api.telegram.org/bot" + BOT_TOKEN + "/sendMessage";

    function sendTelegramMessage(chatId, text, replyMarkup) {
        let payload = {
            "chat_id": chatId,
            "text": text,
            "parse_mode": "Markdown"
        };
        if (replyMarkup) {
            payload["reply_markup"] = replyMarkup;
        }

        try {
            $http.send({
                url: telegramApiUrl,
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(payload)
            });
        } catch (err) {
            console.log("Gagal mengirim pesan Telegram: " + err.message);
        }
    }

    try {
        const update = {};
        try {
            e.bindBody(update);
        } catch (err) {}
        const message = update.message;

        if (!message) {
            return e.json(200, { "status": "no message to process" });
        }

        const chatId = message.chat.id;
        const senderId = message.from.id;

        // 1. Menangani Perintah /start
        if (message.text === "/start") {
            const welcomeText = "Halo! Selamat datang di Bot Telegram waRRRung 🍔☕\n\n" +
                                "Untuk menghubungkan akun Telegram Anda dengan aplikasi waRRRung agar bisa menerima kode OTP login, " +
                                "silakan ketuk tombol *Bagikan Kontak 📱* di bawah ini.";
            
            const replyMarkup = {
                "keyboard": [
                    [
                        {
                            "text": "Bagikan Kontak 📱",
                            "request_contact": true
                        }
                    ]
                ],
                "one_time_keyboard": true,
                "resize_keyboard": true
            };

            sendTelegramMessage(chatId, welcomeText, replyMarkup);
            return e.json(200, { "status": "success" });
        }

        // 2. Menangani Pengiriman Kontak (Share Contact)
        if (message.contact) {
            const contact = message.contact;

            // Validasi: pastikan kontak yang dikirim adalah kontak pengirim itu sendiri
            if (contact.user_id !== senderId) {
                sendTelegramMessage(chatId, "⚠️ Mohon bagikan nomor kontak Anda sendiri dengan menekan tombol *Bagikan Kontak 📱* di bawah.");
                return e.json(200, { "status": "invalid sender contact" });
            }

            let rawPhone = contact.phone_number.trim().replace(/\s+/g, '');
            
            // Format nomor HP ke format E.164 (+62...)
            let formattedPhone = rawPhone;
            if (!formattedPhone.startsWith("+")) {
                if (formattedPhone.startsWith("0")) {
                    formattedPhone = "+62" + formattedPhone.substring(1);
                } else if (formattedPhone.startsWith("62")) {
                    formattedPhone = "+" + formattedPhone;
                } else {
                    formattedPhone = "+" + formattedPhone;
                }
            }

            let userRecord;
            try {
                // Cari user berdasarkan nomor HP terformat
                userRecord = $app.findFirstRecordByData("users", "phone_number", formattedPhone);
            } catch (err) {
                // Jika user belum terdaftar, buat user baru
                const usersCollection = $app.findCollectionByNameOrId("users");
                userRecord = new Record(usersCollection);
                userRecord.set("phone_number", formattedPhone);
                userRecord.set("email", formattedPhone.replace("+", "") + "@warrrung.id");
                userRecord.set("name", message.from.first_name || "Sahabat waRRRung");
                userRecord.set("points", 0);
                userRecord.set("role", "customer");

                const randomPassword = $security.randomString(30);
                userRecord.setPassword(randomPassword);
            }

            // Simpan telegram_chat_id ke user record
            userRecord.set("telegram_chat_id", chatId.toString());
            $app.save(userRecord);

            const successText = "🎉 *Selamat!*\n\nNomor HP Anda *" + formattedPhone + "* berhasil dihubungkan ke waRRRung.\n\n" +
                                "Sekarang Anda sudah bisa login kembali ke aplikasi waRRRung secara nirkabel. " +
                                "Kode verifikasi OTP Anda akan dikirimkan langsung ke chat Telegram ini.";
            
            const replyMarkup = {
                "remove_keyboard": true
            };

            sendTelegramMessage(chatId, successText, replyMarkup);
            return e.json(200, { "status": "connected" });
        }

        // Teks acak / bantuan default
        sendTelegramMessage(chatId, "Silakan ketik `/start` untuk menghubungkan nomor Anda.");
        return e.json(200, { "status": "ignored" });

    } catch (err) {
        console.log("Eror pada Telegram Webhook: " + err.message);
        return e.json(500, { "error": err.message });
    }
});
