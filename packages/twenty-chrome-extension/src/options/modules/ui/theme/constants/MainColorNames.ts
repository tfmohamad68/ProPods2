import { MAIN_COLORS } from '@/ui/theme/constants/MainColors';

export const MAIN_COLOR_NAMES = Object.keys(MAIN_COLORS) as ThemeColor[];

export type ThemeColor = keyof typeof MAIN_COLORS;
