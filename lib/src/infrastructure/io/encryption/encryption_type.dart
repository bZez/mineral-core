enum EncryptionType {
  aeadAes256GcmRtpsize('aead_aes256_gcm_rtpsize'),
  aeadXchacha20Poly1305Rtpsize('aead_xchacha20_poly1305_rtpsize	'),
  none('none');

  final String value;
  const EncryptionType(this.value);
}