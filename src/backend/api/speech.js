const express = require('express');
const router = express.Router();
const speechService = require('../services/speechRecognition');

// 语音识别接口
router.post('/recognize', async (req, res, next) => {
  try {
    const { audioData, format = 'wav', sampleRate = 16000 } = req.body;

    // 验证参数
    if (!audioData) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'MISSING_AUDIO',
          message: '音频数据不能为空'
        }
      });
    }

    // 调用语音识别服务
    const result = await speechService.recognize({
      audioData,
      format,
      sampleRate
    });

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
