// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Mudah Titip';

  @override
  String get appTagline => 'Kelola titipan jadi lebih mudah';

  @override
  String get login => 'Masuk';

  @override
  String get register => 'Daftar';

  @override
  String get logout => 'Keluar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get name => 'Nama';

  @override
  String get phone => 'Telepon';

  @override
  String get address => 'Alamat';

  @override
  String get welcomeBack => 'Selamat Datang Kembali!';

  @override
  String get loginToContinue => 'Masuk untuk melanjutkan';

  @override
  String get noAccount => 'Belum punya akun?';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun?';

  @override
  String get forgotPassword => 'Lupa kata sandi?';

  @override
  String get registerTitle => 'Buat Akun';

  @override
  String get registerSubtitle => 'Daftar untuk memulai';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get shopName => 'Nama Toko';

  @override
  String get shopOwner => 'Pemilik Toko';

  @override
  String get consignor => 'Penitip';

  @override
  String get selectRole => 'Pilih Peran';

  @override
  String get dashboard => 'Beranda';

  @override
  String get products => 'Produk';

  @override
  String get consignments => 'Titipan';

  @override
  String get sales => 'Penjualan';

  @override
  String get analytics => 'Analitik';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Pengaturan';

  @override
  String get hello => 'Halo';

  @override
  String get goodMorning => 'Selamat Pagi';

  @override
  String get goodAfternoon => 'Selamat Siang';

  @override
  String get goodEvening => 'Selamat Sore';

  @override
  String get goodNight => 'Selamat Malam';

  @override
  String get summary => 'Ringkasan';

  @override
  String get attention => 'Perhatian';

  @override
  String get totalProducts => 'Total Produk';

  @override
  String get totalSales => 'Total Penjualan';

  @override
  String get totalEarnings => 'Total Pendapatan';

  @override
  String get activeConsignments => 'Titipan Aktif';

  @override
  String get pendingAgreements => 'Kesepakatan Tertunda';

  @override
  String get sold => 'Terjual';

  @override
  String get soldItems => 'Item Terjual';

  @override
  String get earnings => 'Pendapatan';

  @override
  String get lowStock => 'Stok Rendah';

  @override
  String get quickActions => 'Aksi Cepat';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get viewSales => 'Lihat Penjualan';

  @override
  String get recentActivity => 'Aktivitas Terkini';

  @override
  String get consign => 'Titipkan';

  @override
  String get manageConsignors => 'Kelola Penitip';

  @override
  String get addProduct => 'Tambah Produk';

  @override
  String get editProduct => 'Edit Produk';

  @override
  String get productName => 'Nama Produk';

  @override
  String get productDescription => 'Deskripsi Produk';

  @override
  String get category => 'Kategori';

  @override
  String get price => 'Harga';

  @override
  String get basePrice => 'Harga Dasar';

  @override
  String get sellingPrice => 'Harga Jual';

  @override
  String get quantity => 'Jumlah';

  @override
  String get shelfLife => 'Masa Simpan (hari)';

  @override
  String get noProducts => 'Belum ada produk';

  @override
  String get addFirstProduct => 'Tambahkan produk pertama Anda!';

  @override
  String get ownerProducts => 'Produk Saya';

  @override
  String get guestProducts => 'Produk Titipan';

  @override
  String get addConsignment => 'Tambah Titipan';

  @override
  String get shop => 'Toko';

  @override
  String get product => 'Produk';

  @override
  String get startDate => 'Tanggal Mulai';

  @override
  String get expiryDate => 'Tanggal Kadaluarsa';

  @override
  String get commission => 'Komisi';

  @override
  String get commissionPercent => 'Persentase Komisi';

  @override
  String get notes => 'Catatan';

  @override
  String get noConsignments => 'Belum ada titipan';

  @override
  String get consignmentDetail => 'Detail Titipan';

  @override
  String get currentQuantity => 'Jumlah Saat Ini';

  @override
  String get initialQuantity => 'Jumlah Awal';

  @override
  String expiringConsignments(int count) {
    return '$count titipan akan kedaluwarsa';
  }

  @override
  String lowStockConsignments(int count) {
    return '$count stok titipan rendah';
  }

  @override
  String get checkAndTakeAction => 'Segera periksa dan ambil tindakan';

  @override
  String get needRestockOrWithdraw => 'Perlu restock atau tarik barang';

  @override
  String get status => 'Status';

  @override
  String get active => 'Aktif';

  @override
  String get completed => 'Selesai';

  @override
  String get expired => 'Kadaluarsa';

  @override
  String get pending => 'Menunggu';

  @override
  String get accepted => 'Diterima';

  @override
  String get rejected => 'Ditolak';

  @override
  String get recordSale => 'Catat Penjualan';

  @override
  String get quantitySold => 'Jumlah Terjual';

  @override
  String get totalAmount => 'Total Jumlah';

  @override
  String get shopCommission => 'Komisi Toko';

  @override
  String get consignorEarning => 'Pendapatan Penitip';

  @override
  String get noSales => 'Belum ada penjualan';

  @override
  String get saleRecorded => 'Penjualan berhasil dicatat';

  @override
  String get salesDetail => 'Detail Penjualan';

  @override
  String get agreement => 'Kesepakatan';

  @override
  String get agreements => 'Kesepakatan';

  @override
  String get propose => 'Ajukan';

  @override
  String get counter => 'Counter';

  @override
  String get accept => 'Terima';

  @override
  String get reject => 'Tolak';

  @override
  String get terms => 'Ketentuan';

  @override
  String get proposeAgreement => 'Ajukan Kesepakatan';

  @override
  String get noAgreements => 'Belum ada kesepakatan';

  @override
  String get agreementDetail => 'Detail Kesepakatan';

  @override
  String get guestConsignors => 'Penitip Non-Akun';

  @override
  String get addGuestConsignor => 'Tambah Penitip';

  @override
  String get guestConsignorName => 'Nama Penitip';

  @override
  String get noGuestConsignors => 'Belum ada penitip tamu';

  @override
  String get guestConsignorDetail => 'Detail Penitip';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Cari';

  @override
  String get filter => 'Filter';

  @override
  String get refresh => 'Segarkan';

  @override
  String get loading => 'Memuat...';

  @override
  String get noData => 'Tidak ada data';

  @override
  String get error => 'Terjadi kesalahan';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get success => 'Berhasil!';

  @override
  String get submit => 'Kirim';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get next => 'Selanjutnya';

  @override
  String get done => 'Selesai';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String get selectShop => 'Pilih Toko';

  @override
  String get selectProduct => 'Pilih Produk';

  @override
  String get selectConsignment => 'Pilih Titipan';

  @override
  String get required => 'Wajib diisi';

  @override
  String get invalidEmail => 'Email tidak valid';

  @override
  String get passwordTooShort => 'Kata sandi minimal 6 karakter';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get enterEmail => 'Masukkan email anda';

  @override
  String get enterPassword => 'Masukkan password';

  @override
  String get emailRequired => 'Email wajib diisi';

  @override
  String get passwordRequired => 'Password wajib diisi';

  @override
  String get nameRequired => 'Nama wajib diisi';

  @override
  String get fieldRequired => 'Field ini wajib diisi';

  @override
  String get profileInfo => 'Informasi Profil';

  @override
  String get accountInfo => 'Informasi Akun';

  @override
  String get security => 'Keamanan';

  @override
  String get accountType => 'Tipe Akun';

  @override
  String get joinedDate => 'Bergabung';

  @override
  String get updateProfile => 'Perbarui Profil';

  @override
  String get changePassword => 'Ubah Kata Sandi';

  @override
  String get currentPassword => 'Password Saat Ini';

  @override
  String get newPassword => 'Password Baru';

  @override
  String get newEmail => 'Email Baru';

  @override
  String minCharacters(int count) {
    return 'Minimal $count karakter';
  }

  @override
  String get passwordConfirmNoMatch => 'Konfirmasi password tidak cocok';

  @override
  String get fillAllFields => 'Lengkapi semua field';

  @override
  String get fillEmailAndPassword => 'Lengkapi email dan password';

  @override
  String get today => 'Hari Ini';

  @override
  String get thisWeek => 'Minggu Ini';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get thisYear => 'Tahun Ini';

  @override
  String get all => 'Semua';

  @override
  String rupiah(String amount) {
    return 'Rp$amount';
  }

  @override
  String itemCount(int count) {
    return '$count item';
  }

  @override
  String greeting(String name) {
    return 'Halo, $name!';
  }

  @override
  String get confirmDelete => 'Apakah Anda yakin ingin menghapus ini?';

  @override
  String get confirmLogout => 'Apakah Anda yakin ingin keluar?';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get salesTrend => 'Tren Penjualan';

  @override
  String get topProducts => 'Produk Terlaris';

  @override
  String get earningsBreakdown => 'Rincian Pendapatan';

  @override
  String get units => 'unit';

  @override
  String get noAnalyticsData => 'Belum ada data analitik';

  @override
  String get notFilled => 'Belum diisi';

  @override
  String get language => 'Bahasa';

  @override
  String get indonesian => 'Indonesia';

  @override
  String get english => 'Inggris';

  @override
  String get selectLanguage => 'Pilih Bahasa';
}
