import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { COLORS } from '../constants/theme';
import { hapticManager } from '../utils/haptics';

interface NumberPadProps {
    onTap: (num: string) => void;
    onDelete: () => void;
}

export const NumberPad: React.FC<NumberPadProps> = ({ onTap, onDelete }) => {
    const handleTap = (num: string) => {
        hapticManager.playKeypadTap();
        onTap(num);
    };

    const handleDelete = () => {
        hapticManager.playKeypadTap();
        onDelete();
    };

    return (
        <View style={styles.container}>
            <View style={styles.row}>
                <NumberButton num="1" onPress={handleTap} />
                <NumberButton num="2" onPress={handleTap} />
                <NumberButton num="3" onPress={handleTap} />
            </View>
            <View style={styles.row}>
                <NumberButton num="4" onPress={handleTap} />
                <NumberButton num="5" onPress={handleTap} />
                <NumberButton num="6" onPress={handleTap} />
            </View>
            <View style={styles.row}>
                <NumberButton num="7" onPress={handleTap} />
                <NumberButton num="8" onPress={handleTap} />
                <NumberButton num="9" onPress={handleTap} />
            </View>
            <View style={styles.row}>
                <View style={styles.button} />
                <NumberButton num="0" onPress={handleTap} />
                <TouchableOpacity style={styles.button} onPress={handleDelete}>
                    <Text style={[styles.buttonText, { color: COLORS.neonRed }]}>⌫</Text>
                </TouchableOpacity>
            </View>
        </View>
    );
};

interface NumberButtonProps {
    num: string;
    onPress: (num: string) => void;
}

const NumberButton: React.FC<NumberButtonProps> = ({ num, onPress }) => (
    <TouchableOpacity style={styles.button} onPress={() => onPress(num)}>
        <Text style={styles.buttonText}>{num}</Text>
    </TouchableOpacity>
);

const styles = StyleSheet.create({
    container: {
        padding: 16,
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 20,
    },
    button: {
        flex: 1,
        marginHorizontal: 8,
        height: 60,
        backgroundColor: COLORS.cyberCard,
        borderRadius: 12,
        justifyContent: 'center',
        alignItems: 'center',
    },
    buttonText: {
        fontSize: 28,
        fontWeight: '500',
        color: COLORS.textPrimary,
    },
});
