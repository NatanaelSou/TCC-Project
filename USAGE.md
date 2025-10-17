# Guia de Uso do Projeto Premiora

Este documento explica como usar o Projeto Premiora após a instalação e configuração.

## Visão Geral

O Premiora é uma plataforma que permite aos criadores:

- Publicar conteúdo (posts, vídeos, áudios, cursos)
- Construir comunidades através de chats e murais
- Monetizar via assinaturas mensais com tiers

## Primeiros Passos

### 1. Iniciar o Sistema

```bash
# Terminal 1: Backend
cd backend
npm start

# Terminal 2: Frontend
flutter run -d chrome  # ou dispositivo mobile
```

### 2. Acessar a Aplicação

- Abra `http://localhost:3000` no navegador (se web)
- Ou use o app mobile

## Funcionalidades Principais

### Cadastro e Login

1. **Criar Conta**:
   - Acesse a tela de registro
   - Preencha: nome, email, senha
   - Escolha se é criador ou espectador

2. **Fazer Login**:
   - Use email e senha cadastrados
   - Sistema redireciona baseado no tipo de usuário

### Para Criadores

#### Publicar Conteúdo

1. **Criar Post**:
   - Vá para "Novo Post"
   - Escolha tipo: texto, imagem, vídeo
   - Adicione título e conteúdo
   - Selecione visibilidade: público ou pago

2. **Gerenciar Assinaturas**:
   - Configure tiers (níveis) de assinatura
   - Defina preços mensais
   - Especifique benefícios por tier

#### Gerenciar Comunidade

1. **Criar Canais**:
   - Chat: para conversas em tempo real
   - Mural: para posts e discussões

2. **Moderar**:
   - Adicione moderadores
   - Configure regras por canal
   - Monitore atividade

### Para Espectadores

#### Explorar Conteúdo

1. **Navegar**:
   - Veja posts públicos dos criadores
   - Use filtros por categoria/tipo

2. **Assinar**:
   - Escolha tier desejado
   - Pague mensalmente
   - Acesse conteúdo exclusivo

#### Participar da Comunidade

1. **Chats**:
   - Entre em canais públicos
   - Converse com outros espectadores

2. **Murais**:
   - Leia posts da comunidade
   - Comente e interaja

## Exemplos de Uso

### Exemplo 1: Criador Publicando Vídeo

```dart
// Código simplificado no Flutter
void publicarVideo() {
  // Selecionar arquivo de vídeo
  File video = await pickVideo();

  // Criar post
  Post novoPost = Post(
    titulo: "Tutorial de Flutter",
    tipo: TipoPost.video,
    arquivo: video,
    visibilidade: Visibilidade.pago, // Apenas assinantes
    tierMinimo: 2
  );

  // Enviar para API
  await apiService.criarPost(novoPost);
}
```

### Exemplo 2: Espectador Assinando

```dart
// Ver tiers disponíveis
List<Tier> tiers = await apiService.getTiers(criadorId);

// Escolher tier
Tier tierEscolhido = tiers.firstWhere((tier) => tier.nivel == 1);

// Assinar
await apiService.assinarTier(tierEscolhido.id);
```

### Exemplo 3: Enviando Mensagem no Chat

```dart
// Entrar no canal
Canal canal = await apiService.getCanal(canalId);

// Enviar mensagem
Mensagem msg = Mensagem(
  texto: "Olá comunidade!",
  canalId: canal.id,
  usuarioId: usuarioLogado.id
);

await apiService.enviarMensagem(msg);
```

## API Endpoints

### Autenticação

- `POST /api/auth/register` - Registrar usuário
- `POST /api/auth/login` - Fazer login
- `POST /api/auth/logout` - Fazer logout

### Conteúdo

- `GET /api/posts` - Listar posts públicos
- `POST /api/posts` - Criar post
- `GET /api/posts/:id` - Ver post específico
- `PUT /api/posts/:id` - Editar post
- `DELETE /api/posts/:id` - Deletar post

### Comunidade

- `GET /api/canais` - Listar canais
- `POST /api/canais` - Criar canal
- `GET /api/canais/:id/mensagens` - Mensagens do chat
- `POST /api/canais/:id/mensagens` - Enviar mensagem
- `GET /api/canais/:id/posts` - Posts do mural
- `POST /api/canais/:id/posts` - Criar post no mural

### Assinaturas

- `GET /api/tiers` - Ver tiers disponíveis
- `POST /api/assinaturas` - Assinar tier
- `DELETE /api/assinaturas/:id` - Cancelar assinatura

## Configurações Avançadas

### Personalização do Perfil

- Foto de perfil
- Biografia
- Links sociais
- Configurações de privacidade

### Notificações

- Push notifications para novos posts
- Alertas de mensagens
- Lembretes de pagamento

### Temas

- Modo escuro/claro
- Cores personalizadas (para criadores premium)

## Suporte e Ajuda

- **Documentação**: Consulte outros arquivos .md na raiz
- **Issues**: Relate bugs no GitHub
- **Comunidade**: Use os canais do Discord/Slack do projeto
- **FAQ**: Veja [FAQ.md](FAQ.md) para dúvidas comuns

## Limitações da Versão Atual

- Upload de arquivos limitado a 100MB
- Máximo 10 tiers por criador
- Sem analytics avançados
- Suporte limitado a idiomas

Para recursos avançados, consulte o [ROADMAP.md](ROADMAP.md).
