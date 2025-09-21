# Aplication
Projeto Flutter + Node.js configurando ambiente inicial.
Descripiton...

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