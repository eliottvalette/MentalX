import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { GameMode, SRSItem, SRSStatus } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { persistenceService } from '../services/persistence';
import { calculateSRSItems } from '../utils/srsLogic';
import { CognitiveLoadChart } from '../components/CognitiveLoadChart';
import { SRSListRow } from '../components/SRSListRow';

interface DashboardScreenProps {
    navigation: any;
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
                </View>

                {srsItems.length > 0 && (
                    <>
                        <CognitiveLoadChart items={srsItems} />

                        <View style={styles.threatLogSection}>
                            <Text style={styles.sectionTitle}>THREAT LOG</Text>
                            {criticalItems.slice(0, 4).map((item) => (
                                <SRSListRow key={item.id} item={item} />
                            ))}
                        </View>
                    </>
                )}

                <View style={styles.modesSection}>
                    <ModeButton
                        title="Sprint"
                        subtitle="60s max score"
                        icon="⏱️"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.SPRINT })}
                    />
                    <ModeButton
                        title="Marathon"
                        subtitle="Until first error"
                        icon="🔥"
                        onPress={() => navigation.navigate('ActiveGame', { mode: GameMode.MARATHON })}
                    />
                    <ModeButton
                        title="Training"
                        subtitle="SRS adaptive"
                        icon="🏋️"
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
        paddingVertical: 16,
    },
    headerText: {
        fontSize: 24,
        fontWeight: '800',
        color: COLORS.textPrimary,
    },
    threatLogSection: {
        marginTop: 20,
    },
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
