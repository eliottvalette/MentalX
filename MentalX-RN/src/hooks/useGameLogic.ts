import { useState, useEffect, useRef } from 'react';
import { GameMode, Question, OperationType } from '../types';
import { questionGenerator } from '../utils/questionGenerator';
import { hapticManager } from '../utils/haptics';
import { persistenceService } from '../services/persistence';

const SPRINT_TIME = 60.0;
const MARATHON_QUESTION_TIME = 10.0;
const MAX_LIVES = 3;

export const useGameLogic = (mode: GameMode) => {
    const [currentQuestion, setCurrentQuestion] = useState<Question | null>(null);
    const [input, setInput] = useState('');

    const [globalTimeRemaining, setGlobalTimeRemaining] = useState(mode === GameMode.SPRINT ? SPRINT_TIME : 0);
    const [questionTimeProgress, setQuestionTimeProgress] = useState(1.0);

    const [score, setScore] = useState(0);
    const [lives, setLives] = useState(MAX_LIVES);
    const [isGameOver, setIsGameOver] = useState(false);
    const [successTrigger, setSuccessTrigger] = useState(0);
    const [errorTrigger, setErrorTrigger] = useState(0);

    const questionStartTime = useRef<Date | null>(null);
    const globalTimer = useRef<NodeJS.Timeout | null>(null);
    const questionTimer = useRef<NodeJS.Timeout | null>(null);

    const nextQuestion = () => {
        let question: Question;
        // La génération reste spécifique :
        // Training = On cible tes faiblesses
        // Sprint/Marathon = Aléatoire pour tester la vitesse globale
        if (mode === GameMode.TRAINING) {
            question = questionGenerator.generateWeighted();
        } else {
            const types = [OperationType.ADDITION, OperationType.MULTIPLICATION];
            const randomType = types[Math.floor(Math.random() * types.length)];
            question = questionGenerator.generate(randomType);
        }

        setCurrentQuestion(question);
        setInput('');
        questionStartTime.current = new Date();

        if (mode === GameMode.MARATHON) {
            startQuestionTimer();
        }
    };

    const startGlobalTimer = () => {
        if (mode !== GameMode.SPRINT) return;

        globalTimer.current = setInterval(() => {
            setGlobalTimeRemaining((prev) => {
                if (prev <= 1) {
                    endGame();
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);
    };

    const startQuestionTimer = () => {
        if (questionTimer.current) clearInterval(questionTimer.current);
        setQuestionTimeProgress(1.0);

        const step = 16; // 60fps for smooth animation
        const totalSteps = (MARATHON_QUESTION_TIME * 1000) / step;
        let currentStep = 0;

        questionTimer.current = setInterval(() => {
            currentStep++;
            const progress = 1.0 - (currentStep / totalSteps);
            setQuestionTimeProgress(progress);

            if (progress <= 0) {
                handleMarathonTimeout();
            }
        }, step);
    };

    const handleMarathonTimeout = () => {
        if (questionTimer.current) clearInterval(questionTimer.current);
        setErrorTrigger((prev) => prev + 1);
        hapticManager.playError();
        loseLife();
    };

    const loseLife = () => {
        setLives((prev) => {
            const newLives = prev - 1;
            if (newLives <= 0) {
                endGame();
                return 0;
            }
            nextQuestion();
            return newLives;
        });
    };

    const endGame = async () => {
        setIsGameOver(true);
        clearIntervals();
        await persistenceService.saveHighScore(mode, score);
    };

    const clearIntervals = () => {
        if (globalTimer.current) clearInterval(globalTimer.current);
        if (questionTimer.current) clearInterval(questionTimer.current);
    };

    const validateAnswer = (playerAnswer: number) => {
        if (!currentQuestion) return;

        const isCorrect = playerAnswer === currentQuestion.answer;

        logResult(playerAnswer, isCorrect);

        if (isCorrect) {
            hapticManager.playSuccess();
            setSuccessTrigger((prev) => prev + 1);
            setScore((s) => s + 1);
            nextQuestion();
        } else if (String(playerAnswer).length >= String(currentQuestion.answer).length) {
            hapticManager.playError();
            setErrorTrigger((prev) => prev + 1);

            if (mode === GameMode.MARATHON) {
                loseLife();
            } else {
                setInput('');
            }
        }
    };

    const logResult = async (playerAnswer: number, isCorrect: boolean) => {
        if (!currentQuestion || !questionStartTime.current) return;
        const responseTime = (new Date().getTime() - questionStartTime.current.getTime()) / 1000;

        // 1. Sauvegarde le log brut (Historique global)
        const result = persistenceService.createGameResult(
            mode,
            currentQuestion,
            playerAnswer,
            responseTime,
            isCorrect
        );
        await persistenceService.saveResult(result);

        // 2. Mise à jour Algo SRS (POUR TOUS LES MODES MAINTENANT)
        // On a retiré le `if (mode === GameMode.TRAINING)`
        await persistenceService.updateSRS(
            currentQuestion.text,
            isCorrect,
            responseTime
        );
    };

    const submitInput = (value: string) => {
        const newInput = input + value;
        setInput(newInput);
        const val = parseInt(newInput, 10);
        if (!isNaN(val)) validateAnswer(val);
    };

    const deleteInput = () => {
        setInput((prev) => prev.slice(0, -1));
    };

    useEffect(() => {
        setScore(0);
        setLives(MAX_LIVES);
        setIsGameOver(false);
        setGlobalTimeRemaining(mode === GameMode.SPRINT ? SPRINT_TIME : 0);

        nextQuestion();
        startGlobalTimer();

        return () => clearIntervals();
    }, [mode]);

    return {
        currentQuestion,
        input,
        globalTimeRemaining,
        questionTimeProgress,
        score,
        lives,
        isGameOver,
        successTrigger,
        errorTrigger,
        submitInput,
        deleteInput,
    };
};