# AI 助销助手 - 系统架构设计

## 1. 系统架构概览

### 1.1 架构图
```
┌─────────────────────────────────────────────────────────────┐
│                     移动端应用 (Flutter)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ 语音输入  │  │ 文字输入  │  │ 数据展示  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
└────────────────────┬──────────────────────────────────────┘
                     │ HTTP/HTTPS
┌────────────────────▼──────────────────────────────────────┐
│                   后端服务 (Node.js/Express)             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │ API 网关  │  │ LLM 集成  │  │ 业务逻辑  │          │
│  └──────────┘  └──────────┘  └──────────┘          │
└─────────┬──────────┬──────────┬─────────────────────────┘
          │          │          │
          │          │          │
     ┌────▼───┐ ┌─▼─────┐ ┌─▼──────┐
     │语音识别API│ │LLM API│ │ CRM API │
     │(百度/阿里)│ │(GLM)  │ │(E销系统)│
     └─────────┘ └───────┘ └────────┘
```

### 1.2 架构分层
| 层级 | 技术 | 职责 |
|------|------|------|
| **表现层** | Flutter | 用户界面、语音输入、数据展示 |
| **网关层** | Express | API 路由、认证、限流 |
| **业务层** | Node.js | 意图识别、业务逻辑、数据处理 |
| **集成层** | 各种 SDK/API | LLM 集成、语音识别、CRM 对接 |
| **数据层** | MySQL | 客户数据、操作日志 |

---

## 2. 技术选型

### 2.1 移动端技术栈
| 组件 | 技术选型 | 理由 |
|------|---------|------|
| 框架 | Flutter 3.16+ | 跨平台，一套代码支持 iOS/Android |
| 状态管理 | Provider + River | 轻量级，适合中小型应用 |
| 网络请求 | Dio | 支持 REST API，易用 |
| 本地存储 | Hive | 高性能，适合结构化数据 |
| 语音录音 | record | Flutter 官方插件 |

### 2.2 后端技术栈
| 组件 | 技术选型 | 理由 |
|------|---------|------|
| 运行时 | Node.js 18 LTS | JavaScript 生态丰富，适合 AI 集成 |
| 框架 | Express 4.18+ | 轻量级，易扩展 |
| API 文档 | Swagger/OpenAPI | 自动生成文档 |
| 数据库 ORM | Sequelize | 支持 MySQL，类型安全 |
| 日志 | Winston | 结构化日志，易于分析 |
| 认证 | JWT + OAuth2 | 与 CRM 认证对接 |

### 2.3 AI 服务集成
| 服务 | API | 理由 |
|------|-----|------|
| LLM | GLM-4.7 (智谱 AI) | 中文能力强，性价比高 |
| 语音识别 | 百度语音 API v3 | 准确率高，支持中文 |
| 语音合成 | 百度语音合成 v3 | 自然度高 |

---

## 3. 核心模块设计

### 3.1 语音识别模块（Speech Recognition）

#### 3.1.1 功能
- 录制用户语音
- 调用语音识别 API
- 转换为文本
- 错误处理和重试

#### 3.1.2 接口设计
```
POST /api/v1/speech/recognize
Request:
{
  "audioData": "base64_encoded_audio",
  "format": "wav|mp3",
  "sampleRate": 16000
}

Response:
{
  "success": true,
  "text": "帮我新建一个客户张三",
  "confidence": 0.95
}
```

### 3.2 意图识别模块（Intent Recognition）

#### 3.2.1 功能
- 理解用户自然语言输入
- 识别操作类型（建档、跟进、查询等）
- 提取关键信息（姓名、电话、车型等）

#### 3.2.2 支持的意图
| 意图 | 示例 | 参数 |
|------|------|------|
| CREATE_CUSTOMER | "新建客户张三" | name, phone, carModel |
| ADD_FOLLOWUP | "添加跟进记录" | customerId, content |
| QUERY_CUSTOMER | "查询李四" | name/phone |
| UPDATE_STATUS | "更新状态" | customerId, status |
| BOOK_TESTDRIVE | "预约试驾" | customerId, time |

#### 3.2.3 接口设计
```
POST /api/v1/intent/recognize
Request:
{
  "text": "帮我新建一个客户张三，电话138xxxx8888"
}

Response:
{
  "success": true,
  "intent": "CREATE_CUSTOMER",
  "entities": {
    "name": "张三",
    "phone": "138xxxx8888"
  },
  "confidence": 0.88
}
```

### 3.3 CRM 对接模块（CRM Integration）

#### 3.3.1 功能
- 对接 E 销系统 API
- 实现 CRM 操作的代理
- 处理 API 错误和重试
- 数据映射和转换

#### 3.3.2 CRM API 封装
```
class CRMClient {
  // 客户管理
  async createCustomer(data)
  async getCustomer(id)
  async updateCustomer(id, data)

  // 跟进记录
  async addFollowup(customerId, content)
  async getFollowups(customerId)

  // 试驾管理
  async bookTestDrive(customerId, time)
  async getTestDrives(date)

  // 认证
  async authenticate(token)
}
```

### 3.4 数据整理模块（Data Organizer）

#### 3.4.1 功能
- 定时扫描 CRM 数据
- 分析客户跟进情况
- 生成整理报告
- 推送给销售顾问

#### 3.4.2 报告类型
| 报告类型 | 生成时间 | 内容 |
|---------|---------|------|
| 每日客户回顾 | 每日 22:00 | 当日跟进的客户列表 |
| 试驾日报 | 每日 22:00 | 试驾人数、车型、反馈 |
| 待跟进提醒 | 每日 09:00 | 超过 7 天未联系的客户 |
| 意向客户分析 | 每周一 | 高意向客户特征分析 |

---

## 4. 数据库设计

### 4.1 核心表结构

#### 4.1.1 customers（客户表）
```sql
CREATE TABLE customers (
  id VARCHAR(36) PRIMARY KEY,
  crm_customer_id VARCHAR(50) UNIQUE,  -- CRM 中的 ID
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  car_model VARCHAR(100),
  intent_level ENUM('low', 'medium', 'high'),
  followup_stage VARCHAR(50),
  last_followup_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_crm_id (crm_customer_id),
  INDEX idx_phone (phone)
);
```

#### 4.1.2 followups（跟进记录表）
```sql
CREATE TABLE followups (
  id VARCHAR(36) PRIMARY KEY,
  customer_id VARCHAR(36) NOT NULL,
  content TEXT NOT NULL,
  next_action VARCHAR(255),
  created_by VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  INDEX idx_customer (customer_id),
  INDEX idx_created (created_at)
);
```

#### 4.1.3 operation_logs（操作日志表）
```sql
CREATE TABLE operation_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  operation_type VARCHAR(50) NOT NULL,
  input_text TEXT,
  intent_recognized VARCHAR(100),
  crm_api_called TEXT,
  crm_response TEXT,
  success BOOLEAN,
  error_message TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user (user_id),
  INDEX idx_created (created_at)
);
```

#### 4.1.4 daily_reports（每日报告表）
```sql
CREATE TABLE daily_reports (
  id VARCHAR(36) PRIMARY KEY,
  report_type ENUM('daily_review', 'test_drive', 'pending_followup', 'intent_analysis'),
  report_date DATE NOT NULL,
  user_id VARCHAR(50),
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_date (user_id, report_date)
);
```

---

## 5. API 设计

### 5.1 RESTful API 规范

#### 5.1.1 基础 URL
```
https://api.ai-sales-assistant.com/v1
```

#### 5.1.2 认证
```
Header: Authorization: Bearer <jwt_token>
```

#### 5.1.3 核心接口

| 方法 | 路径 | 功能 |
|------|------|------|
| POST | /speech/recognize | 语音识别 |
| POST | /intent/recognize | 意图识别 |
| POST | /crm/customer/create | 创建客户 |
| POST | /crm/followup/add | 添加跟进记录 |
| GET | /crm/customer/:id | 查询客户 |
| PUT | /crm/customer/:id/status | 更新客户状态 |
| POST | /crm/testdrive/book | 预约试驾 |
| GET | /reports/daily | 获取每日报告 |
| GET | /reports/:date | 获取指定日期报告 |

### 5.2 响应格式标准

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
    "message": "姓名不能为空",
    "details": { ... }
  },
  "timestamp": "2026-02-12T12:00:00Z"
}
```

---

## 6. Prompt 工程设计

### 6.1 意图识别 Prompt 模板

```
你是一个销售 CRM 系统的意图识别助手。

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

请以 JSON 格式返回：
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
}
```

### 6.2 数据整理 Prompt 模板

```
你是一个销售数据分析师，负责整理和分析客户数据。

任务：基于以下客户数据，生成一份每日数据整理报告。

客户数据：
{customer_data}

请生成以下报告：
1. 今日重点客户（跟进阶段靠前的）
2. 试驾情况汇总（人数、车型分布）
3. 待跟进提醒（超过 7 天未联系的客户）
4. 跟进建议（基于客户历史数据）

请以 Markdown 格式输出报告。
```

---

## 7. 部署架构

### 7.1 开发环境
```
┌─────────────────────────────────┐
│   开发者本地机器               │
│  - Flutter 应用 (开发)          │
│  - Node.js 后端 (开发)         │
│  - 本地 MySQL                │
└─────────────────────────────────┘
```

### 7.2 生产环境
```
┌─────────────────────────────────────────────┐
│           CDN (静态资源)                     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│        负载均衡器 (Nginx)                  │
└──────┬──────────────┬──────────────┬─────┘
       │              │              │
┌──────▼──────┐  ┌──▼──────┐  ┌──▼──────────┐
│ 后端实例 1  │  │ 后端实例2│  │ 后端实例 N │
│ (Node.js)   │  │(Node.js) │  │ (Node.js)  │
└──────┬──────┘  └──┬──────┘  └──┬──────────┘
       │              │              │
       └──────┬───────┘              │
              │                        │
       ┌──────▼─────────────┐         │
       │  MySQL 主从集群   │         │
       └───────────────────┘         │
                                     │
                            ┌────────▼─────────┐
                            │ E 销 CRM 系统    │
                            └──────────────────┘
```

---

## 8. 安全设计

### 8.1 认证与授权
- **JWT Token**：用于 API 认证，有效期 24 小时
- **OAuth 2.0**：与 CRM 系统对接
- **RBAC**：基于角色的访问控制

### 8.2 数据加密
- **传输加密**：HTTPS/TLS 1.3
- **存储加密**：敏感字段 AES-256 加密
- **Token 加密**：JWT 使用强密钥签名

### 8.3 审计日志
- 记录所有 API 调用
- 记录所有 CRM 操作
- 记录所有 AI 意图识别结果

---

## 9. 性能优化

### 9.1 缓存策略
- **Redis 缓存**：热点客户数据
- **CDN 缓存**：静态资源
- **LLM 响应缓存**：相同问题缓存结果

### 9.2 异步处理
- **消息队列**：耗时的 CRM 操作异步处理
- **定时任务**：数据整理报告异步生成
- **邮件/推送**：通知异步发送

---

## 10. 监控与运维

### 10.1 监控指标
- **应用性能**：响应时间、错误率、吞吐量
- **AI 服务**：LLM 调用次数、成功率、响应时间
- **CRM 集成**：API 调用次数、失败率
- **业务指标**：日活用户、语音识别准确率、意图识别准确率

### 10.2 日志聚合
- **ELK Stack**：Elasticsearch + Logstash + Kibana
- **结构化日志**：JSON 格式，易于查询
- **告警机制**：关键错误实时通知

---

**文档版本**：v1.0
**创建日期**：2026-02-12
**负责人**：System Architect Agent
