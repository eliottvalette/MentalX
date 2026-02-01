import { GameResult, SRSItem, SRSStatus } from '../types';

export const calculateSRSItems = (results: GameResult[]): SRSItem[] => {
    const groupedByQuestion: { [key: string]: GameResult[] } = {};

    results.forEach((result) => {
        if (!groupedByQuestion[result.question]) {
            groupedByQuestion[result.question] = [];
        }
        groupedByQuestion[result.question].push(result);
    });

    const items: SRSItem[] = [];

    Object.entries(groupedByQuestion).forEach(([question, attempts]) => {
        if (attempts.length < 3) return;

        const avgTime = attempts.reduce((sum, a) => sum + a.responseTime, 0) / attempts.length;
        const errorCount = attempts.filter((a) => !a.isCorrect).length;
        const errorRate = errorCount / attempts.length;
        const correctCount = attempts.length - errorCount;
        const mastery = Math.max(
            0.0,
            Math.min(1.0, (correctCount / attempts.length) * (1.0 - Math.min(avgTime / 5.0, 0.5)))
        );

        let status: SRSStatus;
        if (mastery < 0.4) {
            status = SRSStatus.CRITICAL;
        } else if (mastery < 0.8) {
            status = SRSStatus.UNSTABLE;
        } else {
            status = SRSStatus.STABLE;
        }

        items.push({
            id: Math.random().toString(36).substr(2, 9),
            operation: question,
            avgTime,
            errorRate,
            mastery,
            lastSeen: attempts[0]?.timestamp || new Date(),
            status,
        });
    });

    return items.sort((a, b) => a.mastery - b.mastery);
};
