import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS } from '../constants/theme';

interface SuccessFlashProps {
    trigger: number;
    isError?: boolean;
}

export const SuccessFlash: React.FC<SuccessFlashProps> = ({ trigger, isError = false }) => {
    const opacity = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (trigger > 0) {
            opacity.setValue(0.6);
            Animated.timing(opacity, {
                toValue: 0,
                duration: 800,
                useNativeDriver: true,
            }).start();
        }
    }, [trigger]);

    const color = isError ? 'rgba(255, 59, 48, 0.5)' : 'rgba(32, 199, 89, 0.4)';

    return (
        <View style={styles.container} pointerEvents="none">
            <Animated.View style={[styles.overlay, { opacity }]}>
                <LinearGradient
                    colors={[color, 'transparent', 'transparent', color]}
                    locations={[0, 0.15, 0.85, 1]}
                    style={styles.gradientVertical}
                />
                <LinearGradient
                    colors={[color, 'transparent', 'transparent', color]}
                    locations={[0, 0.15, 0.85, 1]}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 0 }}
                    style={styles.gradientHorizontal}
                />
            </Animated.View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        ...StyleSheet.absoluteFillObject,
        zIndex: 999,
    },
    overlay: {
        flex: 1,
    },
    gradientVertical: {
        ...StyleSheet.absoluteFillObject,
    },
    gradientHorizontal: {
        ...StyleSheet.absoluteFillObject,
    },
});
