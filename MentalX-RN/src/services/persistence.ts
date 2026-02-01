import AsyncStorage from '@react-native-async-storage/async-storage';
import { GameResult, GameMode, Question } from '../types';

const RESULTS_KEY = 'gameResults';
const MAX_RESULTS = 2000;

class PersistenceService {
    async loadResults(): Promise<GameResult[]> {
        try {
            const data = await AsyncStorage.getItem(RESULTS_KEY);
            if (!data) return [];
            const parsed = JSON.parse(data);
            return parsed.map((item: any) => ({
                ...item,
                timestamp: new Date(item.timestamp),
            }));
        } catch (error) {
            console.error('Failed to load results:', error);
            return [];
        }
    }

    async getHighScore(mode: GameMode): Promise<number> {
        try {
            const stored = await AsyncStorage.getItem(`highScore_${mode}`);
            return stored ? parseInt(stored, 10) : 0;
        } catch (error) {
            console.error('Failed to load high score:', error);
            return 0;
        }
    }

    async saveHighScore(mode: GameMode, score: number): Promise<void> {
        try {
            const current = await this.getHighScore(mode);
            if (score > current) {
                await AsyncStorage.setItem(`highScore_${mode}`, score.toString());
            }
        } catch (error) {
            console.error('Failed to save high score:', error);
        }
    }

    async saveResult(result: GameResult): Promise<void> {
        try {
            const existing = await this.loadResults();
            const updated = [result, ...existing];
            if (updated.length > MAX_RESULTS) {
                updated.splice(MAX_RESULTS);
            }
            await AsyncStorage.setItem(RESULTS_KEY, JSON.stringify(updated));
        } catch (error) {
            console.error('Failed to save result:', error);
        }
    }

    createGameResult(
        mode: GameMode,
        question: Question,
        userAnswer: number,
        responseTime: number,
        isCorrect: boolean
    ): GameResult {
        return {
            id: Math.random().toString(36).substr(2, 9),
            mode,
            question: question.text,
            answer: question.answer,
            userAnswer,
            isCorrect,
            responseTime,
            timestamp: new Date(),
        };
    }
}

export const persistenceService = new PersistenceService();
