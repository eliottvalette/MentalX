import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { GameMode, SRSItem } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { persistenceService } from '../services/persistence';
import { SRSHeatmap } from '../components/SRSHeatmap';
import { BackgroundWrapper } from '../components/BackgroundWrapper';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Zap, Flame, Brain } from 'lucide-react-native';
import { LinearGradient } from 'expo-linear-gradient';

type RootStackParamList = {
    Dashboard: undefined;
    ActiveGame: { mode: GameMode };
};

interface DashboardScreenProps {
    navigation: NativeStackNavigationProp<RootStackParamList, 'Dashboard'>;
}

export const DashboardScreen: React.FC<DashboardScreenProps> = ({ navigation }) => {
    const [srsItems, setSrsItems] = useState<SRSItem[]>([]);
    const [sprintRecord, setSprintRecord] = useState(0);
    const [marathonRecord, setMarathonRecord] = useState(0);

    const loadData = async () => {
        const items = await persistenceService.getAllSRSItems();
        setSrsItems(items);

        const sScore = await persistenceService.getHighScore(GameMode.SPRINT);
        const mScore = await persistenceService.getHighScore(GameMode.MARATHON);
        setSprintRecord(sScore);
        setMarathonRecord(mScore);
    };

    useFocusEffect(
        React.useCallback(() => {
            loadData();
        }, [])
    );

    return (
        <BackgroundWrapper>
            <View style={styles.scrollContent}>
                <View style={styles.header}>
                    <Text style={styles.headerText}>MENTAL CORE</Text>
                </View>

                <SRSHeatmap items={srsItems} />

                <View style={styles.modesSection}>
                    <Text style={styles.sectionTitle}>SELECT PROTOCOL</Text>

                    <ModeButton
                        title="Sprint"
                        subtitle="60s Time Attack"
                        stat={`${sprintRecord} pts`}
                        icon={<Zap size={20} color={COLORS.textPrimary} />}
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.SPRINT })}
                    />
                    <ModeButton
                        title="Marathon"
                        subtitle="3 Lives • 10s Limit"
                        stat={`${marathonRecord} pts`}
                        icon={<Flame size={20} color={COLORS.textPrimary} />}
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.MARATHON })}
                    />
                    <ModeButton
                        title="Training"
                        subtitle="Adaptive Learning"
                        stat="SRS"
                        icon={<Brain size={20} color={COLORS.textPrimary} />}
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.TRAINING })}
                    />
                </View>
            </View>
        </BackgroundWrapper>
    );
};

const ModeButton = ({ title, subtitle, stat, icon, onPress }: any) => (
    <TouchableOpacity onPress={onPress} style={{ marginBottom: 12 }}>
        <LinearGradient
            colors={[COLORS.cardGradientStart, COLORS.cardGradientEnd]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.modeButton}
        >
            <View style={styles.iconContainer}>
                {icon}
            </View>
            <View style={styles.modeTextContainer}>
                <Text style={styles.modeTitle}>{title}</Text>
                <Text style={styles.modeSubtitle}>{subtitle}</Text>
            </View>
            <View style={styles.statBadge}>
                <Text style={styles.statText}>{stat}</Text>
            </View>
        </LinearGradient>
    </TouchableOpacity>
);

const styles = StyleSheet.create({
    scrollContent: { padding: 16, paddingTop: 60 },
    header: { paddingVertical: 10, marginBottom: 2 },
    headerText: { fontSize: 22, fontWeight: '600', color: COLORS.textPrimary, letterSpacing: 2, textTransform: 'uppercase' },
    sectionTitle: { fontSize: 10, fontWeight: '600', color: COLORS.textSecondary, marginBottom: 8, paddingLeft: 4, letterSpacing: 1, textTransform: 'uppercase' },
    modesSection: { marginTop: 2 },
    modeButton: { flexDirection: 'row', alignItems: 'center', padding: 16, borderRadius: 8, borderWidth: 1, borderColor: COLORS.borderSubtle },
    iconContainer: { width: 36, height: 36, borderRadius: 8, backgroundColor: 'rgba(255,255,255,0.05)', justifyContent: 'center', alignItems: 'center', marginRight: 16 },
    modeIcon: { fontSize: 18, color: COLORS.textPrimary },
    modeTextContainer: { flex: 1 },
    modeTitle: { fontSize: 16, fontWeight: '500', color: COLORS.textPrimary, marginBottom: 2 },
    modeSubtitle: { fontSize: 12, color: COLORS.textSecondary },
    statBadge: { backgroundColor: 'rgba(40, 217, 102, 0.1)', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6 },
    statText: { color: COLORS.neonGreen, fontWeight: '600', fontSize: 11 },
});
