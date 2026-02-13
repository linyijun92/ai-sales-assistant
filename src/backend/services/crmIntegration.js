const axios = require('axios');
const logger = require('winston');

// E 销系统 CRM API 配置
const CRM_CONFIG = {
  baseUrl: process.env.CRM_BASE_URL || 'https://crm.example.com/api/v2',
  apiKey: process.env.CRM_API_KEY
};

class CRMIntegrationService {
  constructor() {
    this.client = axios.create({
      baseURL: CRM_CONFIG.baseUrl,
      headers: {
        'Authorization': `Bearer ${CRM_CONFIG.apiKey}`,
        'Content-Type': 'application/json'
      }
    });
  }

  /**
   * 创建客户
   */
  async createCustomer(data) {
    try {
      logger.info('调用 CRM 创建客户:', data);

      // 映射数据格式
      const crmData = {
        customer_name: data.name,
        phone: data.phone,
        email: data.email,
        intent_car_model: data.carModel,
        intent_level: data.intentLevel || 'medium'
      };

      const response = await this.client.post('/customers', crmData);

      logger.info('CRM 创建客户成功:', response.data);

      return {
        crmId: response.data.customer_id,
        success: true
      };
    } catch (error) {
      logger.error('CRM 创建客户失败:', error.response?.data || error.message);
      throw new Error(`创建客户失败: ${error.response?.data?.message || error.message}`);
    }
  }

  /**
   * 获取客户信息
   */
  async getCustomer(customerId) {
    try {
      const response = await this.client.get(`/customers/${customerId}`);
      return response.data;
    } catch (error) {
      logger.error('CRM 获取客户失败:', error.response?.data || error.message);
      throw new Error(`获取客户失败: ${error.response?.data?.message || error.message}`);
    }
  }

  /**
   * 添加跟进记录
   */
  async addFollowup(data) {
    try {
      logger.info('调用 CRM 添加跟进记录:', data);

      const crmData = {
        customer_id: data.customerId,
        followup_content: data.content,
        next_action: data.nextAction,
        followup_time: new Date().toISOString()
      };

      const response = await this.client.post('/followups', crmData);

      logger.info('CRM 添加跟进记录成功');

      return {
        followupId: response.data.followup_id,
        success: true
      };
    } catch (error) {
      logger.error('CRM 添加跟进记录失败:', error.response?.data || error.message);
      throw new Error(`添加跟进记录失败: ${error.response?.data?.message || error.message}`);
    }
  }

  /**
   * 预约试驾
   */
  async bookTestDrive(data) {
    try {
      logger.info('调用 CRM 预约试驾:', data);

      const crmData = {
        customer_id: data.customerId,
        test_drive_time: data.time,
        car_model: data.carModel
      };

      const response = await this.client.post('/testdrives', crmData);

      logger.info('CRM 预约试驾成功');

      return {
        testDriveId: response.data.test_drive_id,
        success: true
      };
    } catch (error) {
      logger.error('CRM 预约试驾失败:', error.response?.data || error.message);
      throw new Error(`预约试驾失败: ${error.response?.data?.message || error.message}`);
    }
  }

  /**
   * 更新客户状态
   */
  async updateCustomerStatus(customerId, status) {
    try {
      const response = await this.client.put(`/customers/${customerId}`, {
        followup_stage: status
      });

      logger.info('CRM 更新客户状态成功');

      return {
        success: true
      };
    } catch (error) {
      logger.error('CRM 更新客户状态失败:', error.response?.data || error.message);
      throw new Error(`更新客户状态失败: ${error.response?.data?.message || error.message}`);
    }
  }
}

module.exports = new CRMIntegrationService();
