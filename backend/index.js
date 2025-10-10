const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Rotas
const userRoutes = require('./routes/userRoutes');
const loginRoutes = require('./routes/loginRoutes'); // <-- importando login
const profileRoutes = require('./routes/profileRoutes');
const contentRoutes = require('./routes/contentRoutes');
const communityRoutes = require('./routes/communityRoutes');

app.use('/api/users', userRoutes);
app.use('/api/login', loginRoutes); // <-- adicionando rota de login
app.use('/api/profiles', profileRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/community', communityRoutes);

console.log("Rotas carregadas:");
console.log("userRoutes importado:", userRoutes);
console.log("loginRoutes importado:", loginRoutes);
console.log("profileRoutes importado:", profileRoutes);
console.log("contentRoutes importado:", contentRoutes);
console.log("communityRoutes importado:", communityRoutes);

// Rota de teste simples
app.get('/ping', (req, res) => res.json({ message: 'pong' }));

// Inicializar servidor
app.listen(3000, () => console.log("Servirdor: http://localhost:3000 \nUserRoutes: http://localhost:3000/api/users \nLoginRoutes: http://localhost:3000/api/login"));
