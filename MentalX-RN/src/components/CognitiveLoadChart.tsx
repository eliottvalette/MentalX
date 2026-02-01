import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SRSItem, SRSStatus } from '../types';
import { CyberCard } from './CyberCard';
import { COLORS, FONTS } from '../constants/theme';

interface CognitiveLoadChartProps {
    items: SRSItem[];
}

export const CognitiveLoadChart: React.FC<CognitiveLoadChartProps> = ({ items }) => {
    const criticalCount = items.filter((i) => i.status === SRSStatus.CRITICAL).length;
    const unstableCount = items.filter((i) => i.status === SRSStatus.UNSTABLE).length;
    const stableCount = items.filter((i) => i.status === SRSStatus.STABLE).length;
    const total = items.length;

    const criticalWidth = total > 0 ? (criticalCount / total) * 100 : 0;
    const unstableWidth = total > 0 ? (unstableCount / total) * 100 : 0;
    const stableWidth = total > 0 ? (stableCount / total) * 100 : 0;

    return (
        <CyberCard>
            <View style={styles.header}>
                <Text style={styles.icon}>⚠️</Text>
                <Text style={styles.title}>Cognitive Vulnerabilities</Text>
                <View style={styles.spacer} />
                <Text style={styles.count}>{criticalCount}</Text>
            </View>

            <View style={styles.barContainer}>
                {criticalWidth > 0 && (
                    <View style={[styles.bar, { width: `${criticalWidth}%`, backgroundColor: COLORS.neonRed }]} />
                )}
                {unstableWidth > 0 && (
                    <View style={[styles.bar, { width: `${unstableWidth}%`, backgroundColor: COLORS.orange }]} />
                )}
                {stableWidth > 0 && (
                    <View style={[styles.bar, { width: `${stableWidth}%`, backgroundColor: COLORS.neonGreen }]} />
                )}
            </View>

            <View style={styles.legend}>
                <LegendItem label="Critical" color={COLORS.neonRed} value={criticalCount} />
                <LegendItem label="Review" color={COLORS.orange} value={unstableCount} />
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
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 12,
    },
    icon: {
        fontSize: FONTS.body,
        marginRight: 8,
    },
    title: {
        fontSize: FONTS.headline,
        fontWeight: '600',
        color: COLORS.textSecondary,
    },
    spacer: {
        flex: 1,
    },
    count: {
        fontSize: FONTS.title,
        fontWeight: 'bold',
        color: COLORS.textPrimary,
        fontFamily: 'monospace',
    },
    barContainer: {
        flexDirection: 'row',
        height: 6,
        borderRadius: 3,
        overflow: 'hidden',
        marginVertical: 8,
    },
    bar: {
        height: '100%',
    },
    legend: {
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 8,
    },
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
