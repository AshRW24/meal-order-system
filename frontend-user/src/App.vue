<template>
  <GlobalNotification />
  <ChatBotWindow />
  <router-view />
</template>

<script setup>
import GlobalNotification from './components/GlobalNotification.vue'
import ChatBotWindow from './components/ChatBotWindow.vue'
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: "PingFang SC", "Microsoft YaHei", "Helvetica Neue", Arial, sans-serif;
  width: 100%;
  height: 100vh;
  overflow: hidden;
  color: #000000;
}
</style>
