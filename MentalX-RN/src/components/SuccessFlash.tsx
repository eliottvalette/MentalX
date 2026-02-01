import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS } from '../constants/theme';

interface SuccessFlashProps {
    trigger: number;
}

export const SuccessFlash: React.FC<SuccessFlashProps> = ({ trigger }) => {
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

    return (
        <View style={styles.container} pointerEvents="none">
            <Animated.View style={[styles.overlay, { opacity }]}>
                <LinearGradient
                    colors={[
                        'rgba(32, 199, 89, 0.4)',
                        'rgba(32, 199, 89, 0)',
                        'rgba(32, 199, 89, 0)',
                        'rgba(32, 199, 89, 0.4)',
                    ]}
                    locations={[0, 0.15, 0.85, 1]}
                    style={styles.gradient}
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
    gradient: {
        flex: 1,
    },
});
