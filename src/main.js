import {createApp} from 'vue'
import App from './App.vue'

import ElementPlus from 'element-plus'
import 'element-plus/lib/theme-chalk/index.css'
import '@fortawesome/fontawesome-free/css/all.min.css'
import store from '@/js/store.js'

createApp(App).use(ElementPlus).use(store).mount('#app')
