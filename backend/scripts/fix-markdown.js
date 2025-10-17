const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Função para encontrar todos os arquivos .md no projeto
function findMarkdownFiles(dir, files = []) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
      findMarkdownFiles(fullPath, files);
    } else if (item.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  return files;
}

// Função para encontrar arquivos .md no diretório pai (raiz do projeto)
function findMarkdownFilesInParent(dir, files = []) {
  const parentDir = path.resolve(dir, '..');
  const items = fs.readdirSync(parentDir);
  for (const item of items) {
    const fullPath = path.join(parentDir, item);
    const stat = fs.statSync(fullPath);
    if (stat.isFile() && item.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  return files;
}

// Função principal
function fixMarkdown() {
  try {
    console.log('Procurando arquivos Markdown...');
    const markdownFiles = findMarkdownFiles(process.cwd());
    const parentMarkdownFiles = findMarkdownFilesInParent(process.cwd());
    const allMarkdownFiles = [...markdownFiles, ...parentMarkdownFiles];
    console.log(`Encontrados ${allMarkdownFiles.length} arquivos .md`);

    if (allMarkdownFiles.length === 0) {
      console.log('Nenhum arquivo .md encontrado.');
      return;
    }

    console.log('Executando Prettier nos arquivos Markdown...');
    // Executa o Prettier em todos os arquivos .md encontrados
    execSync(`npx prettier --write ${allMarkdownFiles.join(' ')}`, { stdio: 'inherit' });

    console.log('Executando Markdownlint para correções específicas...');
    // Executa o Markdownlint para corrigir regras específicas
    execSync(`npx markdownlint --fix ${allMarkdownFiles.join(' ')}`, { stdio: 'inherit' });

    console.log('Correção automática de Markdown concluída com sucesso!');
  } catch (error) {
    console.error('Erro ao corrigir arquivos Markdown:', error.message);
    process.exit(1);
  }
}

// Executa a função se o script for chamado diretamente
if (require.main === module) {
  fixMarkdown();
}

module.exports = { fixMarkdown };
