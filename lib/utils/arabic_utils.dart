const _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabicNumerals(int number) {
  return number
      .toString()
      .split('')
      .map((d) => _arabicIndicDigits[int.parse(d)])
      .join();
}

String truncateArabic(String text, {int maxLength = 80}) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}…';
}
