import Foundation
import Observation

@MainActor
@Observable
final class HistoryStore {
    enum DateFilter: Equatable, CaseIterable {
        case all
        case last7Days
        case last30Days

        var title: String {
            switch self {
            case .all: return "전체"
            case .last7Days: return "7일"
            case .last30Days: return "30일"
            }
        }
    }

    struct State: Equatable {
        struct DisplayItem: Equatable, Identifiable {
            let id: String
            let date: Date
            let correctCount: Int
            let totalCount: Int
            let isSuccess: Bool
        }

        var items: [HistoryItem]
        var filteredItems: [HistoryItem]
        var displayItems: [DisplayItem]
        var isLoading: Bool
        var errorMessage: String?
        var dateFilter: DateFilter
    }

    enum Action: Equatable {
        case onAppear
        case refreshTapped
        case dateFilterChanged(DateFilter)
    }

    enum InternalAction: Equatable {
        case setLoading(Bool)
        case setItems([HistoryItem])
        case setFilteredItems([HistoryItem])
        case setDisplayItems([State.DisplayItem])
        case setError(String?)
        case setDateFilter(DateFilter)
    }

    private let fetchHistoryUseCase: FetchHistoryUseCase

    var state: State

    init(fetchHistoryUseCase: FetchHistoryUseCase) {
        self.fetchHistoryUseCase = fetchHistoryUseCase
        self.state = State(
            items: [],
            filteredItems: [],
            displayItems: [],
            isLoading: false,
            errorMessage: nil,
            dateFilter: .all
        )
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            load()
        case .refreshTapped:
            load()
        case .dateFilterChanged(let filter):
            reduce(.setDateFilter(filter))
            applyFilters()
        }
    }

    private func load() {
        Task { [weak self] in
            guard let self else { return }
            reduce(.setLoading(true))
            let items = await fetchHistoryUseCase.execute()
            reduce(.setItems(items))
            applyFilters()
            reduce(.setLoading(false))
        }
    }

    private func reduce(_ action: InternalAction) {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .setItems(let items):
            state.items = items
        case .setFilteredItems(let items):
            state.filteredItems = items
        case .setDisplayItems(let items):
            state.displayItems = items
        case .setError(let message):
            state.errorMessage = message
        case .setDateFilter(let filter):
            state.dateFilter = filter
        }
    }
}

private extension HistoryStore {
    func applyFilters() {
        var items = state.items
        items = applyDateFilter(items)
        reduce(.setFilteredItems(items))
        reduce(.setDisplayItems(makeDisplayItems(items)))
    }

    func applyDateFilter(_ items: [HistoryItem]) -> [HistoryItem] {
        switch state.dateFilter {
        case .all:
            return items
        case .last7Days:
            return filterByDays(items, days: 7)
        case .last30Days:
            return filterByDays(items, days: 30)
        }
    }

    func filterByDays(_ items: [HistoryItem], days: Int) -> [HistoryItem] {
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: Calendar.Component.day, value: -days, to: Date()) else { return items }
        return items.filter { $0.result.date >= start }
    }

    func makeDisplayItems(_ items: [HistoryItem]) -> [State.DisplayItem] {
        items.map { item in
            State.DisplayItem(
                id: item.id,
                date: item.result.date,
                correctCount: item.result.correctCount,
                totalCount: item.result.totalCount,
                isSuccess: isSuccess(item.result)
            )
        }
    }

    func isSuccess(_ result: QuizResult) -> Bool {
        if result.totalCount == 5 {
            return result.correctCount >= 4
        }
        let ratio = Double(result.correctCount) / Double(max(result.totalCount, 1))
        return ratio >= 0.8
    }
}
