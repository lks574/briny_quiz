import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import StatsScreen from './screens/StatsScreen';

const App = () => {
  return (
    <SafeAreaProvider>
      <StatsScreen />
    </SafeAreaProvider>
  );
};

export default App;
