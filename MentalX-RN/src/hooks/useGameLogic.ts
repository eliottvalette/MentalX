import { useState, useEffect, useRef } from 'react';
import { GameMode, Question, OperationType } from '../types';
import { questionGenerator } from '../utils/questionGenerator';
import { hapticManager } from '../utils/haptics';
import { persistenceService } from '../services/persistence';

const MAX_TIME = 60.0;

export const useGameLogic = (mode: GameMode) => {
    const [currentQuestion, setCurrentQuestion] = useState<Question | null>(null);
    const [input, setInput] = useState('');
    const [timeRemaining, setTimeRemaining] = useState(mode === GameMode.SPRINT ? MAX_TIME : 0);
    const [score, setScore] = useState(0);
    const [isGameOver, setIsGameOver] = useState(false);

    const questionStartTime = useRef<Date | null>(null);
    const timerInterval = useRef<NodeJS.Timeout | null>(null);

    const nextQuestion = () => {
        let question: Question;
        if (mode === GameMode.TRAINING) {
            question = questionGenerator.generateWeighted();
        } else {
            const types = [OperationType.ADDITION, OperationType.MULTIPLICATION];
            const randomType = types[Math.floor(Math.random() * types.length)];
            question = questionGenerator.generate(randomType);
        }
        setCurrentQuestion(question);
        questionStartTime.current = new Date();
    };

    const startTimer = () => {
        timerInterval.current = setInterval(() => {
            setTimeRemaining((prev) => {
                if (prev <= 0) {
                    endGame();
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);
    };

    const endGame = () => {
        setIsGameOver(true);
        if (timerInterval.current) {
            clearInterval(timerInterval.current);
        }
    };

    const handleCorrectAnswer = async (playerAnswer: number) => {
        hapticManager.playSuccess();
        setScore((prev) => prev + 1);
        await logResult(playerAnswer);
        setInput('');
        nextQuestion();
    };

    const handleWrongAnswer = async (playerAnswer: number) => {
        hapticManager.playError();
        await logResult(playerAnswer);
        setInput('');

        if (mode === GameMode.MARATHON) {
            endGame();
        }
    };

    const logResult = async (playerAnswer: number) => {
        if (!currentQuestion || !questionStartTime.current) return;

        const responseTime = (new Date().getTime() - questionStartTime.current.getTime()) / 1000;
        const result = persistenceService.createGameResult(
            mode,
            currentQuestion,
            playerAnswer,
            responseTime
        );
        await persistenceService.saveResult(result);
    };

    const validateAnswer = (playerAnswer: number) => {
        if (!currentQuestion) return;

        if (playerAnswer === currentQuestion.answer) {
            handleCorrectAnswer(playerAnswer);
        } else if (String(playerAnswer).length >= String(currentQuestion.answer).length) {
            handleWrongAnswer(playerAnswer);
        }
    };

    const submitInput = (value: string) => {
        const newInput = input + value;
        setInput(newInput);
        const playerAnswer = parseInt(newInput, 10);
        if (!isNaN(playerAnswer)) {
            validateAnswer(playerAnswer);
        }
    };

    const deleteInput = () => {
        if (input.length > 0) {
            setInput(input.slice(0, -1));
        }
    };

    useEffect(() => {
        setScore(0);
        setInput('');
        setIsGameOver(false);
        setTimeRemaining(mode === GameMode.SPRINT ? MAX_TIME : 0);
        nextQuestion();

        if (mode === GameMode.SPRINT) {
            startTimer();
        }

        return () => {
            if (timerInterval.current) {
                clearInterval(timerInterval.current);
            }
        };
    }, [mode]);

    return {
        currentQuestion,
        input,
        timeRemaining,
        score,
        isGameOver,
        submitInput,
        deleteInput,
    };
};
