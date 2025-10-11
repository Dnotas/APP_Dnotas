<template>
  <div id="app" class="min-h-screen bg-gray-950 text-white font-inter">
    <RouterView />
  </div>
</template>

<script setup lang="ts">
import { RouterView } from 'vue-router'
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

onMounted(() => {
  // Verificar se há token salvo
  authStore.initializeAuth()
})
</script>