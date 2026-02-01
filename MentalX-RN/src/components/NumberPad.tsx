import React, { useRef } from 'react';
import { View, Text, Pressable, StyleSheet, Animated } from 'react-native';
import { COLORS } from '../constants/theme';
import { hapticManager } from '../utils/haptics';

const GlowButton = ({ num, onPress, isDelete = false }: any) => {
    const animValue = useRef(new Animated.Value(0)).current;

    const handlePressIn = () => {
        hapticManager.playKeypadTap();
        Animated.timing(animValue, {
            toValue: 1,
            duration: 50,
            useNativeDriver: false,
        }).start();
        onPress();
    };

    const handlePressOut = () => {
        Animated.timing(animValue, {
            toValue: 0,
            duration: 300,
            useNativeDriver: false,
        }).start();
    };

    const backgroundColor = animValue.interpolate({
        inputRange: [0, 1],
        outputRange: [
            'rgba(255,255,255,0.03)',
            'rgba(255, 255, 255, 0.2)'
        ]
    });

    const borderColor = animValue.interpolate({
        inputRange: [0, 1],
        outputRange: [
            'rgba(255, 255, 255, 0.05)',
            'rgba(255, 255, 255, 0.5)'
        ]
    });

    return (
        <Pressable
            onPressIn={handlePressIn}
            onPressOut={handlePressOut}
            style={{ flex: 1, marginHorizontal: 8 }}
        >
            <Animated.View style={[
                styles.button,
                {
                    backgroundColor,
                    borderColor
                }
            ]}>
                <Text style={[
                    styles.buttonText,
                    isDelete && { color: COLORS.neonRed }
                ]}>
                    {num}
                </Text>
            </Animated.View>
        </Pressable>
    );
};

export const NumberPad: React.FC<{ onTap: (n: string) => void; onDelete: () => void }> = ({ onTap, onDelete }) => {
    return (
        <View style={styles.container}>
            <View style={styles.row}>
                <GlowButton num="1" onPress={() => onTap("1")} />
                <GlowButton num="2" onPress={() => onTap("2")} />
                <GlowButton num="3" onPress={() => onTap("3")} />
            </View>
            <View style={styles.row}>
                <GlowButton num="4" onPress={() => onTap("4")} />
                <GlowButton num="5" onPress={() => onTap("5")} />
                <GlowButton num="6" onPress={() => onTap("6")} />
            </View>
            <View style={styles.row}>
                <GlowButton num="7" onPress={() => onTap("7")} />
                <GlowButton num="8" onPress={() => onTap("8")} />
                <GlowButton num="9" onPress={() => onTap("9")} />
            </View>
            <View style={styles.row}>
                <View style={{ flex: 1, marginHorizontal: 8 }} />
                <GlowButton num="0" onPress={() => onTap("0")} />
                <GlowButton num="⌫" onPress={onDelete} isDelete />
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        padding: 16,
        marginBottom: 30
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 12,
    },
    button: {
        height: 60,
        borderRadius: 10,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 1,
    },
    buttonText: {
        fontSize: 24,
        fontWeight: '400',
        color: COLORS.textPrimary,
    },
});
