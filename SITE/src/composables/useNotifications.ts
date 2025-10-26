import { ref } from 'vue'

interface NotificationData {
  title: string
  body: string
  icon?: string
}

export function useNotifications() {
  const isSupported = ref(false)
  const isPermissionGranted = ref(false)

  // Verificar suporte a notificações
  const checkSupport = () => {
    isSupported.value = 'Notification' in window
    isPermissionGranted.value = Notification.permission === 'granted'
  }

  // Solicitar permissão
  const requestPermission = async () => {
    if (!isSupported.value) return false

    const permission = await Notification.requestPermission()
    isPermissionGranted.value = permission === 'granted'
    return isPermissionGranted.value
  }

  // Tocar som de notificação
  const playNotificationSound = () => {
    try {
      // Criar um som de notificação usando Web Audio API
      const audioContext = new (window.AudioContext || window.webkitAudioContext)()
      const oscillator = audioContext.createOscillator()
      const gainNode = audioContext.createGain()
      
      oscillator.connect(gainNode)
      gainNode.connect(audioContext.destination)
      
      oscillator.frequency.value = 800
      oscillator.type = 'sine'
      
      gainNode.gain.setValueAtTime(0.3, audioContext.currentTime)
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5)
      
      oscillator.start(audioContext.currentTime)
      oscillator.stop(audioContext.currentTime + 0.5)
    } catch (error) {
      console.log('Erro ao criar som:', error)
      // Fallback: tentar usar arquivo mp3 se existir
      try {
        const audio = new Audio('/notification.mp3')
        audio.volume = 0.5
        audio.play().catch(() => {})
      } catch (e) {
        console.log('Fallback de áudio falhou')
      }
    }
  }

  // Mostrar notificação
  const showNotification = (data: NotificationData) => {
    // Tocar som sempre
    playNotificationSound()

    // Mostrar notificação do sistema se permitido
    if (isPermissionGranted.value) {
      const notification = new Notification(data.title, {
        body: data.body,
        icon: data.icon || '/favicon.ico',
        tag: 'dnotas-chat',
        renotify: true
      })

      // Auto-fechar após 5 segundos
      setTimeout(() => {
        notification.close()
      }, 5000)

      return notification
    }

    return null
  }

  // Mostrar notificação de nova mensagem
  const notifyNewMessage = (clienteName: string, message: string) => {
    showNotification({
      title: `Nova mensagem de ${clienteName}`,
      body: message.length > 50 ? message.substring(0, 50) + '...' : message,
      icon: '/favicon.ico'
    })
  }

  // Mostrar notificação de nova conversa
  const notifyNewConversation = (clienteName: string, title: string) => {
    showNotification({
      title: `Nova conversa iniciada`,
      body: `${clienteName}: ${title}`,
      icon: '/favicon.ico'
    })
  }

  return {
    isSupported,
    isPermissionGranted,
    checkSupport,
    requestPermission,
    showNotification,
    notifyNewMessage,
    notifyNewConversation,
    playNotificationSound
  }
}