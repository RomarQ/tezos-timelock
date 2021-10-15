import path from 'path';
import typescript from '@rollup/plugin-typescript';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import pkg from './package.json';

const config = {
    input: 'src/index.ts',
    output: [
        {
            file: pkg.main,
            strict: false,
            format: 'cjs',
            exports: 'default',
            banner: `/* === Version: ${pkg.version} === */`,
        },
    ],
    plugins: [
        commonjs(),
        json(),
        typescript({
            tsconfig: path.resolve(__dirname, './tsconfig.prod.json'),
        }),
        terser()
    ],
};

export default config;
