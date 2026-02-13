# AI 助销助手

## 📋 项目概述

AI 助销助手是一款移动端增强型应用，利用 LLM 能力将 CRM（E 销系统）增强为 AI Agent 应用。

### 核心功能
1. **自然语言操控 CRM**：通过语音或文字让 AI 智能操控 CRM 系统
2. **AI 个人助理**：自动整理客户信息、试驾报告等
3. **智能数据分析**：生成每日报告，提供跟进建议

---

## 🏗️ 项目结构

```
ai-sales-assistant/
├── docs/                          # 文档目录
│   ├── requirements.md             # 产品需求文档（PRD）
│   └── architecture.md             # 系统架构设计
├── src/                           # 源代码目录
│   ├── backend/                    # 后端服务（Node.js）
│   │   ├── api/                   # API 路由
│   │   ├── services/              # 业务服务
│   │   ├── models/                # 数据模型
│   │   ├── utils/                 # 工具函数
│   │   ├── server.js              # 服务器入口
│   │   └── package.json           # 依赖配置
│   └── mobile/                    # 移动端应用（Flutter）
│       └── lib/                   # Flutter 代码
└── tests/                         # 测试目录
```

---

## 🚀 快速开始

### 后端服务

#### 1. 安装依赖
```bash
cd src/backend
npm install
```

#### 2. 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件，填入真实的 API Key
```

#### 3. 启动服务
```bash
# 开发模式
npm run dev

# 生产模式
npm start
```

服务将在 `http://localhost:3000` 启动

#### 4. 健康检查
```bash
curl http://localhost:3000/health
```

### 移动端应用

#### 1. 安装 Flutter
```bash
# macOS
brew install flutter

# Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. 安装依赖
```bash
cd src/mobile
flutter pub get
```

#### 3. 运行应用
```bash
# iOS
flutter run

# Android
flutter run

# Web
flutter run -d chrome
```

---

## 📡 API 文档

### 核心接口

| 方法 | 路径 | 功能 |
|------|------|------|
| POST | /api/v1/speech/recognize | 语音识别 |
| POST | /api/v1/intent/recognize | 意图识别 |
| POST | /api/v1/crm/customer/create | 创建客户 |
| POST | /api/v1/crm/followup/add | 添加跟进记录 |
| GET | /api/v1/reports/daily | 获取每日报告 |

### API 响应格式

#### 成功响应
```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2026-02-12T12:00:00Z"
}
```

#### 错误响应
```json
{
  "success": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "错误描述"
  },
  "timestamp": "2026-02-12T12:00:00Z"
}
```

---

## 🔧 配置说明

### 后端环境变量（.env）

| 变量 | 说明 | 示例 |
|------|------|------|
| NODE_ENV | 运行环境 | development/production |
| PORT | 服务端口 | 3000 |
| GLM_API_KEY | GLM API 密钥 | sk-xxx |
| BAIDU_API_KEY | 百度语音 API Key | xxx |
| BAIDU_SECRET_KEY | 百度语音 Secret Key | xxx |
| CRM_BASE_URL | CRM 系统 API 地址 | https://crm.example.com/api/v2 |
| CRM_API_KEY | CRM API 密钥 | xxx |
| JWT_SECRET | JWT 签名密钥 | xxx |

---

## 🧪 测试

### 后端测试
```bash
cd src/backend
npm test
```

### 移动端测试
```bash
cd src/mobile
flutter test
```

---

## 📊 项目进度

| 阶段 | 状态 | 进度 |
|------|------|------|
| 需求分析 | ✅ 完成 | 100% |
| 架构设计 | ✅ 完成 | 100% |
| 后端开发 | 🔄 进行中 | 60% |
| 移动端开发 | 🔄 进行中 | 40% |
| 测试 | ⏳ 待开始 | 0% |

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License

---

**项目版本**：v1.0
**创建日期**：2026-02-12
**技术栈**：Node.js + Express + Flutter + GLM-4.7
