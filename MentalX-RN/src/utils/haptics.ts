import * as Haptics from 'expo-haptics';

export const hapticManager = {
    playKeypadTap: () => {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    },

    playSuccess: () => {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    },

    playError: () => {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    },

    playVictory: () => {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    },
};
