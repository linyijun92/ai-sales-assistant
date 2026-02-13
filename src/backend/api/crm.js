const express = require('express');
const router = express.Router();
const crmService = require('../services/crmIntegration');

// 创建客户
router.post('/customer/create', async (req, res, next) => {
  try {
    const result = await crmService.createCustomer(req.body);
    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

// 查询客户
router.get('/customer/:id', async (req, res, next) => {
  try {
    const result = await crmService.getCustomer(req.params.id);
    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

// 添加跟进记录
router.post('/followup/add', async (req, res, next) => {
  try {
    const result = await crmService.addFollowup(req.body);
    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

// 预约试驾
router.post('/testdrive/book', async (req, res, next) => {
  try {
    const result = await crmService.bookTestDrive(req.body);
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
