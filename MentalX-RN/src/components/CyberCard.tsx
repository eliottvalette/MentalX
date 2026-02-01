import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS } from '../constants/theme';

interface CyberCardProps {
    children: React.ReactNode;
    style?: ViewStyle;
}

export const CyberCard: React.FC<CyberCardProps> = ({ children, style }) => (
    <LinearGradient
        colors={[COLORS.cardGradientStart, COLORS.cardGradientEnd]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[styles.card, style]}
    >
        <View style={styles.innerHighlight} />
        {children}
    </LinearGradient>
);

const styles = StyleSheet.create({
    card: {
        borderRadius: 8,
        padding: 16,
        borderWidth: 1,
        borderColor: COLORS.borderSubtle,
        overflow: 'hidden',
    },
    innerHighlight: {
        position: 'absolute',
        top: 0, left: 0, right: 0,
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.05)',
    }
});
