const axios = require('axios');
const logger = require('winston');

// 百度语音识别配置
const BAIDU_SPEECH_CONFIG = {
  apiUrl: 'https://vop.baidu.com/server_api',
  apiKey: process.env.BAIDU_API_KEY,
  secretKey: process.env.BAIDU_SECRET_KEY,
  // 获取 access token
  async getAccessToken() {
    const res = await axios.post('https://aip.baidubce.com/oauth/2.0/token', null, {
      params: {
        grant_type: 'client_credentials',
        client_id: this.apiKey,
        client_secret: this.secretKey
      }
    });
    return res.data.access_token;
  }
};

class SpeechRecognitionService {
  constructor() {
    this.accessToken = null;
    this.tokenExpireTime = null;
  }

  async recognize({ audioData, format, sampleRate }) {
    try {
      // 获取 access token（如果过期或不存在）
      if (!this.accessToken || Date.now() > this.tokenExpireTime) {
        this.accessToken = await BAIDU_SPEECH_CONFIG.getAccessToken();
        this.tokenExpireTime = Date.now() + 2592000000; // 30 天
      }

      // 调用百度语音识别 API
      const res = await axios.post(`${BAIDU_SPEECH_CONFIG.apiUrl}/api/v1/voice/pcm`, audioData, {
        params: {
          dev_pid: format === 'wav' ? 1737 : 80001, // 普通话（支持自定义音色）
          token: this.accessToken
        },
        headers: {
          'Content-Type': 'audio/' + format + ';rate=' + sampleRate
        },
        maxContentLength: Infinity,
        maxBodyLength: Infinity
      });

      const result = res.data;

      if (result.err_no !== 0) {
        throw new Error(`语音识别失败: ${result.err_msg}`);
      }

      return {
        text: result.result[0], // 识别的文本
        confidence: 0.95 // 百度API不返回置信度，使用固定值
      };
    } catch (error) {
      logger.error('语音识别服务错误:', error);
      throw new Error('语音识别失败，请重试');
    }
  }
}

module.exports = new SpeechRecognitionService();
