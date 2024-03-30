import { UCard } from './.nuxt/components';
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: {
    enabled: true,

    timeline: {
      enabled: true
    }
  },
  srcDir: 'src',
  modules: ['@nuxt/ui'],
  colorMode: {
    classSuffix: '',
  },
  ui: {
    icons: ['solar', 'ri'],
    primary: "#0f172a"
  },
  runtimeConfig: {
    public: {
      appName: 'QubitCo'
    },
  }
})
