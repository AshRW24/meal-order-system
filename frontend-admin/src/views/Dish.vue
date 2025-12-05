<template>
  <div class="dish-container">
    <!-- Search bar -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="菜品名称">
          <el-input v-model="searchForm.name" placeholder="请输入菜品名称" clearable style="width: 200px" />
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

    <!-- Action buttons -->
    <el-card class="action-card">
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增菜品
      </el-button>
    </el-card>

    <!-- Data table -->
    <el-card class="table-card">
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column label="菜品图片" width="120">
          <template #default="{ row }">
            <el-image
              v-if="row.image"
              :src="row.image"
              :preview-src-list="[row.image]"
              fit="cover"
              class="dish-image"
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
        <el-table-column prop="name" label="菜品名称" min-width="150" />
        <el-table-column prop="price" label="价格" width="100">
          <template #default="{ row }">¥{{ row.price }}</template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80" />
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              active-text="在售"
              inactive-text="停售"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- Pagination -->
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

    <!-- Add/Edit Dialog -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="菜品名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入菜品名称" />
        </el-form-item>
        <el-form-item label="所属分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 100%">
            <el-option
              v-for="cat in dishCategoryList"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="菜品价格" prop="price">
          <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="库存数量" prop="stock">
          <el-input-number v-model="form.stock" :min="0" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="菜品图片">
          <el-upload
            class="image-uploader"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
            accept="image/*"
          >
            <img v-if="form.image" :src="getImageUrl(form.image)" class="uploaded-image" />
            <el-icon v-else class="uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">支持jpg、png等图片格式</div>
        </el-form-item>
        <el-form-item label="菜品描述">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入菜品描述" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">在售</el-radio>
            <el-radio :label="0">停售</el-radio>
          </el-radio-group>
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Picture } from '@element-plus/icons-vue'
import { getDishPage, addDish, updateDish, deleteDish, getDishById, updateDishStatus } from '../api/dish'
import { getCategoryList } from '../api/category'

// Search form
const searchForm = reactive({
  name: '',
  categoryId: null,
  status: null
})

// Category list
const categoryList = ref([])
const dishCategoryList = ref([]) // Only dish categories (type=1)

// Table data
const tableData = ref([])
const loading = ref(false)

// Pagination
const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

// Dialog
const dialogVisible = ref(false)
const dialogTitle = ref('新增菜品')
const formRef = ref(null)

// Form data
const form = reactive({
  id: null,
  name: '',
  categoryId: null,
  price: null,
  stock: 0,
  image: '',
  description: '',
  status: 1
})

// Form validation rules
const rules = {
  name: [{ required: true, message: '请输入菜品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  stock: [{ required: true, message: '请输入库存数量', trigger: 'blur' }]
}

// Upload URL
const uploadUrl = ref('/api/admin/common/upload')

// Get image URL (handle relative and absolute paths)
const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `http://localhost:8080/api${url}`
}

// Initialize
onMounted(() => {
  loadCategoryList()
  loadTableData()
})

// Load category list
const loadCategoryList = async () => {
  try {
    const res = await getCategoryList()
    if (res.code === 200) {
      categoryList.value = res.data
      // Filter only dish categories (type=1)
      dishCategoryList.value = res.data.filter(cat => cat.type === 1)
    }
  } catch (error) {
    console.error('加载分类列表失败:', error)
  }
}

// Load table data
const loadTableData = async () => {
  loading.value = true
  try {
    const res = await getDishPage({
      page: pagination.page,
      pageSize: pagination.pageSize,
      name: searchForm.name || undefined,
      categoryId: searchForm.categoryId || undefined,
      status: searchForm.status !== null ? searchForm.status : undefined
    })
    if (res.code === 200) {
      tableData.value = res.data.records
      pagination.total = res.data.total
    }
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

// Search
const handleSearch = () => {
  pagination.page = 1
  loadTableData()
}

// Reset
const handleReset = () => {
  searchForm.name = ''
  searchForm.categoryId = null
  searchForm.status = null
  handleSearch()
}

// Pagination
const handleSizeChange = () => {
  loadTableData()
}

const handleCurrentChange = () => {
  loadTableData()
}

// Add
const handleAdd = () => {
  dialogTitle.value = '新增菜品'
  resetForm()
  dialogVisible.value = true
}

// Edit
const handleEdit = async (row) => {
  dialogTitle.value = '编辑菜品'
  try {
    const res = await getDishById(row.id)
    if (res.code === 200) {
      form.id = res.data.id
      form.name = res.data.name
      form.categoryId = res.data.categoryId
      form.price = res.data.price
      form.stock = res.data.stock
      form.image = res.data.image || ''
      form.description = res.data.description || ''
      form.status = res.data.status
      dialogVisible.value = true
    }
  } catch (error) {
    ElMessage.error('加载菜品信息失败')
  }
}

// Delete
const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除菜品"${row.name}"吗？`, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await deleteDish(row.id)
      if (res.code === 200) {
        ElMessage.success('删除成功')
        loadTableData()
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// Status change
const handleStatusChange = (row) => {
  const statusText = row.status === 1 ? '上架' : '下架'
  ElMessageBox.confirm(`确定要${statusText}该菜品吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await updateDishStatus(row.id, row.status)
      if (res.code === 200) {
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

// Submit form
const handleSubmit = () => {
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const data = {
          id: form.id,
          name: form.name,
          categoryId: form.categoryId,
          price: form.price,
          stock: form.stock,
          image: form.image || null,
          description: form.description || null,
          status: form.status
        }

        const res = form.id ? await updateDish(data) : await addDish(data)
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

// Reset form
const resetForm = () => {
  form.id = null
  form.name = ''
  form.categoryId = null
  form.price = null
  form.stock = 0
  form.image = ''
  form.description = ''
  form.status = 1
}

// Handle upload success
const handleUploadSuccess = (response) => {
  if (response.code === 200) {
    form.image = response.data
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.msg || '图片上传失败')
  }
}

// Before upload validation
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
</script>

<style scoped>
.dish-container {
  padding: 0;
  width: 100%;
}

.search-card, .action-card, .table-card {
  margin: 20px;
  width: calc(100% - 40px);
}

.dish-image {
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

.image-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all 0.3s;
}

.image-uploader:hover {
  border-color: #409eff;
}

.uploaded-image {
  width: 178px;
  height: 178px;
  display: block;
  object-fit: cover;
}

.uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
  line-height: 178px;
}

.upload-tip {
  font-size: 12px;
  color: #999;
  margin-top: 8px;
}
</style>
