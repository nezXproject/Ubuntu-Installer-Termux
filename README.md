# 🐧 Ubuntu 22.04 di Termux — Panduan Lengkap untuk Pemula

Panduan ini dibuat **sangat jelas dan detail**, cocok untuk yang **baru pertama kali** pakai Termux. Ikuti langkahnya satu per satu, jangan skip.

---

## 📌 Daftar Isi

1. [Apa itu Termux dan Ubuntu?](#1-apa-itu-termux-dan-ubuntu)
2. [Persiapan Sebelum Install](#2-persiapan-sebelum-install)
3. [Cara Install Termux yang Benar](#3-cara-install-termux-yang-benar)
4. [Cara Install Ubuntu (Step by Step)](#4-cara-install-ubuntu-step-by-step)
5. [Cara Masuk ke Ubuntu](#5-cara-masuk-ke-ubuntu)
6. [Setup Pertama Kali di Ubuntu](#6-setup-pertama-kali-di-ubuntu)
7. [Cara Keluar dari Ubuntu](#7-cara-keluar-dari-ubuntu)
8. [Cara Hapus/Uninstall Ubuntu](#8-cara-hapusuninstall-ubuntu)
9. [Masalah Umum dan Solusinya](#9-masalah-umum-dan-solusinya)
10. [Pertanyaan yang Sering Ditanya (FAQ)](#10-pertanyaan-yang-sering-ditanya-faq)

---

## 1. Apa itu Termux dan Ubuntu?

### 🤔 Termux itu apa?
Termux adalah **aplikasi terminal Linux di Android**. Anggap saja seperti "mini komputer Linux" yang jalan di HP kamu. Tanpa perlu root.

### 🤔 Ubuntu itu apa?
Ubuntu adalah **sistem operasi Linux** yang populer. Biasanya dipakai di laptop/PC.

### 🤔 Kenapa install Ubuntu di Termux?
- Belajar Linux tanpa beli laptop
- Menjalankan tools Linux (Python, Git, dll)
- Coding di HP
- Server kecil di HP

> ⚠️ **Catatan penting:** Ubuntu di Termux **BUKAN** Ubuntu asli 100%. Namanya **PRoot** — semacam "simulasi" Ubuntu. Beberapa fitur seperti systemd, Docker, dan kernel tidak akan jalan.

---

## 2. Persiapan Sebelum Install

Sebelum mulai, pastikan hal-hal berikut:

### ✅ Ceklis Persiapan

| No | Persyaratan | Cara Cek | Minimal |
|----|-------------|----------|---------|
| 1 | Android versi | Settings → About Phone | Android 7.0+ |
| 2 | Arsitektur HP | Buka Termux → ketik `uname -m` | `aarch64` |
| 3 | Ruang penyimpanan | Settings → Storage | **3 GB kosong** |
| 4 | RAM | Settings → About Phone | 2 GB+ |
| 5 | Internet | Buka browser | Stabil |

### ❌ JANGAN pakai Termux dari Play Store
Termux di Play Store **sudah usang** dan **banyak error**. Wajib pakai dari **F-Droid**.

---

## 3. Cara Install Termux yang Benar

### Langkah 1: Download F-Droid
1. Buka browser di HP
2. Kunjungi: **https://f-droid.org**
3. Klik tombol **Download F-Droid**
4. Install file APK-nya (izinkan "Install from unknown sources" jika diminta)

### Langkah 2: Install Termux dari F-Droid
1. Buka aplikasi **F-Droid** yang baru diinstall
2. Ketik di kolom pencarian: `Termux`
3. Pilih **Termux** (bukan Termux:API, bukan Termux:Styling)
4. Klik **Install**
5. Tunggu sampai selesai

### Langkah 3: Buka Termux
1. Buka aplikasi Termux
2. Akan muncul layar hitam dengan tulisan `$` — itu artinya Termux siap
3. Ketik perintah berikut untuk update:
```bash
pkg update && pkg upgrade -y
```
4. Tunggu sampai selesai (bisa 5-10 menit pertama kali)
5. Jika muncul pertanyaan, tekan `Enter` atau ketik `y`

> 💡 **Tips:** Jika muncul "Do you want to continue? [Y/n]", ketik `y` lalu Enter.

---

## 4. Cara Install Ubuntu (Step by Step)

### 🚀 Metode 1: Cara Otomatis (Paling Mudah — DISARANKAN)

**Copy paste perintah ini ke Termux, lalu tekan Enter:**

```bash
pkg install -y git && git clone https://github.com/nezXproject/Ubuntu-Installer-Termux.git && cd Ubuntu-Installer-Termux && bash termux-ubuntu-installer.sh
```

**Apa yang terjadi?** Perintah di atas akan:
1. Install `git` (untuk download file dari GitHub)
2. Download repository installer dari GitHub
3. Masuk ke folder hasil download
4. Jalankan script installer Ubuntu

**Tunggu 10-20 menit.** Proses yang akan berjalan:

| Tahap | Waktu | Keterangan |
|-------|-------|------------|
| Cek sistem | 10 detik | Cek HP, storage, kernel |
| Install dependencies | 1-2 menit | Install proot, wget, tar |
| Download Ubuntu | 5-15 menit | ~500 MB, tergantung internet |
| Ekstrak file | 2-5 menit | Extract rootfs |
| Konfigurasi | 30 detik | Setup DNS & launcher |
| Verifikasi | 30 detik | Tes instalasi |

Jika berhasil, akan muncul tulisan:
```
╔══════════════════════════════════════════════════╗
║          INSTALASI BERHASIL! 🎉                  ║
╚══════════════════════════════════════════════════╝
```

---

### 🛠️ Metode 2: Cara Manual (Jika Metode 1 Gagal)

#### Langkah 1: Install Dependencies

Ketik satu per satu di Termux:

```bash
pkg install -y proot wget tar git
```

Penjelasan:
- `proot` — Untuk menjalankan Ubuntu
- `wget` — Untuk download file
- `tar` — Untuk ekstrak file
- `git` — Untuk download dari GitHub

#### Langkah 2: Download Installer

```bash
git clone https://github.com/nezXproject/Ubuntu-Installer-Termux.git
```

#### Langkah 3: Masuk ke Folder

```bash
cd Ubuntu-Installer-Termux
```

#### Langkah 4: Jalankan Installer

```bash
bash termux-ubuntu-installer.sh
```

Tunggu sampai selesai. Jangan tutup aplikasi Termux.

---

## 5. Cara Masuk ke Ubuntu

Setelah instalasi selesai, ketik:

```bash
~/startubuntu.sh
```

**Tunggu 5-15 detik.** Jika berhasil, tampilan prompt akan berubah dari:
```
~ $
```
menjadi:
```
root@localhost:~#
```

> 🎉 **Selamat! Kamu sekarang sudah masuk ke Ubuntu!**

Coba ketik perintah ini untuk tes:
```bash
cat /etc/os-release
```
Harus muncul tulisan `Ubuntu 22.04`.

---

## 6. Setup Pertama Kali di Ubuntu

Setelah masuk Ubuntu, **lakukan ini dulu** (sekali saja):

### Langkah 1: Update Package

```bash
apt update && apt upgrade -y
```

⏱️ Tunggu 3-10 menit. Kalau muncul pertanyaan, tekan `Enter`.

### Langkah 2: Install Tools Dasar

```bash
apt install -y build-essential git python3 python3-pip nano vim curl wget net-tools
```

Penjelasan:
- `build-essential` — Compiler (untuk compile program)
- `git` — Version control
- `python3`, `python3-pip` — Python & package manager
- `nano`, `vim` — Text editor
- `curl`, `wget` — Download file
- `net-tools` — Tools network

### Langkah 3: Buat User Baru (Opsional, tapi Disarankan)

```bash
adduser ubuntu
```
- Masukkan password (bebas)
- Tekan Enter untuk yang lain
- Ketik `y` saat ditanya "Is the information correct?"

Setelah itu, keluar & masuk lagi sebagai user:
```bash
exit
~/startubuntu.sh
su - ubuntu
```

---

## 7. Cara Keluar dari Ubuntu

Ketik:
```bash
exit
```

Atau tekan **Ctrl + D** di keyboard.

Kamu akan kembali ke Termux (prompt jadi `~ $` lagi).

---

## 8. Cara Hapus/Uninstall Ubuntu

Kalau mau hapus Ubuntu dan bebaskan storage:

```bash
bash ~/uninstall-ubuntu.sh
```

Akan muncul konfirmasi:
```
Apakah Anda yakin? (y/N):
```

Ketik `y` lalu Enter.

> ⚠️ **PERINGATAN:** Semua file di dalam Ubuntu akan **HILANG PERMANEN**. Backup dulu kalau ada file penting!

---

## 9. Masalah Umum dan Solusinya

### ❌ Masalah 1: "Kernel too old"

**Gejala:** Muncul error saat masuk Ubuntu.

**Solusi:**
1. Edit file launcher:
```bash
nano ~/startubuntu.sh
```
2. Cari baris ini (sekitar baris 18):
```
PROOT_ARGS=""
```
3. Ubah jadi:
```
PROOT_ARGS="-k 4.14.81"
```
4. Simpan: tekan `Ctrl + X`, lalu `Y`, lalu `Enter`
5. Coba lagi: `~/startubuntu.sh`

---

### ❌ Masalah 2: "No space left on device"

**Gejala:** Install gagal karena storage penuh.

**Solusi:**
1. Cek storage:
```bash
df -h
```
2. Hapus install lama:
```bash
rm -rf ~/ubuntu-fs
```
3. Kosongkan cache Termux:
```bash
pkg clean
rm -rf ~/.cache
```
4. Install ulang

---

### ❌ Masalah 3: "proot: command not found"

**Solusi:**
```bash
pkg update
pkg install proot -y
```

---

### ❌ Masalah 4: Network tidak jalan di Ubuntu

**Gejala:** `ping google.com` gagal.

**Solusi (dari dalam Ubuntu):**
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
```

Kalau masih gagal:
1. Keluar Ubuntu (`exit`)
2. Cek internet HP (buka browser)
3. Masuk Ubuntu lagi

---

### ❌ Masalah 5: Ubuntu lambat / lag

**Ini NORMAL.** PRoot memang lambat karena harus "menipu" sistem Android.

**Yang bisa dilakukan:**
- Tutup aplikasi lain yang berjalan
- Jangan jalankan aplikasi berat
- Restart Termux sesekali

---

### ❌ Masalah 6: Muncul "Cannot open /dev/tty"

**Solusi:**
```bash
pkg install -y ncurses-utils
~/startubuntu.sh
```

---

### ❌ Masalah 7: Download Ubuntu stuck / gagal

**Solusi:**
1. Cek koneksi internet
2. Hapus file rusak:
```bash
rm -f ~/ubuntu-rootfs.tar.gz
```
3. Jalankan ulang installer
4. Kalau masih gagal, coba pakai WiFi (bukan data seluler)

---

## 10. Pertanyaan yang Sering Ditanya (FAQ)

### ❓ Apakah perlu root?
**Tidak.** Installer ini 100% tanpa root.

### ❓ Apakah HP saya bisa rusak?
**Tidak.** Ubuntu di Termux hanya "aplikasi biasa", tidak mengubah sistem Android.

### ❓ Berapa storage yang dibutuhkan?
Minimal **3 GB** kosong. Rekomendasi **5 GB+**.

### ❓ Bisa install GUI (tampilan desktop)?
Bisa, tapi butuh setup tambahan (VNC atau Termux:X11). Cari tutorial "Termux X11" di Google.

### ❓ Bisa install Docker?
**Tidak bisa.** Docker butuh fitur kernel yang tidak bisa diakses PRoot.

### ❓ Bisa jalankan server web (nginx, apache)?
**Bisa**, tapi harus dijalankan manual:
```bash
service nginx start
```
Tidak akan auto-start saat Ubuntu dibuka.

### ❓ Bisa install Node.js / PHP / lainnya?
**Bisa.** Asalkan tersedia di repositori Ubuntu:
```bash
apt install nodejs npm -y
apt install php -y
```

### ❓ File di Ubuntu disimpan di mana?
Di `/data/data/com.termux/files/home/ubuntu-fs/`
Tapi biasanya diakses dari Termux: `~/ubuntu-fs/root/`

### ❓ Bagaimana kalau HP restart?
Ubuntu tetap ada. Tinggal buka Termux lagi, lalu:
```bash
~/startubuntu.sh
```

### ❓ Apakah bisa install Ubuntu versi lain?
Bisa, tapi harus ubah script manual. Default: Ubuntu 22.04 (Jammy).

---

## 📞 Bantuan Lebih Lanjut

- **Termux Wiki:** https://wiki.termux.com
- **PRoot Docs:** https://proot-me.github.io
- **Buka Issue:** https://github.com/nezXproject/Ubuntu-Installer-Termux/issues

---

## ⚠️ Keterbatasan yang Perlu Diketahui

| Fitur | Bisa? | Catatan |
|-------|-------|---------|
| `apt install` | ✅ | Jalan normal |
| `systemctl` | ❌ | Ganti dengan `service xxx start` |
| Docker | ❌ | Butuh kernel feature |
| Kernel update | ❌ | Dikontrol Android |
| USB/GPU | ⚠️ | Terbatas / tidak jalan |
| Cron | ⚠️ | Terbatas |
| SSH server | ✅ | Jalan di port 2222 |

---

## 🎉 Selesai!

Kalau kamu berhasil sampai sini, berarti kamu sudah punya **Ubuntu di HP**! 🐧📱

Selamat belajar Linux! Kalau bingung, baca ulang dari atas, atau tanya di kolom Issues GitHub.

**Happy hacking!** 🚀
