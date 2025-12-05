<template>
  <div class="setmeal-container">
    <!-- 搜索筛选区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="套餐名称">
          <el-input v-model="searchForm.name" placeholder="请输入套餐名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchForm.categoryId" placeholder="请选择分类" clearable style="width: 150px">
            <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 120px">
            <el-option label="在售" :value="1" />
            <el-option label="停售" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作按钮 -->
    <el-card class="action-card">
      <el-button type="warning" @click="handleAdd" class="orange-btn">
        <el-icon><Plus /></el-icon>
        新增套餐
      </el-button>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" v-loading="loading" border stripe class="orange-table">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column label="套餐图片" width="120">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="row.image"
              :preview-src-list="[row.image]"
              fit="cover"
              class="setmeal-image"
              :preview-teleported="true"
            >
              <template #error>
                <div class="image-error">
                  <el-icon><Picture /></el-icon>
                </div>
              </template>
            </el-image>
            <span v-else>暂无图片</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="套餐名称" min-width="150" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :page-sizes="[10, 20, 30, 50]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        class="pagination"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      :close-on-click-modal="false"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="套餐名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入套餐名称" />
        </el-form-item>
        <el-form-item label="所属分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="套餐价格" prop="price">
          <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="套餐图片">
          <el-upload
            class="upload-demo"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
            :headers="{ 'Content-Type': 'multipart/form-data' }"
            accept="image/*"
          >
            <img v-if="form.image" :src="getImageUrl(form.image)" class="uploaded-image" />
            <el-icon v-else class="upload-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">支持jpg、png等图片格式</div>
        </el-form-item>
        <el-form-item label="套餐描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入套餐描述" />
        </el-form-item>
        <el-form-item label="包含菜品" prop="dishes">
          <el-button type="primary" size="small" @click="showDishSelector">选择菜品</el-button>
          <el-table :data="form.dishes" border size="small" style="margin-top: 10px">
            <el-table-column prop="dishName" label="菜品名称" />
            <el-table-column prop="quantity" label="数量" width="150">
              <template #default="{ row }">
                <el-input-number v-model="row.quantity" :min="1" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ $index }">
                <el-button type="danger" size="small" @click="removeDish($index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 菜品选择对话框 -->
    <el-dialog v-model="dishSelectorVisible" title="选择菜品" width="600px">
      <el-table :data="dishList" @selection-change="handleDishSelectionChange" border>
        <el-table-column type="selection" width="55" />
        <el-table-column prop="name" label="菜品名称" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="dishSelectorVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmDishSelection">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Picture } from '@element-plus/icons-vue'
import { getSetmealPage, addSetmeal, updateSetmeal, deleteSetmeal, getSetmealById, updateSetmealStatus } from '../api/setmeal'
import { getCategoryList } from '../api/category'
import { getDishPage } from '../api/dish'

// 搜索表单
const searchForm = reactive({
  name: '',
  categoryId: null,
  status: null
})

// 分类列表
const categoryList = ref([])

// 菜品列表（用于选择）
const dishList = ref([])

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增套餐')
const formRef = ref(null)

// 表单数据
const form = reactive({
  id: null,
  name: '',
  categoryId: null,
  price: null,
  image: '',
  description: '',
  dishes: [] // [{ dishId, dishName, quantity }]
})

// 表单验证规则
const rules = {
  name: [{ required: true, message: '请输入套餐名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  dishes: [{ required: true, message: '请选择包含的菜品', trigger: 'change' }]
}

// 图片上传地址
const uploadUrl = ref('/api/admin/common/upload')

// Get image URL (handle relative and absolute paths)
const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `http://localhost:8080/api${url}`
}

// 菜品选择对话框
const dishSelectorVisible = ref(false)
const selectedDishes = ref([])

// 初始化
onMounted(() => {
  loadCategoryList()
  loadTableData()
  loadDishList()
})

// 加载分类列表
const loadCategoryList = async () => {
  try {
    const res = await getCategoryList()
    if (res.code === 1) {
      categoryList.value = res.data
    }
  } catch (error) {
    console.error('加载分类列表失败:', error)
  }
}

// 加载菜品列表
const loadDishList = async () => {
  try {
    const res = await getDishPage({ page: 1, pageSize: 100, status: 1 })
    if (res.code === 1) {
      dishList.value = res.data.records
    }
  } catch (error) {
    console.error('加载菜品列表失败:', error)
  }
}

// 加载表格数据
const loadTableData = async () => {
  loading.value = true
  try {
    const res = await getSetmealPage({
      page: pagination.page,
      pageSize: pagination.pageSize,
      name: searchForm.name || undefined,
      categoryId: searchForm.categoryId || undefined,
      status: searchForm.status !== null ? searchForm.status : undefined
    })
    if (res.code === 1) {
      tableData.value = res.data.records
      pagination.total = res.data.total
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadTableData()
}

// 重置
const handleReset = () => {
  searchForm.name = ''
  searchForm.categoryId = null
  searchForm.status = null
  handleSearch()
}

// 分页
const handleSizeChange = () => {
  loadTableData()
}

const handleCurrentChange = () => {
  loadTableData()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增套餐'
  resetForm()
  dialogVisible.value = true
}

// 编辑
const handleEdit = async (row) => {
  dialogTitle.value = '编辑套餐'
  try {
    const res = await getSetmealById(row.id)
    if (res.code === 1) {
      form.id = res.data.id
      form.name = res.data.name
      form.categoryId = res.data.categoryId
      form.price = res.data.price
      form.image = res.data.image
      form.description = res.data.description

      // 转换菜品数据
      form.dishes = (res.data.dishes || []).map(d => {
        const dish = dishList.value.find(item => item.id === d.dishId)
        return {
          dishId: d.dishId,
          dishName: dish ? dish.name : '未知菜品',
          quantity: d.quantity
        }
      })

      dialogVisible.value = true
    }
  } catch (error) {
    ElMessage.error('加载套餐信息失败')
  }
}

// 删除
const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除套餐"${row.name}"吗？`, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await deleteSetmeal(row.id)
      if (res.code === 1) {
        ElMessage.success('删除成功')
        loadTableData()
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 状态切换
const handleStatusChange = (row) => {
  const statusText = row.status === 1 ? '上架' : '下架'
  ElMessageBox.confirm(`确定要${statusText}该套餐吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await updateSetmealStatus(row.id, row.status)
      if (res.code === 1) {
        ElMessage.success(`${statusText}成功`)
      }
    } catch (error) {
      row.status = row.status === 1 ? 0 : 1
      ElMessage.error(`${statusText}失败`)
    }
  }).catch(() => {
    row.status = row.status === 1 ? 0 : 1
  })
}

// 图片上传成功
const handleUploadSuccess = (response) => {
  if (response.code === 1) {
    form.image = response.data
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error('图片上传失败')
  }
}

// 图片上传前校验
const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt100M = file.size / 1024 / 1024 < 100

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt100M) {
    ElMessage.error('图片大小不能超过 100MB!')
    return false
  }
  return true
}

// 显示菜品选择器
const showDishSelector = () => {
  dishSelectorVisible.value = true
}

// 菜品选择变化
const handleDishSelectionChange = (selection) => {
  selectedDishes.value = selection
}

// 确认菜品选择
const confirmDishSelection = () => {
  selectedDishes.value.forEach(dish => {
    const exists = form.dishes.find(d => d.dishId === dish.id)
    if (!exists) {
      form.dishes.push({
        dishId: dish.id,
        dishName: dish.name,
        quantity: 1
      })
    }
  })
  dishSelectorVisible.value = false
}

// 移除菜品
const removeDish = (index) => {
  form.dishes.splice(index, 1)
}

// 提交表单
const handleSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const data = {
          id: form.id,
          name: form.name,
          categoryId: form.categoryId,
          price: form.price,
          image: form.image,
          description: form.description,
          dishes: form.dishes.map(d => ({
            dishId: d.dishId,
            quantity: d.quantity
          }))
        }

        const res = form.id ? await updateSetmeal(data) : await addSetmeal(data)
        if (res.code === 200) {
          ElMessage.success(form.id ? '修改成功' : '新增成功')
          dialogVisible.value = false
          loadTableData()
        }
      } catch (error) {
        ElMessage.error(form.id ? '修改失败' : '新增失败')
      }
    }
  })
}

// 重置表单
const resetForm = () => {
  form.id = null
  form.name = ''
  form.categoryId = null
  form.price = null
  form.image = ''
  form.description = ''
  form.dishes = []
}
</script>

<style scoped>
.setmeal-container {
  padding: 0;
  width: 100%;
}

.search-card, .action-card, .table-card {
  margin: 20px;
  width: calc(100% - 40px);
}

.orange-btn {
  background: linear-gradient(135deg, #ff8c00, #ffa500);
  border: none;
  color: white;
}

.orange-btn:hover {
  background: linear-gradient(135deg, #ffa500, #ffb733);
}

.setmeal-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  cursor: pointer;
}

.image-error {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: #f5f5f5;
  border-radius: 8px;
}

.pagination {
  margin-top: 20px;
  justify-content: flex-end;
}

.upload-demo {
  width: 150px;
  height: 150px;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.upload-demo:hover {
  border-color: #409eff;
}

.upload-icon {
  font-size: 28px;
  color: #8c939d;
}

.upload-image {
  width: 100%;
  height: 100%;
}
</style>
