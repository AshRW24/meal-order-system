<template>
  <div class="order-container">
    <!-- 搜索筛选区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="searchForm.orderNumber" placeholder="请输入订单号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="用户ID">
          <el-input v-model.number="searchForm.userId" placeholder="请输入用户ID" clearable style="width: 150px" />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable style="width: 150px">
            <el-option label="待支付" :value="1" />
            <el-option label="待发货" :value="2" />
            <el-option label="已发货" :value="3" />
            <el-option label="已完成" :value="4" />
            <el-option label="已取消" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="id" label="订单ID" width="100" />
        <el-table-column prop="orderNumber" label="订单号" min-width="150" show-overflow-tooltip />
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column prop="consignee" label="收货人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="130" show-overflow-tooltip />
        <el-table-column prop="amount" label="订单金额" width="120">
          <template #default="{ row }">¥{{ row.amount }}</template>
        </el-table-column>
        <el-table-column prop="status" label="订单状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="orderTime" label="下单时间" width="170" show-overflow-tooltip />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" link @click="handleViewDetails(row)">详情</el-button>
            <!-- 快捷发货按钮：状态为 1(待确认) 或 2(待发货) 时显示 -->
            <el-button 
              v-if="row.status === 1 || row.status === 2" 
              type="success" 
              size="small" 
              link 
              @click="handleShip(row)"
            >发货</el-button>
            <el-button type="warning" size="small" link @click="handleUpdateStatus(row)">改状态</el-button>
            <el-button type="danger" size="small" link @click="handleDelete(row)">删除</el-button>
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

    <!-- 订单详情对话框 -->
    <el-dialog
      v-model="detailsDialogVisible"
      title="订单详情"
      width="700px"
      :close-on-click-modal="false"
    >
      <div v-if="selectedOrder" class="order-details">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单号">{{ selectedOrder.orderNumber }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ selectedOrder.userId }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ selectedOrder.consignee }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ selectedOrder.phone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ selectedOrder.address }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">¥{{ selectedOrder.amount }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusType(selectedOrder.status)">{{ getStatusText(selectedOrder.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="下单时间" :span="2">{{ selectedOrder.orderTime }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ selectedOrder.remark || '无' }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>

    <!-- 修改状态对话框 -->
    <el-dialog
      v-model="statusDialogVisible"
      title="修改订单状态"
      width="400px"
      :close-on-click-modal="false"
    >
      <el-form v-if="selectedOrder" :model="statusForm" label-width="100px">
        <el-form-item label="当前状态">
          <el-tag :type="getStatusType(selectedOrder.status)">{{ getStatusText(selectedOrder.status) }}</el-tag>
        </el-form-item>
        <el-form-item label="新状态">
          <el-select v-model="statusForm.status" placeholder="请选择新状态" style="width: 100%">
            <el-option label="待支付" :value="1" />
            <el-option label="待发货" :value="2" />
            <el-option label="已发货" :value="3" />
            <el-option label="已完成" :value="4" />
            <el-option label="已取消" :value="5" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmStatusUpdate">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getOrderPage, updateOrderStatus, deleteOrder } from '../api/order'

// 搜索表单
const searchForm = reactive({
  orderNumber: '',
  userId: null,
  status: null
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 分页
const pagination = reactive({
  page: 1,
  pageSize: 10,
  total: 0
})

// 订单详情对话框
const detailsDialogVisible = ref(false)
const selectedOrder = ref(null)

// 状态修改对话框
const statusDialogVisible = ref(false)
const statusForm = reactive({
  status: null
})

// 初始化
onMounted(() => {
  loadTableData()
})

// 加载表格数据
const loadTableData = async () => {
  loading.value = true
  try {
    const res = await getOrderPage({
      page: pagination.page,
      pageSize: pagination.pageSize,
      orderNumber: searchForm.orderNumber || undefined,
      userId: searchForm.userId || undefined,
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

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadTableData()
}

// 重置
const handleReset = () => {
  searchForm.orderNumber = ''
  searchForm.userId = null
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

// 查看详情
const handleViewDetails = (row) => {
  selectedOrder.value = row
  detailsDialogVisible.value = true
}

// 修改状态
const handleUpdateStatus = (row) => {
  selectedOrder.value = row
  statusForm.status = row.status
  statusDialogVisible.value = true
}

// 确认修改状态
const handleConfirmStatusUpdate = async () => {
  try {
    const res = await updateOrderStatus(selectedOrder.value.id, statusForm.status)
    if (res.code === 200) {
      ElMessage.success('订单状态已更新')
      statusDialogVisible.value = false
      loadTableData()
    }
  } catch (error) {
    ElMessage.error('更新失败')
  }
}

// 删除
const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除订单"${row.orderNumber}"吗？`, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await deleteOrder(row.id)
      if (res.code === 200) {
        ElMessage.success('删除成功')
        loadTableData()
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 快捷发货
const handleShip = (row) => {
  ElMessageBox.confirm(`确定要对订单 "${row.orderNumber}" 进行发货操作吗？`, '发货确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'success'
  }).then(async () => {
    try {
      // 状态 3 表示已发货/配送中
      const res = await updateOrderStatus(row.id, 3)
      if (res.code === 200) {
        ElMessage.success('发货成功')
        loadTableData()
      }
    } catch (error) {
      ElMessage.error('操作失败')
    }
  })
}

// 获取状态文本
const getStatusText = (status) => {
  const statusMap = {
    1: '待支付',
    2: '待发货',
    3: '已发货',
    4: '已完成',
    5: '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取状态标签类型
const getStatusType = (status) => {
  const typeMap = {
    1: 'warning',
    2: 'info',
    3: 'primary',
    4: 'success',
    5: 'danger'
  }
  return typeMap[status] || 'info'
}
</script>

<style scoped>
.order-container {
  padding: 0;
  width: 100%;
}

.search-card,
.table-card {
  margin: 20px;
  width: calc(100% - 40px);
}

.pagination {
  margin-top: 20px;
  justify-content: flex-end;
}

.order-details {
  padding: 20px 0;
}
</style>
