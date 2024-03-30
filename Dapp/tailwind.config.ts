import type { Config } from 'tailwindcss';

export default <Partial<Config>>{
    // 安全列表 自定义过的类放在这里，防止扫描丢失
    safelist: [],

    // 主题
    theme: {
        extend: {
            aspectRatio: {
                '4/3': '4 / 3',
                '1/1': '1 / 1',
            },
        },
    },

    // 暗色模式
    darkMode: 'class',
}