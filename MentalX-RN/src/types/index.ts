export enum GameMode {
    SPRINT = 'sprint',
    MARATHON = 'marathon',
    TRAINING = 'training',
}

export enum OperationType {
    ADDITION = 'addition',
    MULTIPLICATION = 'multiplication',
}

export enum SRSStatus {
    CRITICAL = 'critical',
    UNSTABLE = 'unstable',
    STABLE = 'stable',
}

export interface Question {
    id: string;
    text: string;
    answer: number;
    type: OperationType;
}

export interface GameResult {
    id: string;
    mode: GameMode;
    question: string;
    answer: number;
    userAnswer: number;
    isCorrect: boolean;
    responseTime: number;
    timestamp: Date;
}

export interface SRSItem {
    id: string;
    operation: string;
    avgTime: number;
    errorRate: number;
    mastery: number;
    lastSeen: Date;
    status: SRSStatus;
}
