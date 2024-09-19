import ballerina/io;

// Define the Task record
type Task record {|
    int id;
    string title;
    string description;
    string priority; //"low", "medium", "high"
    string status;    //"pending", "in progress", "completed"
|};

// In-memory storage for tasks
Task[] tasks = [];
int nextId = 1;

function addTask(Task task) {
    task.id = nextId;
    nextId += 1;
    tasks.push(task);
}

function getTaskById(int id) returns Task|error {
    foreach var task in tasks {
        if task.id == id {
            return task;
        }
    }
    return error("Task not found");
}

function getAllTasks() returns Task[] {
    return tasks;
}

function updateTask(int id, Task updatedTask) returns Task|error {
    foreach var i in 0 ..< tasks.length() {
        if tasks[i].id == id {
            updatedTask.id = id;
            tasks[i] = updatedTask;
            return updatedTask;
        }
    }
    return error("Task not found");
}

function deleteTask(int id) returns error? {
    foreach var i in 0 ..< tasks.length() {
        if tasks[i].id == id {
            tasks.remove(i);
            return;
        }
    }
    return error("Task not found");
}

public function main() {
    io:println("Hello, World!");
}