import React from 'react';
import { SafeAreaView, StyleSheet, Text, View } from 'react-native';

const App = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>Briny Quiz RN</Text>
        <Text style={styles.subtitle}>React Native 0.83 (New Architecture)</Text>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#0B1B2B'
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24
  },
  title: {
    color: '#E6F2FF',
    fontSize: 28,
    fontWeight: '700'
  },
  subtitle: {
    color: '#9AB3CC',
    marginTop: 8,
    fontSize: 14
  }
});

export default App;
