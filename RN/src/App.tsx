import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import GoalsScreen from './screens/GoalsScreen';
import StatsScreen from './screens/StatsScreen';

type AppProps = {
  source?: 'stats' | 'goals';
};

const App = ({ source = 'stats' }: AppProps) => {
  const content = source === 'goals' ? <GoalsScreen /> : <StatsScreen />;

  return <SafeAreaProvider>{content}</SafeAreaProvider>;
};

export default App;
