import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { SRSItem, SRSStatus } from '../types';
import { CyberCard } from './CyberCard';
import { COLORS, FONTS } from '../constants/theme';

interface SRSListRowProps {
    item: SRSItem;
}

const getStatusIcon = (status: SRSStatus): string => {
    switch (status) {
        case SRSStatus.CRITICAL:
            return '!!';
        case SRSStatus.UNSTABLE:
            return '??';
        case SRSStatus.STABLE:
            return 'OK';
        default:
            return '';
    }
};

const getStatusColor = (status: SRSStatus): string => {
    switch (status) {
        case SRSStatus.CRITICAL:
            return COLORS.neonRed;
        case SRSStatus.UNSTABLE:
            return COLORS.orange;
        case SRSStatus.STABLE:
            return COLORS.neonGreen;
        default:
            return COLORS.textSecondary;
    }
};

export const SRSListRow: React.FC<SRSListRowProps> = ({ item }) => {
    const statusColor = getStatusColor(item.status);
    const icon = getStatusIcon(item.status);

    return (
        <CyberCard
            style={
                item.status === SRSStatus.CRITICAL
                    ? { ...styles.container, borderColor: `${COLORS.neonRed}33` }
                    : styles.container
            }
        >
            <View style={styles.content}>
                <View style={[styles.iconCircle, { borderColor: `${statusColor}4D` }]}>
                    <Text style={[styles.icon, { color: statusColor }]}>{icon}</Text>
                </View>

                <View style={styles.infoContainer}>
                    <Text style={styles.operation}>{item.operation}</Text>
                    <View style={styles.stats}>
                        <Text
                            style={[
                                styles.statText,
                                item.avgTime > 3.0 ? { color: COLORS.neonRed } : {},
                            ]}
                        >
                            {item.avgTime.toFixed(1)}s avg
                        </Text>
                        <Text style={styles.separator}>•</Text>
                        <Text
                            style={[
                                styles.statText,
                                item.errorRate > 0.1 ? { color: COLORS.neonRed } : {},
                            ]}
                        >
                            Err: {Math.round(item.errorRate * 100)}%
                        </Text>
                    </View>
                </View>

                <View style={styles.masteryContainer}>
                    <Text style={[styles.masteryText, { color: statusColor }]}>
                        {Math.round(item.mastery * 100)}%
                    </Text>
                    <View style={styles.progressBarBackground}>
                        <View
                            style={[
                                styles.progressBarFill,
                                {
                                    width: `${item.mastery * 100}%`,
                                    backgroundColor: statusColor,
                                },
                            ]}
                        />
                    </View>
                </View>
            </View>
        </CyberCard>
    );
};

const styles = StyleSheet.create({
    container: {
        marginBottom: 12,
    },
    content: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    iconCircle: {
        width: 40,
        height: 40,
        borderRadius: 20,
        borderWidth: 2,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 16,
    },
    icon: {
        fontSize: 14,
        fontWeight: 'bold',
    },
    infoContainer: {
        flex: 1,
    },
    operation: {
        fontSize: FONTS.title2,
        fontWeight: 'bold',
        color: COLORS.textPrimary,
    },
    stats: {
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 4,
    },
    statText: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
    },
    separator: {
        fontSize: FONTS.caption,
        color: COLORS.textSecondary,
        marginHorizontal: 6,
    },
    masteryContainer: {
        alignItems: 'flex-end',
        marginLeft: 16,
    },
    masteryText: {
        fontSize: FONTS.caption,
        fontWeight: 'bold',
        marginBottom: 4,
    },
    progressBarBackground: {
        width: 80,
        height: 6,
        backgroundColor: COLORS.black,
        borderRadius: 3,
        overflow: 'hidden',
    },
    progressBarFill: {
        height: 6,
        borderRadius: 3,
    },
});
