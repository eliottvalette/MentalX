import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { SRSItem, SRSStatus } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { CyberCard } from './CyberCard';

interface SRSHeatmapProps {
    items: SRSItem[];
}

export const SRSHeatmap: React.FC<SRSHeatmapProps> = ({ items }) => {
    const [activeTab, setActiveTab] = useState<'mult' | 'add'>('mult');

    const multiplicationNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    const additionRanges = [
        { label: '1-10', min: 1, max: 10 },
        { label: '11-20', min: 11, max: 20 },
        { label: '21-30', min: 21, max: 30 },
        { label: '31-40', min: 31, max: 40 },
        { label: '41-50', min: 41, max: 50 },
        { label: '51-60', min: 51, max: 60 },
        { label: '61-70', min: 61, max: 70 },
        { label: '71-80', min: 71, max: 80 },
        { label: '81-90', min: 81, max: 90 },
        { label: '91-99', min: 91, max: 99 },
    ];

    const getStatusForMultiplication = (a: number, b: number): string => {
        const op1 = `${a} × ${b}`;
        const op2 = `${b} × ${a}`;
        const item = items.find(i => i.operation === op1 || i.operation === op2);
        if (!item) return 'EMPTY';
        return item.status;
    };

    const getStatusForAdditionRange = (rangeA: any, rangeB: any): string => {
        const relevantItems = items.filter(item => {
            if (!item.operation.includes('+')) return false;
            const parts = item.operation.split(' + ').map(p => parseInt(p.trim()));
            if (parts.length !== 2) return false;
            const [a, b] = parts;
            return (a >= rangeA.min && a <= rangeA.max && b >= rangeB.min && b <= rangeB.max) ||
                (b >= rangeA.min && b <= rangeA.max && a >= rangeB.min && a <= rangeB.max);
        });

        if (relevantItems.length === 0) return 'EMPTY';

        const avgMastery = relevantItems.reduce((sum, item) => sum + item.mastery, 0) / relevantItems.length;
        if (avgMastery < 0.4) return SRSStatus.CRITICAL;
        if (avgMastery < 0.8) return SRSStatus.UNSTABLE;
        return SRSStatus.STABLE;
    };

    const getColor = (status: string) => {
        switch (status) {
            case SRSStatus.STABLE: return COLORS.neonGreen;
            case SRSStatus.UNSTABLE: return COLORS.orange;
            case SRSStatus.CRITICAL: return COLORS.neonRed;
            default: return '#1C1C1E';
        }
    };

    return (
        <CyberCard style={styles.container}>
            <View style={styles.tabContainer}>
                <TouchableOpacity
                    style={[styles.tab, activeTab === 'mult' && styles.tabActive]}
                    onPress={() => setActiveTab('mult')}
                >
                    <Text style={[styles.tabText, activeTab === 'mult' && styles.tabTextActive]}>×</Text>
                </TouchableOpacity>
                <TouchableOpacity
                    style={[styles.tab, activeTab === 'add' && styles.tabActive]}
                    onPress={() => setActiveTab('add')}
                >
                    <Text style={[styles.tabText, activeTab === 'add' && styles.tabTextActive]}>+</Text>
                </TouchableOpacity>
            </View>

            {activeTab === 'mult' ? (
                <View style={styles.grid}>
                    <View style={styles.row}>
                        <View style={styles.headerCell} />
                        {multiplicationNumbers.map(n => (
                            <View key={`h-${n}`} style={styles.headerCellSmall}>
                                <Text style={styles.headerTextSmall}>{n}</Text>
                            </View>
                        ))}
                    </View>

                    {multiplicationNumbers.map(rowNum => (
                        <View key={`row-${rowNum}`} style={styles.row}>
                            <View style={styles.headerCellSmall}>
                                <Text style={styles.headerTextSmall}>{rowNum}</Text>
                            </View>
                            {multiplicationNumbers.map(colNum => {
                                const status = getStatusForMultiplication(rowNum, colNum);
                                return (
                                    <View
                                        key={`${rowNum}-${colNum}`}
                                        style={[styles.cellSmall, { backgroundColor: getColor(status) }]}
                                    />
                                );
                            })}
                        </View>
                    ))}
                </View>
            ) : (
                <View style={styles.grid}>
                    <View style={styles.row}>
                        <View style={styles.headerCell} />
                        {additionRanges.map(range => (
                            <View key={`h-${range.label}`} style={styles.headerCell}>
                                <Text style={styles.headerText}>{range.label}</Text>
                            </View>
                        ))}
                    </View>

                    {additionRanges.map(rowRange => (
                        <View key={`row-${rowRange.label}`} style={styles.row}>
                            <View style={styles.headerCell}>
                                <Text style={styles.headerText}>{rowRange.label}</Text>
                            </View>
                            {additionRanges.map(colRange => {
                                const status = getStatusForAdditionRange(rowRange, colRange);
                                return (
                                    <View
                                        key={`${rowRange.label}-${colRange.label}`}
                                        style={[styles.cell, { backgroundColor: getColor(status) }]}
                                    />
                                );
                            })}
                        </View>
                    ))}
                </View>
            )}

            <View style={styles.legend}>
                <LegendItem label="Mastery" color={COLORS.neonGreen} />
                <LegendItem label="Struggle" color={COLORS.neonRed} />
                <LegendItem label="Unexplored" color="#1C1C1E" />
            </View>
        </CyberCard>
    );
};

const LegendItem = ({ label, color }: { label: string; color: string }) => (
    <View style={styles.legendItem}>
        <View style={[styles.legendDot, { backgroundColor: color }]} />
        <Text style={styles.legendText}>{label}</Text>
    </View>
);

const styles = StyleSheet.create({
    container: { marginBottom: 20, alignItems: 'center' },
    tabContainer: { flexDirection: 'row', marginBottom: 12, gap: 8 },
    tab: { paddingHorizontal: 20, paddingVertical: 6, borderRadius: 8, backgroundColor: 'rgba(255,255,255,0.05)' },
    tabActive: { backgroundColor: COLORS.neonGreen },
    tabText: { fontSize: 16, fontWeight: 'bold', color: COLORS.textSecondary },
    tabTextActive: { color: COLORS.black },
    grid: { flexDirection: 'column' },
    row: { flexDirection: 'row', alignItems: 'center' },
    headerCell: { width: 35, height: 20, justifyContent: 'center', alignItems: 'center' },
    headerText: { color: COLORS.textSecondary, fontSize: 8, fontWeight: 'bold' },
    headerCellSmall: { width: 18, height: 18, justifyContent: 'center', alignItems: 'center' },
    headerTextSmall: { color: COLORS.textSecondary, fontSize: 7, fontWeight: 'bold' },
    cell: { width: 32, height: 18, margin: 1, borderRadius: 3 },
    cellSmall: { width: 16, height: 16, margin: 0.5, borderRadius: 2 },
    legend: { flexDirection: 'row', gap: 15, marginTop: 10 },
    legendItem: { flexDirection: 'row', alignItems: 'center', gap: 4 },
    legendDot: { width: 8, height: 8, borderRadius: 4 },
    legendText: { fontSize: 10, color: COLORS.textSecondary, fontWeight: 'bold' }
});
