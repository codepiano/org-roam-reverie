import {defineConfig} from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'


/**
 * @type {import('vite').UserConfig}
 */
export default defineConfig({
    plugins: [vue()],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './src'),
        },
    },
    server: {
        proxy: {
            '/roam-data': {
                target: 'http://localhost:8080',
                changeOrigin: true,
                secure: false
            }
        }
    }
})
