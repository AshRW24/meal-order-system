# 外卖订餐系统 - 管理端

基于 Vue 3 + Element Plus 的管理端系统

## 技术栈

- Node.js: 22.20.0
- npm: 10.9.3
- Vue 3: 最新版
- Element Plus: 最新版
- Vue Router: 4.x
- Pinia: 最新版
- Axios: 最新版
- Vite: 最新版

**详细环境配置**：参见 `../docs/环境配置.md`

## 项目结构

```
src/
├── api/          # API 接口
├── assets/       # 静态资源
├── components/   # 公共组件
├── router/       # 路由配置
├── stores/       # 状态管理
├── utils/        # 工具函数
├── views/        # 页面
├── App.vue       # 根组件
└── main.js       # 入口文件
```

## 安装依赖

```bash
npm install
```

## 运行项目

```bash
npm run dev
```

访问：http://localhost:5173

## 构建项目

```bash
npm run build
```

## 默认账号

- 用户名：admin
- 密码：123456

## 功能模块（按照规划图）

- [ ] 登录管理
- [ ] 分类管理
- [ ] 菜单管理（菜品管理）
- [ ] 菜品展示
- [ ] 套餐管理
- [ ] 订单明细

## 技术说明

- **认证方式**：Session + Cookie（前端需配置 `withCredentials: true`）
- **状态管理**：已配置 Pinia，简单存储用户信息
- **路由守卫**：已配置，未登录自动跳转登录页
- **API 配置**：已配置 Axios 拦截器，自动处理 401
