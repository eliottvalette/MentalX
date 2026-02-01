import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SRSItem, SRSStatus } from '../types';
import { CyberCard } from './CyberCard';
import { COLORS, FONTS } from '../constants/theme';
import { AlertTriangle } from 'lucide-react-native';

interface CognitiveLoadChartProps {
    items: SRSItem[];
}

export const CognitiveLoadChart: React.FC<CognitiveLoadChartProps> = ({ items }) => {
    const total = items.length;

    // LOGIQUE DE PLACEHOLDER : Si pas de donnée, on affiche un état "Calibration"
    const isEmpty = total === 0;

    const criticalCount = items.filter((i: SRSItem) => i.status === SRSStatus.CRITICAL).length;
    const unstableCount = items.filter((i: SRSItem) => i.status === SRSStatus.UNSTABLE).length;
    const stableCount = items.filter((i: SRSItem) => i.status === SRSStatus.STABLE).length;

    const criticalWidth = !isEmpty ? (criticalCount / total) * 100 : 0;
    const unstableWidth = !isEmpty ? (unstableCount / total) * 100 : 0;
    const stableWidth = !isEmpty ? (stableCount / total) * 100 : 0;

    return (
        <CyberCard style={styles.container}>
            <View style={styles.header}>
                <AlertTriangle size={18} color={COLORS.neonRed} style={{ marginRight: 10 }} />
                <Text style={styles.title}>Cognitive Vulnerabilities</Text>
                <View style={styles.spacer} />
                <Text style={styles.count}>{isEmpty ? '--' : criticalCount}</Text>
            </View>

            {/* BARRE DE PROGRESSION */}
            <View style={styles.barContainer}>
                {isEmpty ? (
                    // BARRE VIDE (Placeholder gris foncé)
                    <View style={[styles.bar, { width: '100%', backgroundColor: COLORS.borderSubtle }]} />
                ) : (
                    <>
                        {criticalWidth > 0 && <View style={[styles.bar, { width: `${criticalWidth}%`, backgroundColor: COLORS.neonRed }]} />}
                        {unstableWidth > 0 && <View style={[styles.bar, { width: `${unstableWidth}%`, backgroundColor: COLORS.orange }]} />}
                        {stableWidth > 0 && <View style={[styles.bar, { width: `${stableWidth}%`, backgroundColor: COLORS.neonGreen }]} />}
                    </>
                )}
            </View>

            <View style={styles.legend}>
                <LegendItem label="Critical" color={isEmpty ? COLORS.textSecondary : COLORS.neonRed} value={criticalCount} />
                <LegendItem label="Review" color={isEmpty ? COLORS.textSecondary : COLORS.orange} value={unstableCount} />
                <View style={styles.spacer} />
                <Text style={styles.totalText}>Total: {total}</Text>
            </View>
        </CyberCard>
    );
};

interface LegendItemProps {
    label: string;
    color: string;
    value: number;
}

const LegendItem: React.FC<LegendItemProps> = ({ label, color, value }) => (
    <View style={styles.legendItem}>
        <View style={[styles.dot, { backgroundColor: color }]} />
        <Text style={styles.legendLabel}>{label}</Text>
        <Text style={styles.legendValue}>{value}</Text>
    </View>
);

const styles = StyleSheet.create({
    container: { marginBottom: 20 },
    header: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
    icon: { fontSize: 16, marginRight: 8, color: COLORS.neonRed },
    title: { fontSize: FONTS.headline, fontWeight: '600', color: COLORS.textSecondary },
    spacer: { flex: 1 },
    count: { fontSize: FONTS.title2, fontWeight: 'bold', color: COLORS.textPrimary },
    barContainer: { flexDirection: 'row', height: 8, borderRadius: 4, overflow: 'hidden', marginVertical: 12, backgroundColor: '#000' },
    bar: { height: '100%' },
    legend: { flexDirection: 'row', alignItems: 'center' },
    legendItem: {
        flexDirection: 'row',
        alignItems: 'center',
        marginRight: 20,
    },
    dot: {
        width: 6,
        height: 6,
        borderRadius: 3,
        marginRight: 6,
    },
    legendLabel: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
        marginRight: 4,
    },
    legendValue: {
        fontSize: FONTS.caption,
        fontWeight: 'bold',
        color: COLORS.textPrimary,
    },
    totalText: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
    },
});
