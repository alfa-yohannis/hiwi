# CLI-REGISTER

**Project:** Queue Management System (CLI)  
**Author:** [Nama Kamu]  
**Description:** Clients can register for a queue using a queue ID or barcode scan.

---

## Fitur

1. **Register Client**  
   - Masukkan nama client.  
   - Masukkan Queue ID atau scan barcode (scanner akan otomatis mengisi field Queue ID).  
   - Data akan tersimpan ke database PostgreSQL.

2. **Show All Clients**  
   - Menampilkan daftar semua client yang sudah terdaftar beserta Queue ID.

3. **Exit**  
   - Keluar dari aplikasi CLI.

---

## Cara Menjalankan

1. Pastikan PostgreSQL sudah berjalan dan database `cli_register_dev` sudah dibuat.
2. Masuk ke direktori project:
   ```bash
   cd C:\tugas cli_register\cli_register

