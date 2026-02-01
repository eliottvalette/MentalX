import { Question, OperationType } from '../types';

export const questionGenerator = {
    generate: (type: OperationType): Question => {
        switch (type) {
            case OperationType.ADDITION: {
                const a = Math.floor(Math.random() * 50000) + 1;
                const b = Math.floor(Math.random() * 49999) + 1;
                return {
                    id: Math.random().toString(36).substr(2, 9),
                    text: `${a} + ${b}`,
                    answer: a + b,
                    type: OperationType.ADDITION,
                };
            }
            case OperationType.MULTIPLICATION: {
                const a = Math.floor(Math.random() * 99) + 2;
                const b = Math.floor(Math.random() * 99) + 2;
                return {
                    id: Math.random().toString(36).substr(2, 9),
                    text: `${a} × ${b}`,
                    answer: a * b,
                    type: OperationType.MULTIPLICATION,
                };
            }
            default:
                throw new Error('Unknown operation type');
        }
    },

    generateWeighted: (): Question => {
        return questionGenerator.generate(OperationType.MULTIPLICATION);
    },
};
