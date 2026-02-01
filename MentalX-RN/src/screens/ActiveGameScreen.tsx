import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { GameMode } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { useGameLogic } from '../hooks/useGameLogic';
import { NumberPad } from '../components/NumberPad';

interface ActiveGameScreenProps {
    route: any;
    navigation: any;
}

export const ActiveGameScreen: React.FC<ActiveGameScreenProps> = ({ route, navigation }) => {
    const { mode } = route.params as { mode: GameMode };
    const {
        currentQuestion,
        input,
        timeRemaining,
        score,
        isGameOver,
        submitInput,
        deleteInput,
    } = useGameLogic(mode);

    const handleExit = () => {
        navigation.goBack();
    };

    return (
        <View style={styles.container}>
            <View style={styles.topBar}>
                <TouchableOpacity onPress={handleExit}>
                    <Text style={styles.exitButton}>Exit</Text>
                </TouchableOpacity>
                <View style={styles.spacer} />
                {mode === GameMode.SPRINT && (
                    <Text
                        style={[
                            styles.timer,
                            timeRemaining < 10 && { color: COLORS.neonRed },
                        ]}
                    >
                        {Math.floor(timeRemaining)}s
                    </Text>
                )}
            </View>

            <View style={styles.questionArea}>
                {currentQuestion && (
                    <Text style={styles.questionText}>{currentQuestion.text}</Text>
                )}
                <Text style={styles.inputText}>
                    {input || '_'}
                </Text>
            </View>

            <Text style={styles.scoreText}>Score: {score}</Text>

            <NumberPad onTap={submitInput} onDelete={deleteInput} />

            {isGameOver && (
                <View style={styles.gameOverOverlay}>
                    <View style={styles.gameOverCard}>
                        <Text style={styles.gameOverTitle}>SESSION ENDED</Text>
                        <Text style={styles.gameOverScore}>Final Score: {score}</Text>
                        <TouchableOpacity style={styles.closeButton} onPress={handleExit}>
                            <Text style={styles.closeButtonText}>Close</Text>
                        </TouchableOpacity>
                    </View>
                </View>
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.cyberBackground,
    },
    topBar: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 16,
        paddingTop: 50,
    },
    exitButton: {
        fontSize: FONTS.body,
        color: COLORS.neonRed,
        fontWeight: '600',
    },
    spacer: {
        flex: 1,
    },
    timer: {
        fontSize: FONTS.title2,
        color: COLORS.neonGreen,
        fontWeight: '600',
        fontFamily: 'monospace',
    },
    questionArea: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        paddingHorizontal: 20,
    },
    questionText: {
        fontSize: FONTS.huge,
        fontWeight: 'bold',
        color: COLORS.textPrimary,
        fontFamily: 'monospace',
        marginBottom: 10,
    },
    inputText: {
        fontSize: 32,
        fontWeight: '500',
        color: COLORS.neonGreen,
        height: 40,
    },
    scoreText: {
        fontSize: FONTS.headline,
        fontWeight: '600',
        color: COLORS.textSecondary,
        textAlign: 'center',
        marginBottom: 20,
    },
    gameOverOverlay: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    gameOverCard: {
        backgroundColor: COLORS.cyberCard,
        borderRadius: 16,
        padding: 32,
        alignItems: 'center',
        minWidth: 280,
    },
    gameOverTitle: {
        fontSize: FONTS.title,
        fontWeight: '800',
        color: COLORS.textPrimary,
        marginBottom: 20,
    },
    gameOverScore: {
        fontSize: FONTS.title2,
        color: COLORS.neonGreen,
        marginBottom: 30,
    },
    closeButton: {
        paddingVertical: 12,
        paddingHorizontal: 32,
        backgroundColor: COLORS.textPrimary,
        borderRadius: 8,
    },
    closeButtonText: {
        fontSize: FONTS.body,
        color: COLORS.black,
        fontWeight: '600',
    },
});
