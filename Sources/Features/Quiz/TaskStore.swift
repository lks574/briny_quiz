import Foundation

actor TaskStore<ID: Hashable> {
    struct TaskHandle {
        let cancel: () -> Void
    }

    private var tasks: [ID: TaskHandle] = [:]

    func setTask<T>(_ id: ID, task: Task<T, Never>) {
        set(id, cancel: { task.cancel() })
    }

    func setTask<T, E: Error>(_ id: ID, task: Task<T, E>) {
        set(id, cancel: { task.cancel() })
    }

    func set(_ id: ID, cancel: @escaping () -> Void) {
        tasks[id]?.cancel()
        tasks[id] = TaskHandle(cancel: cancel)
    }

    func cancel(_ id: ID) {
        tasks[id]?.cancel()
        tasks[id] = nil
    }

    func remove(_ id: ID) {
        tasks[id] = nil
    }

    func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
