# Firebase Measurement mereferensi AdvertisingIdClient, tapi modul
# play-services-ads-identifier dikeluarkan dari classpath karena app
# tidak mengumpulkan advertising ID (deklarasi Play = No).
-dontwarn com.google.android.gms.ads.identifier.AdvertisingIdClient
-dontwarn com.google.android.gms.ads.identifier.AdvertisingIdClient$Info
