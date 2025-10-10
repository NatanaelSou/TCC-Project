const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  // Modelo para canais de comunidade
  const Channel = sequelize.define('Channel', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    creatorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id',
      },
    },
    name: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    type: {
      type: DataTypes.ENUM('chat', 'mural'),
      allowNull: false,
    },
    isPrivate: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    tierRequired: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'SupportTiers',
        key: 'id',
      },
    },
    members: {
      type: DataTypes.JSON,
      defaultValue: [],
    },
  });

  // Modelo para mensagens de chat
  const Message = sequelize.define('Message', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    senderId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id',
      },
    },
    channelId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Channels',
        key: 'id',
      },
    },
    text: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    timestamp: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    isPrivate: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    tierRequired: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'SupportTiers',
        key: 'id',
      },
    },
  });

  // Modelo para posts de mural
  const MuralPost = sequelize.define('MuralPost', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    creatorId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id',
      },
    },
    channelId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'Channels',
        key: 'id',
      },
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    images: {
      type: DataTypes.JSON,
      allowNull: true,
    },
    parentId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'MuralPosts',
        key: 'id',
      },
    },
    createdAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    likes: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    replies: {
      type: DataTypes.JSON,
      defaultValue: [],
    },
    isPrivate: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    tierRequired: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'SupportTiers',
        key: 'id',
      },
    },
  });

  // Associações
  Channel.associate = (models) => {
    Channel.belongsTo(models.User, { foreignKey: 'creatorId', as: 'creator' });
    Channel.hasMany(models.Message, { foreignKey: 'channelId', as: 'messages' });
    Channel.hasMany(models.MuralPost, { foreignKey: 'channelId', as: 'posts' });
  };

  Message.associate = (models) => {
    Message.belongsTo(models.User, { foreignKey: 'senderId', as: 'sender' });
    Message.belongsTo(models.Channel, { foreignKey: 'channelId', as: 'channel' });
  };

  MuralPost.associate = (models) => {
    MuralPost.belongsTo(models.User, { foreignKey: 'creatorId', as: 'creator' });
    MuralPost.belongsTo(models.Channel, { foreignKey: 'channelId', as: 'channel' });
    MuralPost.belongsTo(models.MuralPost, { foreignKey: 'parentId', as: 'parent' });
    MuralPost.hasMany(models.MuralPost, { foreignKey: 'parentId', as: 'replies' });
  };

  return { Channel, Message, MuralPost };
};
