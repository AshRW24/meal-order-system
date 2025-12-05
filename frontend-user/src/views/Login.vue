<template>
  <div class="login-container">
    <el-card class="login-card">
      <h2 class="title">外卖订餐系统</h2>

      <!-- Tab切换：登录/注册 -->
      <el-tabs v-model="activeTab" class="login-tabs">

        <!-- 登录Tab -->
        <el-tab-pane label="登录" name="login">
          <el-form
            ref="loginFormRef"
            :model="loginForm"
            :rules="loginRules"
            class="form"
          >
            <el-form-item prop="username">
              <el-input
                v-model="loginForm.username"
                placeholder="请输入用户名"
                prefix-icon="User"
                size="large"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                prefix-icon="Lock"
                size="large"
                show-password
                @keyup.enter="handleLogin"
              />
            </el-form-item>
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                style="width: 100%"
                :loading="loginLoading"
                @click="handleLogin"
              >
                登录
              </el-button>
            </el-form-item>
            <el-form-item>
              <el-link type="primary" @click="showForgetDialog">忘记密码？</el-link>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 注册Tab -->
        <el-tab-pane label="注册" name="register">
          <el-form
            ref="registerFormRef"
            :model="registerForm"
            :rules="registerRules"
            class="form"
          >
            <el-form-item prop="username">
              <el-input
                v-model="registerForm.username"
                placeholder="请输入用户名（3-20位）"
                prefix-icon="User"
                size="large"
              />
            </el-form-item>
            <el-form-item prop="password">
              <el-input
                v-model="registerForm.password"
                type="password"
                placeholder="请输入密码（6-20位）"
                prefix-icon="Lock"
                size="large"
                show-password
              />
            </el-form-item>
            <el-form-item prop="confirmPassword">
              <el-input
                v-model="registerForm.confirmPassword"
                type="password"
                placeholder="请确认密码"
                prefix-icon="Lock"
                size="large"
                show-password
              />
            </el-form-item>
            <el-form-item prop="securityQuestion">
              <el-select
                v-model="registerForm.securityQuestion"
                placeholder="请选择密保问题"
                size="large"
                style="width: 100%"
              >
                <el-option label="您母亲的姓名是？" value="您母亲的姓名是？" />
                <el-option label="您的出生城市是？" value="您的出生城市是？" />
                <el-option label="您小学的名称是？" value="您小学的名称是？" />
                <el-option label="您第一个宠物的名字是？" value="您第一个宠物的名字是？" />
                <el-option label="您最喜欢的电影是？" value="您最喜欢的电影是？" />
                <el-option label="您最喜欢的书籍是？" value="您最喜欢的书籍是？" />
              </el-select>
            </el-form-item>
            <el-form-item prop="securityAnswer">
              <el-input
                v-model="registerForm.securityAnswer"
                placeholder="请输入密保答案"
                prefix-icon="QuestionFilled"
                size="large"
              />
            </el-form-item>
            <el-form-item prop="phone">
              <el-input
                v-model="registerForm.phone"
                placeholder="请输入手机号（可选）"
                prefix-icon="Phone"
                size="large"
              />
            </el-form-item>
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                style="width: 100%"
                :loading="registerLoading"
                @click="handleRegister"
              >
                注册
              </el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

      </el-tabs>
    </el-card>

    <!-- 找回密码对话框 -->
    <el-dialog
      v-model="forgetDialogVisible"
      title="找回密码"
      width="450px"
      :close-on-click-modal="false"
    >
      <el-steps :active="forgetStep" align-center style="margin-bottom: 30px">
        <el-step title="输入账号" />
        <el-step title="验证密保" />
        <el-step title="重置密码" />
      </el-steps>

      <!-- 第一步：输入账号 -->
      <el-form v-if="forgetStep === 0" :model="forgetForm">
        <el-form-item label="账号">
          <el-input
            v-model="forgetForm.username"
            placeholder="请输入用户名"
            size="large"
          />
        </el-form-item>
      </el-form>

      <!-- 第二步：验证密保 -->
      <el-form v-if="forgetStep === 1">
        <el-form-item label="密保问题">
          <el-input
            v-model="securityQuestion"
            disabled
            size="large"
          />
        </el-form-item>
        <el-form-item label="密保答案">
          <el-input
            v-model="forgetForm.securityAnswer"
            placeholder="请输入密保答案"
            size="large"
          />
        </el-form-item>
      </el-form>

      <!-- 第三步：重置密码 -->
      <el-form v-if="forgetStep === 2" :model="forgetForm">
        <el-form-item label="新密码">
          <el-input
            v-model="forgetForm.newPassword"
            type="password"
            placeholder="请输入新密码（6-20位）"
            size="large"
            show-password
          />
        </el-form-item>
        <el-form-item label="确认密码">
          <el-input
            v-model="forgetForm.confirmPassword"
            type="password"
            placeholder="请再次输入新密码"
            size="large"
            show-password
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button v-if="forgetStep > 0" @click="forgetStep--">上一步</el-button>
        <el-button
          v-if="forgetStep < 2"
          type="primary"
          @click="handleForgetNext"
          :loading="forgetLoading"
        >
          下一步
        </el-button>
        <el-button
          v-if="forgetStep === 2"
          type="primary"
          @click="handleResetPassword"
          :loading="forgetLoading"
        >
          确认重置
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import request from '../utils/request'

const router = useRouter()

// Tab切换
const activeTab = ref('login')

// ==================== 登录 ====================
const loginFormRef = ref()
const loginLoading = ref(false)
const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  await loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loginLoading.value = true
      try {
        const res = await request.post('/user/login', loginForm)

        // 保存用户信息到 localStorage（后端使用Session，无需token）
        localStorage.setItem('userInfo', JSON.stringify(res.data))
        localStorage.setItem('token', 'session-based') // 兼容路由守卫

        window.$notification?.success('登录成功')
        // 刷新页面以更新余额显示
        router.push('/').then(() => {
          window.location.reload()
        })
      } catch (error) {
        console.error('登录失败：', error)
      } finally {
        loginLoading.value = false
      }
    }
  })
}

// ==================== 注册 ====================
const registerFormRef = ref()
const registerLoading = ref(false)
const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  securityQuestion: '',
  securityAnswer: '',
  phone: ''
})

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次密码输入不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  securityQuestion: [
    { required: true, message: '请选择密保问题', trigger: 'change' }
  ],
  securityAnswer: [
    { required: true, message: '请输入密保答案', trigger: 'blur' },
    { min: 1, max: 50, message: '密保答案长度为1-50位', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!registerFormRef.value) return

  await registerFormRef.value.validate(async (valid) => {
    if (valid) {
      registerLoading.value = true
      try {
        await request.post('/user/register', registerForm)
        window.$notification?.success('注册成功，请登录')
        activeTab.value = 'login'
        // 清空注册表单
        Object.keys(registerForm).forEach(key => {
          registerForm[key] = ''
        })
        registerFormRef.value.resetFields()
      } catch (error) {
        console.error('注册失败：', error)
      } finally {
        registerLoading.value = false
      }
    }
  })
}

// ==================== 找回密码 ====================
const forgetDialogVisible = ref(false)
const forgetStep = ref(0)
const forgetLoading = ref(false)
const securityQuestion = ref('')
const forgetForm = reactive({
  username: '',
  securityAnswer: '',
  newPassword: '',
  confirmPassword: ''
})

const showForgetDialog = () => {
  forgetDialogVisible.value = true
  forgetStep.value = 0
  Object.keys(forgetForm).forEach(key => {
    forgetForm[key] = ''
  })
  securityQuestion.value = ''
}

const handleForgetNext = async () => {
  if (forgetStep.value === 0) {
    // 第一步：获取密保问题
    if (!forgetForm.username) {
      window.$notification?.warning('请输入用户名')
      return
    }
    forgetLoading.value = true
    try {
      const res = await request.get('/user/security-question', {
        params: { username: forgetForm.username }
      })
      securityQuestion.value = res.data
      forgetStep.value = 1
    } catch (error) {
      console.error('获取密保问题失败：', error)
    } finally {
      forgetLoading.value = false
    }
  } else if (forgetStep.value === 1) {
    // 第二步：验证密保答案（直接进入下一步，后端会验证）
    if (!forgetForm.securityAnswer) {
      window.$notification?.warning('请输入密保答案')
      return
    }
    forgetStep.value = 2
  }
}

const handleResetPassword = async () => {
  if (!forgetForm.newPassword) {
    window.$notification?.warning('请输入新密码')
    return
  }
  if (forgetForm.newPassword.length < 6 || forgetForm.newPassword.length > 20) {
    window.$notification?.warning('密码长度为6-20位')
    return
  }
  if (forgetForm.newPassword !== forgetForm.confirmPassword) {
    window.$notification?.warning('两次密码输入不一致')
    return
  }

  forgetLoading.value = true
  try {
    await request.post('/user/reset-password', {
      username: forgetForm.username,
      securityAnswer: forgetForm.securityAnswer,
      newPassword: forgetForm.newPassword,
      confirmPassword: forgetForm.confirmPassword
    })
    window.$notification?.success('密码重置成功，请登录')
    forgetDialogVisible.value = false
    activeTab.value = 'login'
  } catch (error) {
    console.error('密码重置失败：', error)
  } finally {
    forgetLoading.value = false
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-light) 100%);
}

.login-card {
  width: 450px;
  padding: 20px;
}

.title {
  text-align: center;
  margin-bottom: 20px;
  color: #000000;
  font-size: 26px;
  font-weight: 700;
}

.login-tabs {
  margin-top: 10px;
}

.form {
  margin-top: 20px;
}
</style>
