<template>
  <div class="sales-statistics">
    <!-- Header -->
    <div class="header">
      <h1>Sales Analytics Dashboard</h1>
      <p class="subtitle">Real-time sales data and trends visualization</p>
    </div>

    <!-- Controls -->
    <div class="controls">
      <el-select v-model="dateRange" placeholder="Select date range" class="range-select">
        <el-option label="Last 7 days" value="7" />
        <el-option label="Last 14 days" value="14" />
        <el-option label="Last 30 days" value="30" />
      </el-select>
      <el-button type="primary" @click="refreshData">Refresh Data</el-button>
    </div>

    <!-- Statistics Cards -->
    <div class="statistics-cards">
      <div class="card">
        <div class="card-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)">
          📦
        </div>
        <div class="card-content">
          <p class="label">Total Orders</p>
          <p class="value">{{ statistics.totalOrders || 0 }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">
          💰
        </div>
        <div class="card-content">
          <p class="label">Total Revenue</p>
          <p class="value">${{ statistics.totalRevenue || '0.00' }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)">
          📈
        </div>
        <div class="card-content">
          <p class="label">Avg Order Value</p>
          <p class="value">${{ ((statistics.totalRevenue || 0) / (statistics.totalOrders || 1)).toFixed(2) }}</p>
        </div>
      </div>

      <div class="card">
        <div class="card-icon" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%)">
          ⭐
        </div>
        <div class="card-content">
          <p class="label">Top Category</p>
          <p class="value">{{ topCategory || '-' }}</p>
        </div>
      </div>
    </div>

    <!-- Charts Grid -->
    <div class="charts-container">
      <!-- Sales Trend Chart -->
      <div class="chart-card">
        <h3>Sales Trend (Last {{ dateRange }} Days)</h3>
        <v-chart :option="salesTrendOption" autoresize />
      </div>

      <!-- Revenue Trend Chart -->
      <div class="chart-card">
        <h3>Cumulative Revenue Trend</h3>
        <v-chart :option="revenueTrendOption" autoresize />
      </div>

      <!-- Category Sales Chart -->
      <div class="chart-card">
        <h3>Sales by Category</h3>
        <v-chart :option="categorySalesOption" autoresize />
      </div>

      <!-- Top Dishes Chart -->
      <div class="chart-card">
        <h3>Top 10 Selling Dishes</h3>
        <v-chart :option="topDishesOption" autoresize />
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-overlay">
      <el-spin size="large" description="Loading data..." />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, BarChart, PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  ToolboxComponent
} from 'echarts/components'

import {
  getSalesStatistics,
  getTopDishes,
  getSalesByCategory,
  getRevenueTrends
} from '../api/sales'

use([
  CanvasRenderer,
  LineChart,
  BarChart,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  ToolboxComponent
])

// State
const dateRange = ref('7')
const loading = ref(false)
const statistics = ref({
  totalOrders: 0,
  totalRevenue: '0.00'
})
const salesData = ref({
  dates: [],
  salesVolume: [],
  salesAmount: []
})
const categoryData = ref({
  categories: [],
  sales: []
})
const dishesData = ref({
  dishNames: [],
  quantities: [],
  revenues: []
})
const revenueData = ref({
  dates: [],
  cumulativeRevenue: []
})

// Computed Properties
const topCategory = computed(() => {
  if (!categoryData.value.categories || categoryData.value.categories.length === 0) {
    return '-'
  }
  const maxIndex = categoryData.value.sales.indexOf(Math.max(...categoryData.value.sales))
  return categoryData.value.categories[maxIndex] || '-'
})

const salesTrendOption = computed(() => ({
  responsive: true,
  title: {
    text: '',
    textStyle: { color: '#333' }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(50, 50, 50, 0.9)',
    borderColor: '#333',
    textStyle: { color: '#fff' }
  },
  legend: {
    top: 'bottom',
    textStyle: { color: '#666' }
  },
  grid: {
    left: '3%',
    right: '3%',
    top: '5%',
    bottom: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: salesData.value.dates,
    axisLine: { lineStyle: { color: '#ddd' } },
    axisLabel: { color: '#666', fontSize: 12 }
  },
  yAxis: [
    {
      type: 'value',
      name: 'Orders',
      position: 'left',
      axisLine: { lineStyle: { color: '#667eea' } },
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f0f0f0' } }
    },
    {
      type: 'value',
      name: 'Revenue ($)',
      position: 'right',
      axisLine: { lineStyle: { color: '#f093fb' } },
      axisLabel: { color: '#666' },
      splitLine: { show: false }
    }
  ],
  series: [
    {
      name: 'Orders',
      data: salesData.value.salesVolume,
      type: 'line',
      smooth: true,
      yAxisIndex: 0,
      itemStyle: {
        color: '#667eea',
        borderWidth: 2
      },
      areaStyle: {
        color: 'rgba(102, 126, 234, 0.1)'
      }
    },
    {
      name: 'Revenue ($)',
      data: salesData.value.salesAmount,
      type: 'line',
      smooth: true,
      yAxisIndex: 1,
      itemStyle: {
        color: '#f093fb',
        borderWidth: 2
      },
      areaStyle: {
        color: 'rgba(240, 147, 251, 0.1)'
      }
    }
  ]
}))

const revenueTrendOption = computed(() => ({
  responsive: true,
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(50, 50, 50, 0.9)',
    borderColor: '#333',
    textStyle: { color: '#fff' }
  },
  legend: {
    top: 'bottom',
    textStyle: { color: '#666' }
  },
  grid: {
    left: '3%',
    right: '3%',
    top: '5%',
    bottom: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: revenueData.value.dates,
    axisLine: { lineStyle: { color: '#ddd' } },
    axisLabel: { color: '#666', fontSize: 12 }
  },
  yAxis: {
    type: 'value',
    axisLine: { lineStyle: { color: '#ddd' } },
    axisLabel: { color: '#666' },
    splitLine: { lineStyle: { color: '#f0f0f0' } }
  },
  series: [
    {
      name: 'Cumulative Revenue',
      data: revenueData.value.cumulativeRevenue,
      type: 'line',
      smooth: true,
      itemStyle: {
        color: '#4facfe',
        borderWidth: 2
      },
      areaStyle: {
        color: 'rgba(79, 172, 254, 0.1)'
      }
    }
  ]
}))

const categorySalesOption = computed(() => ({
  responsive: true,
  tooltip: {
    trigger: 'item',
    backgroundColor: 'rgba(50, 50, 50, 0.9)',
    borderColor: '#333',
    textStyle: { color: '#fff' }
  },
  legend: {
    bottom: 0,
    textStyle: { color: '#666' }
  },
  series: [
    {
      name: 'Sales',
      type: 'pie',
      radius: ['30%', '70%'],
      data: categoryData.value.categories.map((cat, idx) => ({
        value: categoryData.value.sales[idx] || 0,
        name: cat
      })),
      itemStyle: {
        borderRadius: 8,
        borderColor: '#fff',
        borderWidth: 2
      }
    }
  ]
}))

const topDishesOption = computed(() => ({
  responsive: true,
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(50, 50, 50, 0.9)',
    borderColor: '#333',
    textStyle: { color: '#fff' }
  },
  legend: {
    bottom: 0,
    textStyle: { color: '#666' }
  },
  grid: {
    left: '3%',
    right: '3%',
    top: '5%',
    bottom: '15%',
    containLabel: true
  },
  xAxis: {
    type: 'value',
    axisLine: { lineStyle: { color: '#ddd' } },
    axisLabel: { color: '#666' },
    splitLine: { lineStyle: { color: '#f0f0f0' } }
  },
  yAxis: {
    type: 'category',
    data: dishesData.value.dishNames,
    axisLine: { lineStyle: { color: '#ddd' } },
    axisLabel: { color: '#666', fontSize: 12 }
  },
  series: [
    {
      name: 'Quantity',
      data: dishesData.value.quantities,
      type: 'bar',
      itemStyle: {
        color: new (require('echarts').graphic).LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#667eea' },
          { offset: 1, color: '#764ba2' }
        ]),
        borderRadius: [0, 8, 8, 0]
      }
    }
  ]
}))

// Methods
const loadData = async () => {
  loading.value = true
  try {
    const [statsRes, dishRes, catRes, revenueRes] = await Promise.all([
      getSalesStatistics({ days: dateRange.value }),
      getTopDishes(10),
      getSalesByCategory(),
      getRevenueTrends(parseInt(dateRange.value))
    ])

    if (statsRes.code === 200) {
      statistics.value = statsRes.data
      salesData.value = statsRes.data
    }

    if (dishRes.code === 200) {
      dishesData.value = dishRes.data
    }

    if (catRes.code === 200) {
      categoryData.value = catRes.data
    }

    if (revenueRes.code === 200) {
      revenueData.value = revenueRes.data
    }

    ElMessage.success('Data loaded successfully')
  } catch (error) {
    console.error('Failed to load data:', error)
    ElMessage.error('Failed to load sales data')
  } finally {
    loading.value = false
  }
}

const refreshData = () => {
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.sales-statistics {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  min-height: 100vh;
  position: relative;
}

.header {
  margin-bottom: 32px;
  text-align: center;
}

.header h1 {
  font-size: 32px;
  font-weight: bold;
  color: #333;
  margin: 0 0 8px 0;
}

.header .subtitle {
  font-size: 14px;
  color: #999;
  margin: 0;
}

.controls {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  justify-content: flex-end;
}

.range-select {
  width: 200px;
}

.statistics-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.card-icon {
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  border-radius: 12px;
  flex-shrink: 0;
}

.card-content {
  flex: 1;
}

.card-content .label {
  font-size: 12px;
  color: #999;
  margin: 0 0 6px 0;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.card-content .value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  margin: 0;
}

.charts-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.chart-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.chart-card:hover {
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.chart-card h3 {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
  color: #333;
  padding-bottom: 12px;
  border-bottom: 2px solid #f0f0f0;
}

.chart-card :deep(.v-chart) {
  height: 350px;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

@media (max-width: 1200px) {
  .charts-container {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .sales-statistics {
    padding: 16px;
  }

  .header h1 {
    font-size: 24px;
  }

  .statistics-cards {
    grid-template-columns: 1fr;
  }

  .controls {
    flex-direction: column;
  }

  .range-select {
    width: 100%;
  }
}
</style>
