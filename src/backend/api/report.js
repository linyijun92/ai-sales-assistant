const express = require('express');
const router = express.Router();
const reportService = require('../services/dataOrganizer');

// 获取每日报告
router.get('/daily', async (req, res, next) => {
  try {
    const { date = new Date().toISOString().split('T')[0], userId } = req.query;
    const result = await reportService.getDailyReport(date, userId);
    res.json({
      success: true,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    next(error);
  }
});

// 获取指定日期报告
router.get('/:date', async (req, res, next) => {
  try {
    const { userId } = req.query;
    const result = await reportService.getDailyReport(req.params.date, userId);
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
