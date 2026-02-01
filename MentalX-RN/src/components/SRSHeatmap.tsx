import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { SRSItem } from '../types';
import { COLORS, FONTS } from '../constants/theme';
import { CyberCard } from './CyberCard';
import { interpolateColor } from '../utils/srsAlgorithm';

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

    const getColorForMultiplication = (a: number, b: number): string => {
        const op1 = `${a} × ${b}`;
        const op2 = `${b} × ${a}`;
        const item = items.find(i => i.operation === op1 || i.operation === op2);
        if (!item) return '#1C1C1E'; // Empty state (Dark)
        return interpolateColor(item.mastery);
    };

    const getColorForAdditionRange = (rangeA: any, rangeB: any): string => {
        const relevantItems = items.filter(item => {
            if (!item.operation.includes('+')) return false;
            const parts = item.operation.split(' + ').map(p => parseInt(p.trim()));
            if (parts.length !== 2) return false;
            const [a, b] = parts;
            return (a >= rangeA.min && a <= rangeA.max && b >= rangeB.min && b <= rangeB.max) ||
                (b >= rangeA.min && b <= rangeA.max && a >= rangeB.min && a <= rangeB.max);
        });

        if (relevantItems.length === 0) return '#1C1C1E';

        const avgMastery = relevantItems.reduce((sum, item) => sum + item.mastery, 0) / relevantItems.length;
        return interpolateColor(avgMastery);
    };

    return (
        <CyberCard style={styles.container}>
            {/* TABS */}
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


            {/* CONTENT - Conditional ScrollView */}
            {activeTab === 'mult' ? (
                <View>
                    <View style={styles.grid}>
                        {/* Header Row */}
                        <View style={styles.row}>
                            <View style={styles.headerCellSmallPlaceholder} />
                            {multiplicationNumbers.map(n => (
                                <View key={`h-${n}`} style={styles.headerCellSmall}>
                                    <Text style={styles.headerTextSmall}>{n}</Text>
                                </View>
                            ))}
                        </View>

                        {/* Data Rows */}
                        {multiplicationNumbers.map(rowNum => (
                            <View key={`row-${rowNum}`} style={styles.row}>
                                <View style={styles.headerCellSmall}>
                                    <Text style={styles.headerTextSmall}>{rowNum}</Text>
                                </View>
                                {multiplicationNumbers.map(colNum => {
                                    const color = getColorForMultiplication(rowNum, colNum);
                                    return (
                                        <View
                                            key={`${rowNum}-${colNum}`}
                                            style={[styles.cellSmall, { backgroundColor: color }]}
                                        />
                                    );
                                })}
                            </View>
                        ))}
                    </View>
                </View>
            ) : (
                <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.scrollContainer}>
                    <View style={styles.grid}>
                        {/* Header Row */}
                        <View style={styles.row}>
                            <View style={styles.headerCellPlaceholder} />
                            {additionRanges.map(range => (
                                <View key={`h-${range.label}`} style={styles.headerCell}>
                                    <Text style={styles.headerText}>{range.label}</Text>
                                </View>
                            ))}
                        </View>

                        {/* Data Rows */}
                        {additionRanges.map(rowRange => (
                            <View key={`row-${rowRange.label}`} style={styles.row}>
                                <View style={styles.headerCell}>
                                    <Text style={styles.headerText}>{rowRange.label}</Text>
                                </View>
                                {additionRanges.map(colRange => {
                                    const color = getColorForAdditionRange(rowRange, colRange);
                                    return (
                                        <View
                                            key={`${rowRange.label}-${colRange.label}`}
                                            style={[styles.cell, { backgroundColor: color }]}
                                        />
                                    );
                                })}
                            </View>
                        ))}
                    </View>
                </ScrollView>
            )}


            {/* LEGEND */}
            <View style={styles.legend}>
                <LegendItem label="Mastered" color={COLORS.neonGreen} />
                <LegendItem label="Learning" color={COLORS.orange} />
                <LegendItem label="New" color={COLORS.neonRed} />
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

// CONSTANTES DE TAILLE POUR L'ALIGNEMENT PARFAIT
// Cellule de multiplication : 18px width + 1px margin left + 1px margin right = 20px Total
const MULT_CELL_SIZE = 18;
const MULT_CELL_MARGIN = 1;
const MULT_TOTAL_SIZE = MULT_CELL_SIZE + (MULT_CELL_MARGIN * 2);

// Cellule d'addition : 38px width + 1px margin left + 1px margin right = 40px Total
const ADD_CELL_SIZE = 38;
const ADD_CELL_MARGIN = 1;
const ADD_TOTAL_SIZE = ADD_CELL_SIZE + (ADD_CELL_MARGIN * 2);

const styles = StyleSheet.create({
    container: { marginBottom: 20, alignItems: 'center', width: '100%' },
    scrollContainer: { paddingBottom: 10 }, // Espace pour scroller
    tabContainer: { flexDirection: 'row', marginBottom: 12, gap: 8 },
    tab: { paddingHorizontal: 20, paddingVertical: 6, borderRadius: 4, backgroundColor: 'rgba(255,255,255,0.05)' },
    tabActive: { backgroundColor: COLORS.neonGreen },
    tabText: { fontSize: 16, fontWeight: 'bold', color: COLORS.textSecondary },
    tabTextActive: { color: COLORS.black },

    grid: { flexDirection: 'column' },
    row: { flexDirection: 'row', alignItems: 'center' },

    // --- STYLES MULTIPLICATION (Alignés sur MULT_TOTAL_SIZE = 20px) ---
    headerCellSmall: {
        width: MULT_TOTAL_SIZE,
        height: 20,
        justifyContent: 'center',
        alignItems: 'center'
    },
    headerCellSmallPlaceholder: {
        width: MULT_TOTAL_SIZE,
        height: 20,
    },
    headerTextSmall: { color: COLORS.textSecondary, fontSize: 8, fontWeight: 'bold' },
    cellSmall: {
        width: MULT_CELL_SIZE,
        height: MULT_CELL_SIZE,
        margin: MULT_CELL_MARGIN,
        borderRadius: 2
    },

    // --- STYLES ADDITION (Alignés sur ADD_TOTAL_SIZE = 40px) ---
    headerCell: {
        width: ADD_TOTAL_SIZE,
        height: 20,
        justifyContent: 'center',
        alignItems: 'center'
    },
    headerCellPlaceholder: {
        width: ADD_TOTAL_SIZE,
        height: 20,
    },
    headerText: { color: COLORS.textSecondary, fontSize: 9, fontWeight: 'bold' },
    cell: {
        width: ADD_CELL_SIZE,
        height: 18,
        margin: ADD_CELL_MARGIN,
        borderRadius: 3
    },

    legend: { flexDirection: 'row', gap: 15, marginTop: 10 },
    legendItem: { flexDirection: 'row', alignItems: 'center', gap: 4 },
    legendDot: { width: 8, height: 8, borderRadius: 4 },
    legendText: { fontSize: 10, color: COLORS.textSecondary, fontWeight: 'bold' }
});