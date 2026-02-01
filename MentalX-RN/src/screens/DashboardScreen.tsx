import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { GameMode, SRSItem, SRSStatus } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { persistenceService } from '../services/persistence';
import { calculateSRSItems } from '../utils/srsLogic';
import { CognitiveLoadChart } from '../components/CognitiveLoadChart';
import { SRSListRow } from '../components/SRSListRow';

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

    const loadSRSData = async () => {
        const results = await persistenceService.loadResults();
        const items = calculateSRSItems(results);
        setSrsItems(items);
    };

    useFocusEffect(
        React.useCallback(() => {
            loadSRSData();
        }, [])
    );

    useEffect(() => {
        loadSRSData();
    }, []);

    const criticalItems = srsItems.filter(
        (item) => item.status === SRSStatus.CRITICAL || item.status === SRSStatus.UNSTABLE
    );

    return (
        <View style={styles.container}>
            <ScrollView contentContainerStyle={styles.scrollContent}>
                <View style={styles.header}>
                    <Text style={styles.headerText}>MENTAL CORE</Text>
                    <View style={styles.statusBadge}>
                        <View style={styles.onlineDot} />
                        <Text style={styles.statusText}>SYSTEM ONLINE</Text>
                    </View>
                </View>

                {/* Toujours afficher le Chart, il gérera son état vide lui-même */}
                <CognitiveLoadChart items={srsItems} />

                <View style={styles.threatLogSection}>
                    <Text style={styles.sectionTitle}>THREAT LOG</Text>

                    {criticalItems.length > 0 ? (
                        criticalItems.slice(0, 4).map((item) => (
                            <SRSListRow key={item.id} item={item} />
                        ))
                    ) : (
                        // Placeholder pour la liste vide
                        <View style={styles.emptyLog}>
                            <Text style={styles.emptyLogText}>NO ACTIVE THREATS DETECTED</Text>
                            <Text style={styles.emptyLogSub}>Start training to calibrate algorithm</Text>
                        </View>
                    )}
                </View>

                <View style={styles.modesSection}>
                    <ModeButton
                        title="Sprint"
                        subtitle="60s max score"
                        icon="SP"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.SPRINT })}
                    />
                    <ModeButton
                        title="Marathon"
                        subtitle="Until first error"
                        icon="MA"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.MARATHON })}
                    />
                    <ModeButton
                        title="Training"
                        subtitle="SRS adaptive"
                        icon="TR"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.TRAINING })}
                    />
                </View>
            </ScrollView>
        </View>
    );
};

interface ModeButtonProps {
    title: string;
    subtitle: string;
    icon: string;
    onPress: () => void;
}

const ModeButton: React.FC<ModeButtonProps> = ({ title, subtitle, icon, onPress }) => (
    <TouchableOpacity style={styles.modeButton} onPress={onPress}>
        <Text style={styles.modeIcon}>{icon}</Text>
        <View style={styles.modeTextContainer}>
            <Text style={styles.modeTitle}>{title}</Text>
            <Text style={styles.modeSubtitle}>{subtitle}</Text>
        </View>
        <Text style={styles.chevron}>›</Text>
    </TouchableOpacity>
);

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.cyberBackground,
    },
    scrollContent: {
        padding: 16,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 20,
        marginBottom: 10
    },
    headerText: { fontSize: 24, fontWeight: '900', color: COLORS.textPrimary, letterSpacing: 1 },
    statusBadge: { flexDirection: 'row', alignItems: 'center', backgroundColor: 'rgba(32, 199, 89, 0.1)', paddingHorizontal: 10, paddingVertical: 5, borderRadius: 12 },
    onlineDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: COLORS.neonGreen, marginRight: 6 },
    statusText: { fontSize: 10, color: COLORS.neonGreen, fontWeight: 'bold' },

    threatLogSection: {
        marginTop: 20,
    },
    emptyLog: {
        padding: 30,
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: 'rgba(255,255,255,0.02)',
        borderRadius: 12,
        borderStyle: 'dashed',
        borderWidth: 1,
        borderColor: COLORS.textSecondary,
    },
    emptyLogText: { color: COLORS.textSecondary, fontWeight: 'bold', marginBottom: 4 },
    emptyLogSub: { color: COLORS.textSecondary, fontSize: 10, opacity: 0.7 },

    sectionTitle: {
        fontSize: FONTS.caption,
        fontWeight: '800',
        color: COLORS.textSecondary,
        marginBottom: 12,
        paddingLeft: 4,
    },
    modesSection: {
        marginTop: 20,
    },
    modeButton: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 16,
        backgroundColor: COLORS.cyberCard,
        borderRadius: 12,
        borderWidth: 1,
        borderColor: 'rgba(255, 255, 255, 0.05)',
        marginBottom: 12,
    },
    modeIcon: {
        fontSize: FONTS.title2,
        marginRight: 16,
        width: 40,
        textAlign: 'center',
        color: COLORS.textPrimary,
    },
    modeTextContainer: {
        flex: 1,
    },
    modeTitle: {
        fontSize: FONTS.headline,
        fontWeight: 'bold',
        color: COLORS.textPrimary,
        marginBottom: 4,
    },
    modeSubtitle: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
    },
    chevron: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
    },
});
