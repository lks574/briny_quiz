import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

const GoalsScreen = () => {
  const dailyGoals = [
    { label: '오늘 퀴즈 풀이', value: 6, target: 10, unit: '문제' },
    { label: '정답률', value: 82, target: 90, unit: '%' },
    { label: '연속 정답', value: 9, target: 12, unit: '문제' }
  ];

  const weeklyGoals = [
    { label: '주간 퀴즈 풀이', value: 48, target: 70, unit: '문제' },
    { label: '주간 플레이', value: 4, target: 5, unit: '일' },
    { label: '최고 연속 정답', value: 12, target: 15, unit: '문제' }
  ];

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.title}>목표</Text>
          <Text style={styles.subtitle}>일일 · 주간 목표 진행률</Text>
        </View>

        <View style={[styles.card, styles.highlightCard]}>
          <Text style={styles.cardTitle}>오늘의 진행</Text>
          <View style={styles.progressRow}>
            <View style={styles.progressCircle}>
              <Text style={styles.progressValue}>62%</Text>
              <Text style={styles.progressLabel}>달성</Text>
            </View>
            <View style={styles.progressSummary}>
              <Text style={styles.summaryTitle}>다음 목표</Text>
              <Text style={styles.summaryValue}>정답률 90%</Text>
              <Text style={styles.summaryMeta}>현재 82% · +8%p 남음</Text>
            </View>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>일일 목표</Text>
          {dailyGoals.map((item, index) => {
            const progress = Math.min(item.value / item.target, 1);
            const isLast = index === dailyGoals.length - 1;
            return (
              <View key={item.label} style={[styles.goalRow, isLast && styles.goalRowLast]}>
                <View style={styles.goalHeader}>
                  <Text style={styles.goalLabel}>{item.label}</Text>
                  <Text style={styles.goalValue}>
                    {item.value}/{item.target}
                    {item.unit}
                  </Text>
                </View>
                <View style={styles.barTrack}>
                  <View style={[styles.barFill, { width: `${progress * 100}%` }]} />
                </View>
              </View>
            );
          })}
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>주간 목표</Text>
          {weeklyGoals.map((item, index) => {
            const progress = Math.min(item.value / item.target, 1);
            const isLast = index === weeklyGoals.length - 1;
            return (
              <View key={item.label} style={[styles.goalRow, isLast && styles.goalRowLast]}>
                <View style={styles.goalHeader}>
                  <Text style={styles.goalLabel}>{item.label}</Text>
                  <Text style={styles.goalValue}>
                    {item.value}/{item.target}
                    {item.unit}
                  </Text>
                </View>
                <View style={styles.barTrack}>
                  <View style={[styles.barFill, { width: `${progress * 100}%` }]} />
                </View>
              </View>
            );
          })}
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>연속 학습</Text>
          <View style={styles.streakRow}>
            <View style={styles.streakItem}>
              <Text style={styles.streakValue}>4일</Text>
              <Text style={styles.streakLabel}>현재</Text>
            </View>
            <View style={styles.streakDivider} />
            <View style={styles.streakItem}>
              <Text style={styles.streakValue}>9일</Text>
              <Text style={styles.streakLabel}>최고</Text>
            </View>
            <View style={styles.streakDivider} />
            <View style={styles.streakItem}>
              <Text style={styles.streakValue}>2일</Text>
              <Text style={styles.streakLabel}>남은 목표</Text>
            </View>
          </View>
          <Text style={styles.streakMeta}>오늘 1회만 더 풀면 목표 달성</Text>
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
  card: {
    borderRadius: 18,
    padding: 16,
    backgroundColor: '#0F2234',
    borderWidth: 1,
    borderColor: '#1B3550'
  },
  highlightCard: {
    backgroundColor: '#14293F',
    borderColor: '#244561'
  },
  cardTitle: {
    color: '#E6F2FF',
    fontSize: 16,
    fontWeight: '700',
    marginBottom: 12
  },
  progressRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16
  },
  progressCircle: {
    width: 92,
    height: 92,
    borderRadius: 46,
    borderWidth: 2,
    borderColor: '#4EC6FF',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#0D2133'
  },
  progressValue: {
    color: '#E6F2FF',
    fontSize: 20,
    fontWeight: '700'
  },
  progressLabel: {
    color: '#9AB3CC',
    fontSize: 12,
    marginTop: 4
  },
  progressSummary: {
    flex: 1
  },
  summaryTitle: {
    color: '#9AB3CC',
    fontSize: 12,
    fontWeight: '600'
  },
  summaryValue: {
    color: '#E6F2FF',
    fontSize: 18,
    fontWeight: '700',
    marginTop: 6
  },
  summaryMeta: {
    color: '#6FA8DC',
    fontSize: 12,
    marginTop: 4
  },
  goalRow: {
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#1B3550'
  },
  goalRowLast: {
    borderBottomWidth: 0,
    paddingBottom: 0
  },
  goalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8
  },
  goalLabel: {
    color: '#9AB3CC',
    fontSize: 13
  },
  goalValue: {
    color: '#E6F2FF',
    fontSize: 13,
    fontWeight: '600'
  },
  barTrack: {
    height: 8,
    backgroundColor: '#162C43',
    borderRadius: 999
  },
  barFill: {
    height: 8,
    backgroundColor: '#4EC6FF',
    borderRadius: 999
  },
  streakRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#0D2133',
    borderRadius: 12,
    padding: 12
  },
  streakItem: {
    alignItems: 'center',
    flex: 1
  },
  streakDivider: {
    width: 1,
    height: 36,
    backgroundColor: '#1B3550'
  },
  streakValue: {
    color: '#E6F2FF',
    fontSize: 16,
    fontWeight: '700'
  },
  streakLabel: {
    color: '#9AB3CC',
    fontSize: 11,
    marginTop: 4
  },
  streakMeta: {
    marginTop: 10,
    color: '#6FA8DC',
    fontSize: 12
  }
});

export default GoalsScreen;
