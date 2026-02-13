const logger = require('winston');

module.exports = (err, req, res, next) => {
  // 记录错误
  logger.error('API 错误:', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });

  // 默认错误
  let statusCode = err.statusCode || 500;
  let errorCode = 'INTERNAL_ERROR';
  let message = err.message || '服务器内部错误';

  // 已定义的错误
  if (err.name === 'ValidationError') {
    statusCode = 400;
    errorCode = 'VALIDATION_ERROR';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    errorCode = 'UNAUTHORIZED';
    message = '未授权访问';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    errorCode = 'NOT_FOUND';
    message = '资源不存在';
  }

  // 返回错误响应
  res.status(statusCode).json({
    success: false,
    error: {
      code: errorCode,
      message: message
    },
    timestamp: new Date().toISOString()
  });
};
