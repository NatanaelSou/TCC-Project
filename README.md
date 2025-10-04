# Aplication

Projeto Flutter + Node.js configurando ambiente inicial.
Descripiton...

Projeto Premiora

1. O que é o Premiora
O Premiora é uma plataforma feita para juntar em um só lugar o que hoje os criadores precisam separar: a exposição do conteúdo e a comunidade em torno dele.
Hoje, influencers e criadores usam redes como Instagram para aparecer no algoritmo e precisam direcionar sua comunidade para outros espaços, como WhatsApp ou Telegram. O Premiora resolve isso: dá ao criador um ambiente único para divulgar, interagir e monetizar seu trabalho.

2. Como funciona a criação de conteúdo
O Premiora não se limita a um formato só. A ideia é que o criador tenha liberdade total para produzir e compartilhar:
Vídeos (editados ou brutos), Live streaming para interações em tempo real, Podcasts e áudios exclusivos, Posts e publicações (memes, textos, reflexões, bastidores etc.), Cursos e materiais educativos, Qualquer outro tipo de mídia que ele queira experimentar. Tudo isso pode ser organizado dentro da própria plataforma, sem depender de outros apps.

3. Monetização e assinaturas

Criadores podem disponibilizar conteúdos pagos além dos gratuitos.

O sistema de assinatura é mensal, com diferentes níveis (tiers) que o criador pode configurar.

Cada tier pode ter benefícios específicos: acesso a canais privados, conteúdos exclusivos, bastidores, interação direta, entre outros.

O preço é flexível: cada criador decide quanto cobrar em cada nível de assinatura.
4. Comunidade dentro da plataforma

Mais do que uma vitrine de conteúdos, o Premiora é também um espaço de comunidade.

Criadores podem abrir canais e chats para falar diretamente com seu público.

Esses espaços podem ser livres ou restritos a assinantes de determinados tiers.

Os criadores podem ter moderadores para ajudar na organização.

A comunidade vira parte do conteúdo, fortalecendo o vínculo entre criador e público.
5. Para o usuário

Todo criador precisa oferecer um conteúdo mínimo gratuito, que funciona como porta de entrada.

Usuários podem acompanhar de graça, mas também têm a opção de apoiar e ter acesso a mais através da assinatura mensal.

A experiência é completa: o usuário assiste, interage e participa da comunidade sem precisar sair da plataforma.
6. Para o criador

Total autonomia para decidir o que postar, como postar e quanto cobrar.

Um único espaço para cuidar de conteúdo e comunidade.

Ferramentas que equilibram alcance gratuito (para atrair mais público) e conteúdo exclusivo pago (para rentabilizar).

Menos dependência de algoritmos externos e múltiplos aplicativos.

Resumindo: Premiora seria como um híbrido entre Patreon, Discord, Twitch e Instagram, mas com o diferencial de unir conteúdo + comunidade + monetização flexível em uma única plataforma.

## MVP

Objetivo do MVP
Criar uma versão mínima funcional com:

- **Cadastro e login de usuários** (criadores e espectadores).
- **Publicação de conteúdo básico** (posts de texto/imagem).
- **Assinaturas mensais** com tiers simulados.
- **Comunidade inicial** (chat/mural).

## Estrutura do projeto

```shell
APP/ # Flutter App
- backend/ # Node.js
  - config/
  - controllers/
  - models/
  - routes/
  - index.js # servidor
  - package.json
- assets/
- lib/ # Front-End
  - models/
  - screens/
  - services/
    - api_service.dart # comunicação com backend
  - widgets/
  - main.dart
```

## Como rodar

### Backend (Node.js)

No terminal 1 inicilize e execute o Node.JS

```bash
cd backend
npm install
node index.js
Servidor rodando em: http://localhost:3000
```

### Frontend (Flutter)

No terminal 2 inicialize

```bash
flutter pub get
flutter run           # para mobile
flutter run -d chrome # para web
# selecione modo ( escolha o chrome caso nao tenha um emulator )
# Outras saidas.. Se Saida -> 
{ "message": "pong" } # Saida: API mínima: /ping retorna 
# Conexao Node.JS normal
```

### Database Setup (MySQL)

O banco de dados `tcc_project` já existe. Para configurar o acesso:

1. Instale o MySQL Server se não tiver.

2. Configure as credenciais no backend/config/db.js (atualmente: host: 'localhost', user: 'root', password: '512200Balatro@', database: 'tcc_project').

3. Execute o schema para criar a tabela users (se necessário):

   ```sql
   -- backend/database/schema.sql
   CREATE TABLE IF NOT EXISTS users (
       id INT AUTO_INCREMENT PRIMARY KEY,
       email VARCHAR(255) NOT NULL UNIQUE,
       password VARCHAR(255) NOT NULL,
       name VARCHAR(100)
   );

   -- Usuário de teste (senha: 123456)
   INSERT INTO users (email, password, name) VALUES ('teste@teste.com', '123456', 'Usuário Teste')
       ON DUPLICATE KEY UPDATE email=email;
   ```

   Use um cliente MySQL (como MySQL Workbench) para executar o schema.sql se a tabela não existir.

   **Acesso ao BD:**
   - Host: localhost
   - Port: 3306 (padrão)
   - User: root
   - Password: 512200Balatro@
   - Database: tcc_project

   Nota: Em produção, use credenciais seguras e variáveis de ambiente (.env).
