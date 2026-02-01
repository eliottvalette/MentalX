import React from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS } from '../constants/theme';

const { width, height } = Dimensions.get('window');

export const BackgroundWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    return (
        <View style={styles.container}>
            <LinearGradient
                colors={[COLORS.cyberBackgroundStart, COLORS.cyberBackgroundEnd]}
                locations={[0, 0.2]}
                style={styles.gradient}
            />

            <View style={styles.gridContainer} pointerEvents="none">
                {[...Array(6)].map((_, i) => (
                    <View key={`v-${i}`} style={[styles.gridLine, { left: (width / 5) * i }]} />
                ))}
                {[...Array(10)].map((_, i) => (
                    <View key={`h-${i}`} style={[styles.gridLineHorizontal, { top: (height / 8) * i }]} />
                ))}
            </View>

            <View style={styles.content}>
                {children}
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#000' },
    gradient: { ...StyleSheet.absoluteFillObject },
    content: { flex: 1 },
    gridContainer: { ...StyleSheet.absoluteFillObject, opacity: 0.3 },
    gridLine: {
        position: 'absolute',
        width: 1,
        height: '100%',
        backgroundColor: 'rgba(255, 255, 255, 0.05)',
    },
    gridLineHorizontal: {
        position: 'absolute',
        width: '100%',
        height: 1,
        backgroundColor: 'rgba(255,255,255,0.05)',
    }
});
