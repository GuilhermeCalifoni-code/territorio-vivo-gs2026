/// Redação simples de identificadores estruturados no campo de texto livre.
/// Não equivale a anonimização garantida: nomes e descrições contextuais
/// ainda podem reidentificar pessoas. Por isso relatos não são transmitidos.
class PrivacySanitizer {
  static String redact(String input) {
    var text = input.trim();
    text = text.replaceAll(
      RegExp(r'[\w.+\-]+@[\w.\-]+\.[A-Za-z]{2,}'),
      '[e-mail removido]',
    );
    text = text.replaceAll(
      RegExp(r'\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b'),
      '[CPF removido]',
    );
    text = text.replaceAll(
      RegExp(r'\b(?:\(?\d{2}\)?[\s\-]?)9?\d{4}[\s\-]?\d{4}\b'),
      '[telefone removido]',
    );
    return text;
  }
}
