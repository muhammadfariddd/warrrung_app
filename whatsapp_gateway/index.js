const { default: makeWASocket, useMultiFileAuthState, DisconnectReason } = require('@whiskeysockets/baileys');
const qrcode = require('qrcode-terminal');
const express = require('express');
const pino = require('pino');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let sock;
let isConnected = false;

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    
    // Gunakan logger silent agar terminal benar-benar bersih dari log internal/warning protocol WhatsApp
    const logger = pino({ level: 'silent' });
    
    sock = makeWASocket({
        auth: state,
        logger: logger,
        printQRInTerminal: true
    });
    
    sock.ev.on('creds.update', saveCreds);
    
    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect, qr } = update;
        
        if (qr) {
            console.log('\n[WhatsApp Gateway] Scan QR Code berikut dengan WhatsApp Anda (Linked Devices) untuk menghubungkan:\n');
            qrcode.generate(qr, { small: true });
        }
        
        if (connection === 'close') {
            isConnected = false;
            const statusCode = lastDisconnect?.error?.output?.statusCode;
            const shouldReconnect = statusCode !== DisconnectReason.loggedOut;
            console.log(`[WhatsApp Gateway] Koneksi terputus. Status Code: ${statusCode}. Mencoba menghubungkan kembali: ${shouldReconnect}`);
            if (shouldReconnect) {
                connectToWhatsApp();
            } else {
                console.log('[WhatsApp Gateway] Akun Anda keluar (logged out). Hapus folder "auth_info_baileys" lalu jalankan ulang script untuk menghubungkan baru.');
            }
        } else if (connection === 'open') {
            isConnected = true;
            console.log('\n============================================================');
            console.log('[WhatsApp Gateway] KONEKSI WA BERHASIL TERHUBUNG & SIAP PAKAI!');
            console.log('============================================================\n');
        }
    });
}

app.post('/send', async (req, res) => {
    const { number, message } = req.body;
    if (!number || !message) {
        return res.status(400).json({ error: 'Parameter "number" dan "message" wajib diisi.' });
    }
    
    if (!sock || !isConnected) {
        return res.status(503).json({ error: 'WhatsApp Gateway belum terhubung. Silakan scan QR code terlebih dahulu.' });
    }
    
    try {
        // Bersihkan nomor dari spasi, tanda tambah, dll
        let cleanNumber = number.replace(/\D/g, '');
        // Pastikan nomor diawali dengan 62 (bukan 0)
        if (cleanNumber.startsWith('0')) {
            cleanNumber = '62' + cleanNumber.substring(1);
        }
        
        const jid = `${cleanNumber}@s.whatsapp.net`;
        
        console.log(`[WhatsApp Gateway] Mengirim pesan ke ${jid}...`);
        await sock.sendMessage(jid, { text: message });
        console.log(`[WhatsApp Gateway] Pesan terkirim ke ${jid}.`);
        
        return res.json({ success: true, message: 'OTP berhasil dikirim via WhatsApp.' });
    } catch (err) {
        console.error('[WhatsApp Gateway] Gagal mengirim pesan:', err);
        return res.status(500).json({ error: 'Gagal mengirim pesan: ' + err.message });
    }
});

app.get('/status', (req, res) => {
    return res.json({ connected: isConnected });
});

connectToWhatsApp();

app.listen(3000, () => {
    console.log('[WhatsApp Gateway] API berjalan di http://localhost:3000');
});
