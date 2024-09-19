import ballerina/http;

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
    foreach Task task in tasks {
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
    foreach int i in 0 ..< tasks.length() {
        if tasks[i].id == id {
            updatedTask.id = id;
            tasks[i] = updatedTask;
            return updatedTask;
        }
    }
    return error("Task not found");
}

function deleteTask(int id) returns error? {
    Task[] updatedTasks = [];

    foreach Task task in tasks {
        if task.id != id {
            updatedTasks.push(task);
        }
    }

    if tasks.length() == updatedTasks.length() {
        return error("Task not found");
    }

    tasks = updatedTasks;
    return;
}

// HTTP Service to manage tasks
service /tasks on new http:Listener(8080) {

    resource function post .(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task newTask = check payload.cloneWithType(Task);
        addTask(newTask);
        check caller->respond(newTask);
    }

    resource function get .() returns Task[] {
        return getAllTasks();
    }

    resource function get [int id]() returns Task|error {
        return getTaskById(id);
    }

    resource function put [int id](http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task updatedTask = check payload.cloneWithType(Task);
        Task result = check updateTask(id, updatedTask);
        check caller->respond(result);
    }

    resource function delete [int id](http:Caller caller) returns error? {
        check deleteTask(id);
        check caller->respond("Task deleted");
    }
}