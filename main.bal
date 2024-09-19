import ballerina/http;

// Define the Task record
type Task record {| 
    int id; 
    string title; 
    string description; 
    string priority; //"low", "medium", "high"
    string status;    //"pending", "in progress", "completed"
|};

// Define the response record
type Response record {|
    string status;
    string message;
    json|Task[]|Task data?;
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
        if (task.id == id) {
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
        if (tasks[i].id == id) {
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
        if (task.id != id) {
            updatedTasks.push(task);
        }
    }

    if (tasks.length() == updatedTasks.length()) {
        return error("Task not found");
    }

    tasks = updatedTasks;
    return;
}

// HTTP Service to manage tasks
service /tasks on new http:Listener(8080) {

    // Add a new task
    resource function post .(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task newTask = check payload.cloneWithType(Task);
        addTask(newTask);
        
        Response res = {
            status: "success",
            message: "task added successfully",
            data: newTask
        };
        check caller->respond(res);
    }

    // Get all tasks
    resource function get .(http:Caller caller) returns error? {
        Task[] allTasks = getAllTasks();
        Response res = {
            status: "success",
            message: "tasks retrieved successfully",
            data: allTasks
        };
        check caller->respond(res);
    }

    // Get a task by ID
    resource function get [int id](http:Caller caller) returns error? {
        Task|error task = getTaskById(id);
        if task is Task {
            Response res = {
                status: "success",
                message: "task retrieved successfully",
                data: task
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "error",
                message: "Task not found"
            };
            check caller->respond(res);
        }
    }

    // Update a task by ID
    resource function put [int id](http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task updatedTask = check payload.cloneWithType(Task);
        Task|error result = updateTask(id, updatedTask);

        if result is Task {
            Response res = {
                status: "success",
                message: "task updated successfully",
                data: result
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "error",
                message: "Task not found"
            };
            check caller->respond(res);
        }
    }

    // Delete a task by ID
    resource function delete [int id](http:Caller caller) returns error? {
        error? deleteResult = deleteTask(id);
        if deleteResult is error {
            Response res = {
                status: "error",
                message: "Task not found"
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "success",
                message: "task deleted successfully"
            };
            check caller->respond(res);
        }
    }
}