import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// The application title
  ///
  /// In id, this message translates to:
  /// **'Mudah Titip'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Kelola titipan jadi lebih mudah'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get address;

  /// No description provided for @welcomeBack.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang Kembali!'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan'**
  String get loginToContinue;

  /// No description provided for @noAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get forgotPassword;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar untuk memulai'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get fullName;

  /// No description provided for @shopName.
  ///
  /// In id, this message translates to:
  /// **'Nama Toko'**
  String get shopName;

  /// No description provided for @shopOwner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik Toko'**
  String get shopOwner;

  /// No description provided for @consignor.
  ///
  /// In id, this message translates to:
  /// **'Penitip'**
  String get consignor;

  /// No description provided for @selectRole.
  ///
  /// In id, this message translates to:
  /// **'Pilih Peran'**
  String get selectRole;

  /// No description provided for @dashboard.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get dashboard;

  /// No description provided for @products.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get products;

  /// No description provided for @consignments.
  ///
  /// In id, this message translates to:
  /// **'Titipan'**
  String get consignments;

  /// No description provided for @sales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get sales;

  /// No description provided for @analytics.
  ///
  /// In id, this message translates to:
  /// **'Analitik'**
  String get analytics;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @hello.
  ///
  /// In id, this message translates to:
  /// **'Halo'**
  String get hello;

  /// No description provided for @goodMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat Sore'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam'**
  String get goodNight;

  /// No description provided for @summary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get summary;

  /// No description provided for @attention.
  ///
  /// In id, this message translates to:
  /// **'Perhatian'**
  String get attention;

  /// No description provided for @totalProducts.
  ///
  /// In id, this message translates to:
  /// **'Total Produk'**
  String get totalProducts;

  /// No description provided for @totalSales.
  ///
  /// In id, this message translates to:
  /// **'Total Penjualan'**
  String get totalSales;

  /// No description provided for @totalEarnings.
  ///
  /// In id, this message translates to:
  /// **'Total Pendapatan'**
  String get totalEarnings;

  /// No description provided for @activeConsignments.
  ///
  /// In id, this message translates to:
  /// **'Titipan Aktif'**
  String get activeConsignments;

  /// No description provided for @pendingAgreements.
  ///
  /// In id, this message translates to:
  /// **'Kesepakatan Tertunda'**
  String get pendingAgreements;

  /// No description provided for @sold.
  ///
  /// In id, this message translates to:
  /// **'Terjual'**
  String get sold;

  /// No description provided for @soldItems.
  ///
  /// In id, this message translates to:
  /// **'Item Terjual'**
  String get soldItems;

  /// No description provided for @earnings.
  ///
  /// In id, this message translates to:
  /// **'Pendapatan'**
  String get earnings;

  /// No description provided for @lowStock.
  ///
  /// In id, this message translates to:
  /// **'Stok Rendah'**
  String get lowStock;

  /// No description provided for @quickActions.
  ///
  /// In id, this message translates to:
  /// **'Aksi Cepat'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get viewAll;

  /// No description provided for @viewSales.
  ///
  /// In id, this message translates to:
  /// **'Lihat Penjualan'**
  String get viewSales;

  /// No description provided for @recentActivity.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Terkini'**
  String get recentActivity;

  /// No description provided for @consign.
  ///
  /// In id, this message translates to:
  /// **'Titipkan'**
  String get consign;

  /// No description provided for @manageConsignors.
  ///
  /// In id, this message translates to:
  /// **'Kelola Penitip'**
  String get manageConsignors;

  /// No description provided for @addProduct.
  ///
  /// In id, this message translates to:
  /// **'Tambah Produk'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In id, this message translates to:
  /// **'Edit Produk'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In id, this message translates to:
  /// **'Nama Produk'**
  String get productName;

  /// No description provided for @productDescription.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi Produk'**
  String get productDescription;

  /// No description provided for @category.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @price.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get price;

  /// No description provided for @basePrice.
  ///
  /// In id, this message translates to:
  /// **'Harga Dasar'**
  String get basePrice;

  /// No description provided for @sellingPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga Jual'**
  String get sellingPrice;

  /// No description provided for @quantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get quantity;

  /// No description provided for @stock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get stock;

  /// No description provided for @totalStock.
  ///
  /// In id, this message translates to:
  /// **'Total Stok'**
  String get totalStock;

  /// No description provided for @shelfLife.
  ///
  /// In id, this message translates to:
  /// **'Masa Simpan (hari)'**
  String get shelfLife;

  /// No description provided for @noProducts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk'**
  String get noProducts;

  /// No description provided for @addFirstProduct.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan produk pertama Anda!'**
  String get addFirstProduct;

  /// No description provided for @ownerProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk Saya'**
  String get ownerProducts;

  /// No description provided for @guestProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk Titipan'**
  String get guestProducts;

  /// No description provided for @addConsignment.
  ///
  /// In id, this message translates to:
  /// **'Tambah Titipan'**
  String get addConsignment;

  /// No description provided for @shop.
  ///
  /// In id, this message translates to:
  /// **'Toko'**
  String get shop;

  /// No description provided for @product.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get product;

  /// No description provided for @startDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Mulai'**
  String get startDate;

  /// No description provided for @expiryDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Kadaluarsa'**
  String get expiryDate;

  /// No description provided for @commission.
  ///
  /// In id, this message translates to:
  /// **'Komisi'**
  String get commission;

  /// No description provided for @commissionPercent.
  ///
  /// In id, this message translates to:
  /// **'Persentase Komisi'**
  String get commissionPercent;

  /// No description provided for @notes.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get notes;

  /// No description provided for @noConsignments.
  ///
  /// In id, this message translates to:
  /// **'Belum ada titipan'**
  String get noConsignments;

  /// No description provided for @consignmentDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Titipan'**
  String get consignmentDetail;

  /// No description provided for @currentQuantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Saat Ini'**
  String get currentQuantity;

  /// No description provided for @initialQuantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Awal'**
  String get initialQuantity;

  /// No description provided for @expiringConsignments.
  ///
  /// In id, this message translates to:
  /// **'{count} titipan akan kedaluwarsa'**
  String expiringConsignments(int count);

  /// No description provided for @lowStockConsignments.
  ///
  /// In id, this message translates to:
  /// **'{count} stok titipan rendah'**
  String lowStockConsignments(int count);

  /// No description provided for @checkAndTakeAction.
  ///
  /// In id, this message translates to:
  /// **'Segera periksa dan ambil tindakan'**
  String get checkAndTakeAction;

  /// No description provided for @needRestockOrWithdraw.
  ///
  /// In id, this message translates to:
  /// **'Perlu restock atau tarik barang'**
  String get needRestockOrWithdraw;

  /// No description provided for @status.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get completed;

  /// No description provided for @expired.
  ///
  /// In id, this message translates to:
  /// **'Kadaluarsa'**
  String get expired;

  /// No description provided for @pending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get rejected;

  /// No description provided for @recordSale.
  ///
  /// In id, this message translates to:
  /// **'Catat Penjualan'**
  String get recordSale;

  /// No description provided for @quantitySold.
  ///
  /// In id, this message translates to:
  /// **'Jumlah Terjual'**
  String get quantitySold;

  /// No description provided for @totalAmount.
  ///
  /// In id, this message translates to:
  /// **'Total Jumlah'**
  String get totalAmount;

  /// No description provided for @shopCommission.
  ///
  /// In id, this message translates to:
  /// **'Komisi Toko'**
  String get shopCommission;

  /// No description provided for @consignorEarning.
  ///
  /// In id, this message translates to:
  /// **'Pendapatan Penitip'**
  String get consignorEarning;

  /// No description provided for @noSales.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penjualan'**
  String get noSales;

  /// No description provided for @saleRecorded.
  ///
  /// In id, this message translates to:
  /// **'Penjualan berhasil dicatat'**
  String get saleRecorded;

  /// No description provided for @salesDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Penjualan'**
  String get salesDetail;

  /// No description provided for @agreement.
  ///
  /// In id, this message translates to:
  /// **'Kesepakatan'**
  String get agreement;

  /// No description provided for @agreements.
  ///
  /// In id, this message translates to:
  /// **'Kesepakatan'**
  String get agreements;

  /// No description provided for @propose.
  ///
  /// In id, this message translates to:
  /// **'Ajukan'**
  String get propose;

  /// No description provided for @counter.
  ///
  /// In id, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @accept.
  ///
  /// In id, this message translates to:
  /// **'Terima'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get reject;

  /// No description provided for @terms.
  ///
  /// In id, this message translates to:
  /// **'Ketentuan'**
  String get terms;

  /// No description provided for @proposeAgreement.
  ///
  /// In id, this message translates to:
  /// **'Ajukan Kesepakatan'**
  String get proposeAgreement;

  /// No description provided for @noAgreements.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kesepakatan'**
  String get noAgreements;

  /// No description provided for @agreementDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Kesepakatan'**
  String get agreementDetail;

  /// No description provided for @guestConsignors.
  ///
  /// In id, this message translates to:
  /// **'Penitip Non-Akun'**
  String get guestConsignors;

  /// No description provided for @addGuestConsignor.
  ///
  /// In id, this message translates to:
  /// **'Tambah Penitip'**
  String get addGuestConsignor;

  /// No description provided for @guestConsignorName.
  ///
  /// In id, this message translates to:
  /// **'Nama Penitip'**
  String get guestConsignorName;

  /// No description provided for @noGuestConsignors.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penitip tamu'**
  String get noGuestConsignors;

  /// No description provided for @guestConsignorDetail.
  ///
  /// In id, this message translates to:
  /// **'Detail Penitip'**
  String get guestConsignorDetail;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Segarkan'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In id, this message translates to:
  /// **'Berhasil!'**
  String get success;

  /// No description provided for @submit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get submit;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Selanjutnya'**
  String get next;

  /// No description provided for @done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get done;

  /// No description provided for @selectDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih Tanggal'**
  String get selectDate;

  /// No description provided for @selectShop.
  ///
  /// In id, this message translates to:
  /// **'Pilih Toko'**
  String get selectShop;

  /// No description provided for @selectProduct.
  ///
  /// In id, this message translates to:
  /// **'Pilih Produk'**
  String get selectProduct;

  /// No description provided for @selectConsignment.
  ///
  /// In id, this message translates to:
  /// **'Pilih Titipan'**
  String get selectConsignment;

  /// No description provided for @required.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Email tidak valid'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok'**
  String get passwordsDoNotMatch;

  /// No description provided for @enterEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email anda'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In id, this message translates to:
  /// **'Masukkan password'**
  String get enterPassword;

  /// No description provided for @emailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password wajib diisi'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get nameRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In id, this message translates to:
  /// **'Field ini wajib diisi'**
  String get fieldRequired;

  /// No description provided for @profileInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Profil'**
  String get profileInfo;

  /// No description provided for @accountInfo.
  ///
  /// In id, this message translates to:
  /// **'Informasi Akun'**
  String get accountInfo;

  /// No description provided for @security.
  ///
  /// In id, this message translates to:
  /// **'Keamanan'**
  String get security;

  /// No description provided for @accountType.
  ///
  /// In id, this message translates to:
  /// **'Tipe Akun'**
  String get accountType;

  /// No description provided for @joinedDate.
  ///
  /// In id, this message translates to:
  /// **'Bergabung'**
  String get joinedDate;

  /// No description provided for @updateProfile.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Profil'**
  String get updateProfile;

  /// No description provided for @changePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah Kata Sandi'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Saat Ini'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In id, this message translates to:
  /// **'Password Baru'**
  String get newPassword;

  /// No description provided for @newEmail.
  ///
  /// In id, this message translates to:
  /// **'Email Baru'**
  String get newEmail;

  /// No description provided for @minCharacters.
  ///
  /// In id, this message translates to:
  /// **'Minimal {count} karakter'**
  String minCharacters(int count);

  /// No description provided for @passwordConfirmNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password tidak cocok'**
  String get passwordConfirmNoMatch;

  /// No description provided for @fillAllFields.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi semua field'**
  String get fillAllFields;

  /// No description provided for @fillEmailAndPassword.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi email dan password'**
  String get fillEmailAndPassword;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu Ini'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan Ini'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun Ini'**
  String get thisYear;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @rupiah.
  ///
  /// In id, this message translates to:
  /// **'Rp{amount}'**
  String rupiah(String amount);

  /// No description provided for @itemCount.
  ///
  /// In id, this message translates to:
  /// **'{count} item'**
  String itemCount(int count);

  /// No description provided for @greeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}!'**
  String greeting(String name);

  /// No description provided for @confirmDelete.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menghapus ini?'**
  String get confirmDelete;

  /// No description provided for @confirmLogout.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar?'**
  String get confirmLogout;

  /// No description provided for @yes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get no;

  /// No description provided for @salesTrend.
  ///
  /// In id, this message translates to:
  /// **'Tren Penjualan'**
  String get salesTrend;

  /// No description provided for @topProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk Terlaris'**
  String get topProducts;

  /// No description provided for @earningsBreakdown.
  ///
  /// In id, this message translates to:
  /// **'Rincian Pendapatan'**
  String get earningsBreakdown;

  /// No description provided for @units.
  ///
  /// In id, this message translates to:
  /// **'unit'**
  String get units;

  /// No description provided for @noAnalyticsData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data analitik'**
  String get noAnalyticsData;

  /// No description provided for @notFilled.
  ///
  /// In id, this message translates to:
  /// **'Belum diisi'**
  String get notFilled;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @indonesian.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In id, this message translates to:
  /// **'Inggris'**
  String get english;

  /// No description provided for @selectLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
