import express from 'express';
import { assetsPath } from './shared/path.js';

export const trim = (str: string): string => str.replace(/\/*$/, '');
export const serveStatic = (path: string) : any => express.static(assetsPath(path));
