import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { DashboardScreen } from './src/screens/DashboardScreen';
import { ActiveGameScreen } from './src/screens/ActiveGameScreen';

import { GameMode } from './src/types';

type RootStackParamList = {
  Dashboard: undefined;
  ActiveGame: { mode: GameMode };
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="light" />
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: '#040404' },
        }}
      >
        <Stack.Screen name="Dashboard" component={DashboardScreen} />
        <Stack.Screen
          name="ActiveGame"
          component={ActiveGameScreen}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
