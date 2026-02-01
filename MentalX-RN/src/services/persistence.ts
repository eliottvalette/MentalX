import AsyncStorage from '@react-native-async-storage/async-storage';
import { GameResult, GameMode, Question } from '../types';

const RESULTS_KEY = 'gameResults';
const MAX_RESULTS = 1000;

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
        responseTime: number
    ): GameResult {
        return {
            id: Math.random().toString(36).substr(2, 9),
            mode,
            question: question.text,
            answer: question.answer,
            userAnswer,
            isCorrect: userAnswer === question.answer,
            responseTime,
            timestamp: new Date(),
        };
    }
}

export const persistenceService = new PersistenceService();
