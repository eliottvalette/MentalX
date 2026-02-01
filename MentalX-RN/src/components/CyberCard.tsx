import React from 'react';
import { View, StyleSheet, ViewStyle } from 'react-native';
import { COLORS } from '../constants/theme';

interface CyberCardProps {
    children: React.ReactNode;
    style?: ViewStyle;
}

export const CyberCard: React.FC<CyberCardProps> = ({ children, style }) => (
    <View style={[styles.card, style]}>{children}</View>
);

const styles = StyleSheet.create({
    card: {
        backgroundColor: COLORS.cyberCard,
        borderRadius: 16,
        padding: 16,
        // BORDURE FINE pour l'effet "Sharp"
        borderWidth: 1,
        borderColor: COLORS.borderSubtle,
        // OMBRE pour la profondeur
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 4,
        },
        shadowOpacity: 0.3,
        shadowRadius: 4.65,
        elevation: 8,
    },
});
