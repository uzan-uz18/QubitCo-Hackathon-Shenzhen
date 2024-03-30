import { UCard } from './.nuxt/components';
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ssr: false,
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
      appName: 'QubitCo',
      daoId: "0x94015e7a090a9bc92c343fe6629018e8a860a4f6b17a4a60babdab32fb2ee012",
      addrModules: "0xceb1952b202180a3c222a037d45a89e39db8c4227a7e47b5da30f1169bb2791d::DaoProposeVoteScriptAptosCoin::"
    },
  }
})
