const express = require('express');
const router = express.Router();
const intentService = require('../services/intentRecognition');

// 意图识别接口
router.post('/recognize', async (req, res, next) => {
  try {
    const { text } = req.body;

    // 验证参数
    if (!text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'MISSING_TEXT',
          message: '输入文本不能为空'
        }
      });
    }

    // 调用意图识别服务
    const result = await intentService.recognizeIntent(text);

    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
