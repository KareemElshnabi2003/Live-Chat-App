String decodeHtmlEntities(String? text) {
  if (text == null || text.isEmpty || !text.contains('&')) {
    return text ?? '';
  }

  var decoded = text
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#039;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&copy;', '©')
      .replaceAll('&reg;', '®')
      .replaceAll('&trade;', '™');

  // Decimal entities like &#160;
  decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    try {
      final code = int.parse(match.group(1)!);
      return String.fromCharCode(code);
    } catch (_) {
      return match.group(0)!;
    }
  });

  // Hex entities like &#x2F;
  decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
    try {
      final code = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(code);
    } catch (_) {
      return match.group(0)!;
    }
  });

  // Decode &amp; last so we don't prematurely decode escaped entities like &amp;#039;
  decoded = decoded.replaceAll('&amp;', '&');

  return decoded;
}
