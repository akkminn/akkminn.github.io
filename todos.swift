import Foundation

struct ToDo {
    var toDoId: Int
    var toDoTitle: String
    var toDoStatus: Bool
}

let sampleToDos = [
    ToDo(toDoId: 1, toDoTitle: "TestSet 1 - Day 1", toDoStatus: false),
    ToDo(toDoId: 2, toDoTitle: "TestSet 2 - Day 2", toDoStatus: true),
    ToDo(toDoId: 3, toDoTitle: "TestSet 1 - Day 3", toDoStatus: false),
    ToDo(toDoId: 4, toDoTitle: "TestSet 2 - Day 4", toDoStatus: true),
    ToDo(toDoId: 5, toDoTitle: "TestSet 1 - Day 5", toDoStatus: true),
    ToDo(toDoId: 6, toDoTitle: "TestSet 2 - Day 6", toDoStatus: true),
    ToDo(toDoId: 7, toDoTitle: "TestSet 1 - Day 7", toDoStatus: false),
    ToDo(toDoId: 8, toDoTitle: "TestSet 2 - Day 8", toDoStatus: false),
    ToDo(toDoId: 9, toDoTitle: "TestSet 1 - Day 9", toDoStatus: true),
    ToDo(toDoId: 10, toDoTitle: "TestSet 2 - Day 10", toDoStatus: true)
]

func filterCompletedEvenToDos(toDos: [ToDo]) -> [ToDo] {
    return toDos.filter { $0.toDoId % 2 == 0 && $0.toDoStatus == true }
}

// Example usage
let completedEvenToDos = filterCompletedEvenToDos(toDos: sampleToDos)
print(completedEvenToDos)
