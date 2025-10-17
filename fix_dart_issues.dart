import 'dart:io';
import 'package:path/path.dart' as path;

/// Script para corrigir automaticamente problemas comuns no código Dart
/// Corrige depreciações, contextos assíncronos e construtores const
void main() async {
  // Diretório raiz do projeto
  final projectRoot = Directory.current.path;

  // Diretório lib onde estão os arquivos Dart
  final libDir = Directory(path.join(projectRoot, 'lib'));

  if (!libDir.existsSync()) {
    print('Diretório lib não encontrado. Certifique-se de executar no diretório raiz do projeto Flutter.');
    return;
  }

  print('Iniciando correção automática de problemas Dart...');

  // Encontra todos os arquivos .dart no diretório lib
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  int filesFixed = 0;

  for (final file in dartFiles) {
    final originalContent = file.readAsStringSync();
    String fixedContent = originalContent;

    // Correção 1: Substituir withOpacity por withValues (depreciado)
    fixedContent = _fixWithOpacity(fixedContent);

    // Correção 2: Adicionar const aos construtores em classes @immutable
    fixedContent = _fixConstConstructors(fixedContent);

    // Correção 3: Tentar corrigir uso de BuildContext através de async gaps (básico)
    fixedContent = _fixBuildContextAsyncGaps(fixedContent);

    // Se o conteúdo foi alterado, salva o arquivo
    if (fixedContent != originalContent) {
      file.writeAsStringSync(fixedContent);
      print('Corrigido: ${file.path}');
      filesFixed++;
    }
  }

  print('Correção concluída. Arquivos corrigidos: $filesFixed');
}

/// Corrige o uso de withOpacity depreciado substituindo por withValues
String _fixWithOpacity(String content) {
  // Regex para encontrar .withOpacity( seguido por um número
  final regex = RegExp(r'\.withOpacity\s*\(\s*([0-9]*\.?[0-9]+)\s*\)');
  return content.replaceAllMapped(regex, (match) {
    final opacity = match.group(1);
    return '.withValues(alpha: $opacity)';
  });
}

/// Adiciona const aos construtores de classes marcadas com @immutable
String _fixConstConstructors(String content) {
  // Divide o conteúdo em linhas para processamento
  final lines = content.split('\n');
  final fixedLines = <String>[];

  bool inImmutableClass = false;

  for (final line in lines) {
    // Verifica se estamos dentro de uma classe @immutable
    if (line.contains('@immutable')) {
      inImmutableClass = true;
    } else if (line.contains('class ') && line.contains('{')) {
      // Nova classe, reseta o flag
      inImmutableClass = false;
    }

    // Se estamos em uma classe @immutable e a linha é um construtor sem const
    if (inImmutableClass &&
        RegExp(r'^\s*[A-Za-z_][A-Za-z0-9_]*\s*\(').hasMatch(line) &&
        !line.contains('const ') &&
        !line.contains('factory ') &&
        !line.contains('static ')) {
      // Adiciona const antes do construtor
      final leadingSpaces = RegExp(r'^\s*').firstMatch(line)?.group(0) ?? '';
      fixedLines.add('$leadingSpaces const ${line.trimLeft()}');
    } else {
      fixedLines.add(line);
    }
  }

  return fixedLines.join('\n');
}

/// Tenta corrigir uso de BuildContext através de async gaps (correção básica)
/// Nota: Esta é uma correção simplista. Para correções mais precisas, considere usar ferramentas como dart fix.
String _fixBuildContextAsyncGaps(String content) {
  // Esta correção é limitada. Adiciona comentários de aviso onde BuildContext pode ser usado incorretamente
  // Para correções automáticas completas, seria necessário análise AST mais avançada

  final lines = content.split('\n');
  final fixedLines = <String>[];

  for (final line in lines) {
    fixedLines.add(line);

    // Se a linha contém await e a próxima linha usa context, adiciona comentário
    if (line.contains('await ') && !line.contains('//')) {
      fixedLines.add('    // AVISO: Verifique se o uso de BuildContext após await é seguro');
    }
  }

  return fixedLines.join('\n');
}
