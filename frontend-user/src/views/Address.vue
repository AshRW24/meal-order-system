<template>
  <div class="address-container">
    <el-card class="address-card">
      <template #header>
        <div class="card-header">
          <h2>地址管理</h2>
          <el-button type="primary" @click="handleAdd">新增地址</el-button>
        </div>
      </template>

      <div v-if="addressList.length === 0" class="empty-state">
        <el-empty description="暂无收货地址，请添加" />
      </div>

      <div v-else class="address-list">
        <el-card
          v-for="address in addressList"
          :key="address.id"
          class="address-item"
          :class="{ 'is-default': address.isDefault === 1 }"
        >
          <div class="address-info">
            <div class="address-header">
              <span class="consignee">{{ address.consignee }}</span>
              <span class="phone">{{ address.phone }}</span>
              <el-tag v-if="address.label" type="info" size="small">{{ address.label }}</el-tag>
              <el-tag v-if="address.isDefault === 1" type="success" size="small">默认</el-tag>
            </div>
            <div class="address-detail">
              {{ address.province }} {{ address.city }} {{ address.district }} {{ address.detail }}
            </div>
          </div>
          <div class="address-actions">
            <el-button
              v-if="address.isDefault !== 1"
              type="primary"
              text
              @click="handleSetDefault(address)"
            >
              设为默认
            </el-button>
            <el-button type="primary" text @click="handleEdit(address)">编辑</el-button>
            <el-button type="danger" text @click="handleDelete(address)">删除</el-button>
          </div>
        </el-card>
      </div>
    </el-card>

    <!-- 新增/编辑地址对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="收货人" prop="consignee">
          <el-input v-model="formData.consignee" placeholder="请输入收货人姓名" />
        </el-form-item>

        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入11位手机号" maxlength="11" />
        </el-form-item>

        <el-form-item label="所在地区" required>
          <el-row :gutter="10">
            <el-col :span="8">
              <el-form-item prop="province">
                <el-input v-model="formData.province" placeholder="省" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item prop="city">
                <el-input v-model="formData.city" placeholder="市" />
              </el-form-item>
            </el-col>
            <el-col :span="8">
              <el-form-item prop="district">
                <el-input v-model="formData.district" placeholder="区" />
              </el-form-item>
            </el-col>
          </el-row>
        </el-form-item>

        <el-form-item label="详细地址" prop="detail">
          <el-input
            v-model="formData.detail"
            type="textarea"
            :rows="3"
            placeholder="请输入详细地址，如街道、门牌号等"
            maxlength="255"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="地址标签">
          <el-radio-group v-model="formData.label">
            <el-radio label="家">家</el-radio>
            <el-radio label="公司">公司</el-radio>
            <el-radio label="学校">学校</el-radio>
            <el-radio :label="null">无</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="默认地址">
          <el-switch
            v-model="formData.isDefault"
            :active-value="1"
            :inactive-value="0"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getAddressList,
  addAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress
} from '../api/address'

const addressList = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref(null)
const isEditMode = ref(false)

const formData = ref({
  id: null,
  consignee: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  label: null,
  isDefault: 0
})

const formRules = {
  consignee: [
    { required: true, message: '请输入收货人姓名', trigger: 'blur' },
    { min: 2, max: 32, message: '长度在 2 到 32 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  province: [
    { required: true, message: '请输入省份', trigger: 'blur' }
  ],
  city: [
    { required: true, message: '请输入城市', trigger: 'blur' }
  ],
  district: [
    { required: true, message: '请输入区/县', trigger: 'blur' }
  ],
  detail: [
    { required: true, message: '请输入详细地址', trigger: 'blur' },
    { min: 5, max: 255, message: '长度在 5 到 255 个字符', trigger: 'blur' }
  ]
}

const loadAddressList = async () => {
  try {
    const res = await getAddressList()
    if (res.code === 200) {
      addressList.value = res.data || []
    }
  } catch (error) {
    ElMessage.error('加载地址列表失败')
  }
}

const handleAdd = () => {
  isEditMode.value = false
  dialogTitle.value = '新增地址'
  formData.value = {
    id: null,
    consignee: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detail: '',
    label: null,
    isDefault: 0
  }
  dialogVisible.value = true
}

const handleEdit = (address) => {
  isEditMode.value = true
  dialogTitle.value = '编辑地址'
  formData.value = { ...address }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()

    const apiMethod = isEditMode.value ? updateAddress : addAddress
    const res = await apiMethod(formData.value)

    if (res.code === 200) {
      ElMessage.success(isEditMode.value ? '更新成功' : '添加成功')
      dialogVisible.value = false
      loadAddressList()
    }
  } catch (error) {
    if (error !== false) {
      ElMessage.error('操作失败')
    }
  }
}

const handleDelete = (address) => {
  ElMessageBox.confirm(
    `确定要删除"${address.consignee}"的收货地址吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    const res = await deleteAddress(address.id)
    if (res.code === 200) {
      ElMessage.success('删除成功')
      loadAddressList()
    }
  }).catch(() => {
    // 用户取消删除
  })
}

const handleSetDefault = async (address) => {
  try {
    const res = await setDefaultAddress(address.id)
    if (res.code === 200) {
      ElMessage.success('设置成功')
      loadAddressList()
    }
  } catch (error) {
    ElMessage.error('设置失败')
  }
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

onMounted(() => {
  loadAddressList()
})
</script>

<style scoped>
.address-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

.address-card {
  width: 100%;
  max-width: 900px;
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.empty-state {
  padding: 40px 0;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.address-item {
  border: 2px solid transparent;
  transition: all 0.3s;
}

.address-item:hover {
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.address-item.is-default {
  border-color: #67c23a;
}

.address-item :deep(.el-card__body) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
}

.address-info {
  flex: 1;
}

.address-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.consignee {
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.phone {
  color: #666;
  font-size: 14px;
}

.address-detail {
  color: #666;
  font-size: 14px;
  line-height: 1.6;
}

.address-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-left: 20px;
}

.address-actions .el-button {
  margin: 0;
}
</style>
