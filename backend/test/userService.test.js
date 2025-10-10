const { register } = require('../services/userService');
const db = require('../config/db');
const bcrypt = require('bcrypt');

jest.mock('../config/db');
jest.mock('bcrypt');

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register user successfully', async () => {
      const mockHashedPassword = 'hashed_password';
      const mockInsertId = 1;
      bcrypt.hash.mockResolvedValue(mockHashedPassword);
      db.query.mockResolvedValue([{ insertId: mockInsertId }]);

      const result = await register('test@example.com', 'password123', 'Test User');

      expect(bcrypt.hash).toHaveBeenCalledWith('password123', 10);
      expect(db.query).toHaveBeenCalledWith(
        'INSERT INTO users (email, password, name) VALUES (?, ?, ?)',
        ['test@example.com', mockHashedPassword, 'Test User']
      );
      expect(result).toEqual({
        id: mockInsertId,
        email: 'test@example.com',
        name: 'Test User'
      });
    });

    it('should throw error for missing email', async () => {
      await expect(register('', 'password123', 'Test User')).rejects.toThrow('Email e senha são obrigatórios');
      expect(db.query).not.toHaveBeenCalled();
    });

    it('should throw error for missing password', async () => {
      await expect(register('test@example.com', '', 'Test User')).rejects.toThrow('Email e senha são obrigatórios');
      expect(db.query).not.toHaveBeenCalled();
    });

    it('should throw error for short password', async () => {
      await expect(register('test@example.com', '123', 'Test User')).rejects.toThrow('Senha deve ter pelo menos 6 caracteres');
      expect(db.query).not.toHaveBeenCalled();
    });

    it('should throw error for invalid email', async () => {
      await expect(register('invalid-email', 'password123', 'Test User')).rejects.toThrow('Email inválido');
      expect(db.query).not.toHaveBeenCalled();
    });

    it('should handle DB error', async () => {
      bcrypt.hash.mockResolvedValue('hashed');
      db.query.mockRejectedValue(new Error('DB error'));

      await expect(register('test@example.com', 'password123', 'Test User')).rejects.toThrow('DB error');
    });

    it('should register without name', async () => {
      const mockHashedPassword = 'hashed_password';
      const mockInsertId = 1;
      bcrypt.hash.mockResolvedValue(mockHashedPassword);
      db.query.mockResolvedValue([{ insertId: mockInsertId }]);

      const result = await register('test@example.com', 'password123', '');

      expect(db.query).toHaveBeenCalledWith(
        'INSERT INTO users (email, password) VALUES (?, ?)',
        ['test@example.com', mockHashedPassword]
      );
      expect(result.name).toBeNull();
    });
  });
});
