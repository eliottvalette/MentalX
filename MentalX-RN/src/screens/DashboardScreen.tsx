import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { GameMode, SRSItem } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { persistenceService } from '../services/persistence';
import { calculateSRSItems } from '../utils/srsLogic';
import { SRSHeatmap } from '../components/SRSHeatmap';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';

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
        const results = await persistenceService.loadResults();
        const items = calculateSRSItems(results);
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
        <View style={styles.container}>
            <ScrollView contentContainerStyle={styles.scrollContent}>
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
                        icon="SP"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.SPRINT })}
                    />
                    <ModeButton
                        title="Marathon"
                        subtitle="3 Lives • 10s Limit"
                        stat={`${marathonRecord} pts`}
                        icon="MA"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.MARATHON })}
                    />
                    <ModeButton
                        title="Training"
                        subtitle="Adaptive Learning"
                        stat="SRS"
                        icon="TR"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.TRAINING })}
                    />
                </View>
            </ScrollView>
        </View>
    );
};

const ModeButton = ({ title, subtitle, stat, icon, onPress }: any) => (
    <TouchableOpacity style={styles.modeButton} onPress={onPress}>
        <Text style={styles.modeIcon}>{icon}</Text>
        <View style={styles.modeTextContainer}>
            <Text style={styles.modeTitle}>{title}</Text>
            <Text style={styles.modeSubtitle}>{subtitle}</Text>
        </View>
        <View style={styles.statBadge}>
            <Text style={styles.statText}>{stat}</Text>
        </View>
    </TouchableOpacity>
);

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.cyberBackground },
    scrollContent: { padding: 16 },
    header: { paddingVertical: 20, marginBottom: 10 },
    headerText: { fontSize: 24, fontWeight: '900', color: COLORS.textPrimary, letterSpacing: 1 },
    sectionTitle: { fontSize: FONTS.caption, fontWeight: '800', color: COLORS.textSecondary, marginBottom: 12, paddingLeft: 4 },
    modesSection: { marginTop: 10 },
    modeButton: { flexDirection: 'row', alignItems: 'center', padding: 16, backgroundColor: COLORS.cyberCard, borderRadius: 12, borderWidth: 1, borderColor: 'rgba(255, 255, 255, 0.05)', marginBottom: 12 },
    modeIcon: { fontSize: 24, marginRight: 16, color: COLORS.textPrimary },
    modeTextContainer: { flex: 1 },
    modeTitle: { fontSize: FONTS.headline, fontWeight: 'bold', color: COLORS.textPrimary },
    modeSubtitle: { fontSize: FONTS.caption, color: COLORS.textSecondary },
    statBadge: { backgroundColor: 'rgba(255,255,255,0.05)', paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8 },
    statText: { color: COLORS.neonGreen, fontWeight: 'bold', fontSize: 12 },
});
