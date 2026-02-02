import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

const StatsScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title}>통계</Text>
          <Text style={styles.subtitle}>최근 7일 요약</Text>
        </View>

        <View style={styles.kpiRow}>
          <View style={[styles.kpiCard, styles.kpiPrimary]}>
            <Text style={styles.kpiLabel}>총 문제</Text>
            <Text style={styles.kpiValue}>120</Text>
            <Text style={styles.kpiMeta}>+18% vs 이전 주</Text>
          </View>
          <View style={styles.kpiCard}>
            <Text style={styles.kpiLabel}>정답률</Text>
            <Text style={styles.kpiValue}>82%</Text>
            <Text style={styles.kpiMeta}>+4%p</Text>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>카테고리별 정답률</Text>
          {[
            { label: '일반 상식', value: 88 },
            { label: '과학', value: 74 },
            { label: '역사', value: 69 },
            { label: '스포츠', value: 81 }
          ].map(item => (
            <View key={item.label} style={styles.barRow}>
              <Text style={styles.barLabel}>{item.label}</Text>
              <View style={styles.barTrack}>
                <View style={[styles.barFill, { width: `${item.value}%` }]} />
              </View>
              <Text style={styles.barValue}>{item.value}%</Text>
            </View>
          ))}
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>최근 성과</Text>
          {[
            { label: '연속 정답', value: '9문제' },
            { label: '최고 점수', value: '48점' },
            { label: '평균 응답 시간', value: '6.4초' }
          ].map(item => (
            <View key={item.label} style={styles.statRow}>
              <Text style={styles.statLabel}>{item.label}</Text>
              <Text style={styles.statValue}>{item.value}</Text>
            </View>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#0B1B2B'
  },
  content: {
    padding: 24,
    gap: 16
  },
  header: {
    marginBottom: 4
  },
  title: {
    color: '#E6F2FF',
    fontSize: 28,
    fontWeight: '700'
  },
  subtitle: {
    color: '#9AB3CC',
    marginTop: 6,
    fontSize: 14
  },
  kpiRow: {
    flexDirection: 'row',
    gap: 12
  },
  kpiCard: {
    flex: 1,
    borderRadius: 16,
    padding: 16,
    backgroundColor: '#13273B',
    borderWidth: 1,
    borderColor: '#1E3956'
  },
  kpiPrimary: {
    backgroundColor: '#173857',
    borderColor: '#28557D'
  },
  kpiLabel: {
    color: '#9AB3CC',
    fontSize: 12,
    fontWeight: '600'
  },
  kpiValue: {
    color: '#E6F2FF',
    fontSize: 24,
    fontWeight: '700',
    marginTop: 6
  },
  kpiMeta: {
    color: '#6FA8DC',
    marginTop: 4,
    fontSize: 12
  },
  card: {
    borderRadius: 18,
    padding: 16,
    backgroundColor: '#0F2234',
    borderWidth: 1,
    borderColor: '#1B3550'
  },
  cardTitle: {
    color: '#E6F2FF',
    fontSize: 16,
    fontWeight: '700',
    marginBottom: 12
  },
  barRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10
  },
  barLabel: {
    width: 86,
    color: '#9AB3CC',
    fontSize: 12
  },
  barTrack: {
    flex: 1,
    height: 8,
    backgroundColor: '#162C43',
    borderRadius: 999
  },
  barFill: {
    height: 8,
    backgroundColor: '#4EC6FF',
    borderRadius: 999
  },
  barValue: {
    width: 40,
    textAlign: 'right',
    color: '#9AB3CC',
    fontSize: 12
  },
  statRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#1B3550'
  },
  statLabel: {
    color: '#9AB3CC',
    fontSize: 13
  },
  statValue: {
    color: '#E6F2FF',
    fontSize: 13,
    fontWeight: '600'
  }
});

export default StatsScreen;
