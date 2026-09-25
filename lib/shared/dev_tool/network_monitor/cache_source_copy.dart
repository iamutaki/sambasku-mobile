/// Copy awam untuk badge [NetworkRequestRecord.cacheSource].
String cacheSourcePlainExplanation(String source) {
  switch (source) {
    case 'HIT':
      return 'Data masih segar di HP. Langsung ditampilkan dari '
          'simpanan lokal; tidak minta ke server.';
    case 'STALE':
      return 'Data di HP sudah agak usang, tapi tetap ditampilkan dulu '
          'agar cepat. Di belakang layar app mencoba ambil yang lebih '
          'baru dari server (biasanya muncul sebagai request biasa).';
    case 'DEGRADED':
      return 'Gagal ambil dari server (jaringan putus / error). '
          'App memakai data lama yang masih ada di HP supaya layar '
          'tidak kosong.';
    default:
      return 'Ditampilkan dari cache lokal.';
  }
}
