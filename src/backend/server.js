require('dotenv').config();
const express = require('express');
const cors = require('cors');
const winston = require('winston');

// 路由
const speechRoutes = require('./api/speech');
const intentRoutes = require('./api/intent');
const crmRoutes = require('./api/crm');
const reportRoutes = require('./api/report');

// 中间件
const errorHandler = require('./utils/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// 日志配置
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    path: req.path,
    ip: req.ip,
    userAgent: req.get('user-agent')
  });
  next();
});

// API 路由
app.use('/api/v1/speech', speechRoutes);
app.use('/api/v1/intent', intentRoutes);
app.use('/api/v1/crm', crmRoutes);
app.use('/api/v1/reports', reportRoutes);

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// 错误处理
app.use(errorHandler);

// 启动服务器
app.listen(PORT, () => {
  logger.info(`🚀 AI 助销助手后端服务启动成功`);
  logger.info(`📍 端口: ${PORT}`);
  logger.info(`🌍 环境: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
