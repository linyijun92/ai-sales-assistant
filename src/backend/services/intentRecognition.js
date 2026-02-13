const axios = require('axios');
const logger = require('winston');

// GLM API 配置
const GLM_CONFIG = {
  apiUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  apiKey: process.env.GLM_API_KEY,
  model: 'glm-4.7'
};

// 意图识别 Prompt 模板
const INTENT_PROMPT = `你是一个销售 CRM 系统的意图识别助手。

任务：分析用户输入，识别他们想要执行的操作，并提取关键信息。

用户输入：{user_input}

可选操作类型：
1. CREATE_CUSTOMER - 创建新客户
2. ADD_FOLLOWUP - 添加跟进记录
3. QUERY_CUSTOMER - 查询客户信息
4. UPDATE_STATUS - 更新客户状态
5. BOOK_TESTDRIVE - 预约试驾

提取的实体：
- name: 客户姓名
- phone: 电话号码
- email: 电子邮件
- carModel: 意向车型
- followupContent: 跟进内容
- status: 状态
- testDriveTime: 试驾时间

请以 JSON 格式返回，不要包含其他文字：
{
  "intent": "操作类型",
  "confidence": 0.0-1.0,
  "entities": {
    "提取的实体": "值"
  }
}

如果无法识别意图，返回：
{
  "intent": "UNKNOWN",
  "confidence": 0.0,
  "entities": {}
}`;

class IntentRecognitionService {
  async recognizeIntent(userInput) {
    try {
      const prompt = INTENT_PROMPT.replace('{user_input}', userInput);

      // 调用 GLM API
      const response = await axios.post(GLM_CONFIG.apiUrl, {
        model: GLM_CONFIG.model,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.3,
        max_tokens: 500
      }, {
        headers: {
          'Authorization': `Bearer ${GLM_CONFIG.apiKey}`,
          'Content-Type': 'application/json'
        }
      });

      const content = response.data.choices[0].message.content;

      // 解析 JSON 响应
      const result = JSON.parse(content);

      // 验证结果
      if (!result.intent || !result.confidence) {
        throw new Error('意图识别结果格式错误');
      }

      logger.info(`意图识别成功: ${result.intent}, 置信度: ${result.confidence}`);

      return result;
    } catch (error) {
      logger.error('意图识别服务错误:', error);

      // 如果是 JSON 解析错误，返回默认值
      if (error instanceof SyntaxError) {
        return {
          intent: 'UNKNOWN',
          confidence: 0.0,
          entities: {}
        };
      }

      throw new Error('意图识别失败，请重试');
    }
  }
}

module.exports = new IntentRecognitionService();
