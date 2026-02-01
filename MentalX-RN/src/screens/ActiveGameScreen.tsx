import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { GameMode } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { useGameLogic } from '../hooks/useGameLogic';
import { NumberPad } from '../components/NumberPad';
import { SuccessFlash } from '../components/SuccessFlash';
import { BackgroundWrapper } from '../components/BackgroundWrapper';
import { Heart } from 'lucide-react-native';

import { NativeStackScreenProps } from '@react-navigation/native-stack';

type RootStackParamList = {
    Dashboard: undefined;
    ActiveGame: { mode: GameMode };
};

type ActiveGameScreenProps = NativeStackScreenProps<RootStackParamList, 'ActiveGame'>;

export const ActiveGameScreen: React.FC<ActiveGameScreenProps> = ({ route, navigation }) => {
    const { mode } = route.params as { mode: GameMode };
    const {
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
    } = useGameLogic(mode);

    const handleExit = () => navigation.goBack();

    return (
        <BackgroundWrapper>
            <View style={styles.container}>
                <SuccessFlash trigger={successTrigger} />
                <SuccessFlash trigger={errorTrigger} isError />

                <View style={styles.topBar}>
                    <TouchableOpacity onPress={handleExit}>
                        <Text style={styles.exitButton}>Exit</Text>
                    </TouchableOpacity>
                    <View style={styles.spacer} />

                    {mode === GameMode.SPRINT && (
                        <Text style={[styles.timer, globalTimeRemaining < 10 && { color: COLORS.neonRed }]}>
                            {globalTimeRemaining}s
                        </Text>
                    )}

                    {mode === GameMode.MARATHON && (
                        <View style={styles.livesContainer}>
                            {[...Array(3)].map((_, i) => (
                                <Heart
                                    key={i}
                                    size={20}
                                    fill={i < lives ? COLORS.neonRed : 'transparent'}
                                    color={COLORS.neonRed}
                                    style={{ opacity: i < lives ? 1 : 0.3 }}
                                />
                            ))}
                        </View>
                    )}
                </View>

                {mode === GameMode.MARATHON && (
                    <View style={styles.progressBarContainer}>
                        <View
                            style={[
                                styles.progressBarFill,
                                {
                                    width: `${questionTimeProgress * 100}%`,
                                    backgroundColor: questionTimeProgress > 0.3 ? COLORS.neonGreen : COLORS.neonRed,
                                },
                            ]}
                        />
                    </View>
                )}

                <View style={styles.questionArea}>
                    {currentQuestion && (
                        <>
                            <Text style={styles.questionText}>{currentQuestion.text}</Text>
                            <Text style={styles.inputText}>{input || '_'}</Text>
                        </>
                    )}
                    <Text style={styles.scoreText}>Score: {score}</Text>
                </View>

                <NumberPad onTap={submitInput} onDelete={deleteInput} />

                {isGameOver && (
                    <View style={styles.gameOverOverlay}>
                        <View style={styles.gameOverCard}>
                            <Text style={styles.gameOverTitle}>Game Over</Text>
                            <Text style={styles.gameOverScore}>Final Score: {score}</Text>
                            <TouchableOpacity style={styles.closeButton} onPress={handleExit}>
                                <Text style={styles.closeButtonText}>Close</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                )}
            </View>
        </BackgroundWrapper>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1 },
    topBar: { flexDirection: 'row', alignItems: 'center', padding: 16, paddingTop: 50 },
    exitButton: { fontSize: FONTS.body, color: COLORS.neonRed, fontWeight: '600' },
    spacer: { flex: 1 },
    timer: { fontSize: FONTS.title2, color: COLORS.neonGreen, fontWeight: '600' },
    livesContainer: { flexDirection: 'row', gap: 4 },
    heart: { fontSize: 24, color: COLORS.neonRed },
    progressBarContainer: { height: 4, backgroundColor: '#333', width: '100%' },
    progressBarFill: { height: '100%' },
    questionArea: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 20 },
    questionText: { fontSize: 42, fontWeight: '300', color: COLORS.textPrimary, marginBottom: 10, fontVariant: ['tabular-nums'] },
    inputText: { fontSize: 32, fontWeight: '500', color: COLORS.neonGreen, height: 40 },
    scoreText: { fontSize: FONTS.headline, fontWeight: '600', color: COLORS.textSecondary, textAlign: 'center', marginBottom: 20 },
    gameOverOverlay: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0, 0, 0, 0.9)', justifyContent: 'center', alignItems: 'center' },
    gameOverCard: { backgroundColor: COLORS.cyberCard, borderRadius: 16, padding: 32, alignItems: 'center', minWidth: 280, borderWidth: 1, borderColor: COLORS.borderSubtle },
    gameOverTitle: { fontSize: FONTS.title, fontWeight: '800', color: COLORS.textPrimary, marginBottom: 20 },
    gameOverScore: { fontSize: FONTS.title2, color: COLORS.neonGreen, marginBottom: 30 },
    closeButton: { paddingVertical: 12, paddingHorizontal: 32, backgroundColor: COLORS.textPrimary, borderRadius: 8 },
    closeButtonText: { fontSize: FONTS.body, color: COLORS.black, fontWeight: '600' },
});
