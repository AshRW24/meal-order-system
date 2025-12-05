# GitHub 推送指南

## 现状
- ✅ 代码已在本地 Git 中提交
- 📍 Commit: `4518cb3`
- ✅ 消息: `Add Windows startup script, update .gitignore, and implement sales analytics dashboard`

## 推送方式选择

### 方式 1: 使用 GitHub Desktop (推荐最简单)
```
1. 打开 GitHub Desktop 应用
2. 选择 "Meal Order System" 仓库
3. 点击 "Push origin" 按钮
4. 或在菜单 Branch → Push 中进行推送
5. 根据提示输入 GitHub 凭证
```

### 方式 2: 使用 GitHub Web UI (Web 上传)
```
1. 访问 https://github.com/AshRW24/meal-order-system
2. 点击 "Upload files" 按钮
3. 拖拽或选择项目文件
4. 提交变更
```

### 方式 3: 使用 Personal Access Token (命令行)
```bash
# 步骤 1: 生成 Personal Access Token
# 访问: https://github.com/settings/tokens
# - 点击 "Generate new token (classic)"
# - 勾选 "repo" 权限
# - 复制生成的 token

# 步骤 2: 设置 Git 认证
git config --global credential.helper store

# 步骤 3: 推送代码
cd /Users/huangzirui/Desktop/meal-order-system
git push -u origin main

# 步骤 4: 输入凭证
# Username: AshRW24
# Password: <粘贴 Personal Access Token>
```

### 方式 4: 使用 SSH 密钥 (长期解决方案)
```bash
# 步骤 1: 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your-email@example.com"
# 或
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# 步骤 2: 添加到 GitHub
# 访问: https://github.com/settings/keys
# 新增 SSH key，粘贴 ~/.ssh/id_rsa.pub 的内容

# 步骤 3: 更新 Git 远程
git remote set-url origin git@github.com:AshRW24/meal-order-system.git

# 步骤 4: 推送
git push -u origin main
```

## 快速验证

推送完成后，验证提交是否已上传：
```bash
# 本地检查
git log --oneline -1

# GitHub 网页
访问: https://github.com/AshRW24/meal-order-system/commits/main
```

## 提交内容
- ✅ Windows 启动脚本 (start_all.bat)
- ✅ .gitignore 更新
- ✅ 销量统计后端 API (SalesController.java)
- ✅ 销量统计前端 API (sales.js)
- ✅ 销量统计可视化组件 (SalesStatistics.vue)
- ✅ 路由配置更新
- ✅ 导航菜单更新
- ✅ ECharts 依赖添加
- ✅ AI 客服浮窗组件 (ChatBotWindow.vue)

---

**建议**: 使用 **GitHub Desktop** 是最简单的方式！
