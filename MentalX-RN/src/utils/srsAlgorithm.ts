import { SRSStatus } from '../types';

const MIN_SCORE = 3;

export const calculateQuality = (isCorrect: boolean, time: number): number => {
    if (!isCorrect) return 0;
    if (time < 2.5) return 5;
    if (time < 5.0) return 4;
    if (time < 10.0) return 3;
    return 3;
};

export const updateSRSItem = (
    currentInterval: number,
    currentRepetitions: number,
    currentEF: number,
    quality: number
) => {
    let nextInterval: number;
    let nextRepetitions: number;
    let nextEF: number;

    if (quality < MIN_SCORE) {
        nextRepetitions = 0;
        nextInterval = 1;
        nextEF = currentEF;
    } else {
        nextEF = currentEF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
        if (nextEF < 1.3) nextEF = 1.3;

        nextRepetitions = currentRepetitions + 1;

        if (nextRepetitions === 1) {
            nextInterval = 1;
        } else if (nextRepetitions === 2) {
            nextInterval = 6;
        } else {
            nextInterval = Math.round(currentInterval * nextEF);
        }
    }

    return { nextInterval, nextRepetitions, nextEF };
};

export const calculateMastery = (interval: number): number => {
    return Math.min(Math.max(interval / 21.0, 0), 1.0);
};

export const interpolateColor = (mastery: number): string => {
    let r, g, b;

    if (mastery < 0.5) {
        const t = mastery * 2;
        r = 255;
        g = Math.round(59 + (149 - 59) * t);
        b = Math.round(48 + (0 - 48) * t);
    } else {
        const t = (mastery - 0.5) * 2;
        r = Math.round(255 + (50 - 255) * t);
        g = Math.round(149 + (215 - 149) * t);
        b = Math.round(0 + (75 - 0) * t);
    }

    return `rgb(${r}, ${g}, ${b})`;
};

export const getStatusFromMastery = (mastery: number): SRSStatus => {
    if (mastery < 0.3) return SRSStatus.CRITICAL;
    if (mastery < 0.7) return SRSStatus.UNSTABLE;
    return SRSStatus.STABLE;
};
