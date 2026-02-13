const axios = require('axios');
const cron = require('node-cron');
const logger = require('winston');

// GLM API 配置
const GLM_CONFIG = {
  apiUrl: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
  apiKey: process.env.GLM_API_KEY,
  model: 'glm-4.7'
};

// 数据整理 Prompt 模板
const DATA_ORGANIZER_PROMPT = `你是一个销售数据分析师，负责整理和分析客户数据。

任务：基于以下客户数据，生成一份每日数据整理报告。

客户数据：
{customer_data}

请生成以下报告：
1. 今日重点客户（跟进阶段靠前的）
2. 试驾情况汇总（人数、车型分布）
3. 待跟进提醒（超过 7 天未联系的客户）
4. 跟进建议（基于客户历史数据）

请以 Markdown 格式输出报告，不要包含其他文字。`;

class DataOrganizerService {
  constructor() {
    this.crmClient = require('./crmIntegration');
  }

  /**
   * 获取每日报告
   */
  async getDailyReport(date, userId) {
    try {
      logger.info(`生成 ${date} 的每日报告，用户: ${userId}`);

      // 从 CRM 获取客户数据
      const customers = await this.crmClient.getCustomersByDate(date, userId);

      // 如果没有数据，返回空报告
      if (!customers || customers.length === 0) {
        return {
          date,
          summary: '今日无客户数据',
          reports: []
        };
      }

      // 使用 LLM 生成报告
      const customerDataJson = JSON.stringify(customers, null, 2);
      const prompt = DATA_ORGANIZER_PROMPT.replace('{customer_data}', customerDataJson);

      const response = await axios.post(GLM_CONFIG.apiUrl, {
        model: GLM_CONFIG.model,
        messages: [
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.5,
        max_tokens: 2000
      }, {
        headers: {
          'Authorization': `Bearer ${GLM_CONFIG.apiKey}`,
          'Content-Type': 'application/json'
        }
      });

      const reportMarkdown = response.data.choices[0].message.content;

      // 保存报告到数据库
      const reportId = await this.saveReport({
        reportType: 'daily_review',
        date,
        userId,
        content: reportMarkdown
      });

      return {
        reportId,
        date,
        summary: '每日报告生成成功',
        content: reportMarkdown
      };
    } catch (error) {
      logger.error('生成每日报告失败:', error);
      throw new Error('生成报告失败，请重试');
    }
  }

  /**
   * 保存报告到数据库
   */
  async saveReport(data) {
    // 这里应该调用数据库操作
    // 暂时返回模拟 ID
    return `report_${Date.now()}`;
  }

  /**
   * 自动生成每日报告（定时任务）
   */
  startDailyReportJob() {
    // 每天 22:00 生成报告
    cron.schedule('0 22 * * *', async () => {
      try {
        logger.info('开始执行每日报告生成任务');

        const today = new Date().toISOString().split('T')[0];

        // 获取所有需要生成报告的用户
        // 这里应该从数据库查询活跃用户
        const users = ['user1', 'user2']; // 示例

        for (const userId of users) {
          await this.getDailyReport(today, userId);
        }

        logger.info('每日报告生成任务完成');
      } catch (error) {
        logger.error('每日报告生成任务失败:', error);
      }
    });

    logger.info('每日报告定时任务已启动：每天 22:00');
  }

  /**
   * 生成试驾日报
   */
  async generateTestDriveReport(date) {
    try {
      logger.info(`生成 ${date} 的试驾日报`);

      const testDrives = await this.crmClient.getTestDrivesByDate(date);

      // 分析试驾数据
      const summary = {
        totalCount: testDrives.length,
        modelDistribution: {},
        feedbackSummary: []
      };

      testDrives.forEach(drive => {
        const model = drive.carModel;
        summary.modelDistribution[model] = (summary.modelDistribution[model] || 0) + 1;

        if (drive.feedback) {
          summary.feedbackSummary.push(drive.feedback);
        }
      });

      const reportMarkdown = `
# 试驾日报 - ${date}

## 试驾概况
- 试驾总人数：${summary.totalCount}
- 车型分布：
${Object.entries(summary.modelDistribution).map(([model, count]) =>
  `- ${model}: ${count}人`).join('\n')}

## 客户反馈汇总
${summary.feedbackSummary.length > 0 ?
  summary.feedbackSummary.map(f => `- ${f}`).join('\n') :
  '暂无反馈'}
`;

      return {
        date,
        summary,
        content: reportMarkdown
      };
    } catch (error) {
      logger.error('生成试驾日报失败:', error);
      throw new Error('生成试驾日报失败');
    }
  }
}

module.exports = new DataOrganizerService();
