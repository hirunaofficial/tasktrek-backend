import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string host = "localhost";
configurable int port = 3306;
configurable string user = "root";
configurable string password = "";
configurable string database = "task_trek";

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

// MySQL client
mysql:Client dbClient = check new (host, user, password, database, port);

// Function to create the Tasks table if it doesn't exist
function createTasksTable() returns error? {
    sql:ExecutionResult result = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS Tasks (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            priority ENUM('low', 'medium', 'high') NOT NULL,
            status ENUM('pending', 'in progress', 'completed') NOT NULL
        );
    `);
    if result.affectedRowCount == 0 {
        return error("Failed to add table");
    }
}

// Add a task to the MySQL database
function addTask(Task task) returns error? {
    sql:ExecutionResult result = check dbClient->execute(`
        INSERT INTO Tasks (title, description, priority, status)
        VALUES (${task.title}, ${task.description}, ${task.priority}, ${task.status})`);
    if result.affectedRowCount == 0 {
        return error("Failed to add task");
    }
}

// Get a task by ID from the MySQL database
function getTaskById(int id) returns Task|error {
    Task|sql:Error task = dbClient->queryRow(`SELECT * FROM Tasks WHERE id = ${id}`, Task);
    if task is sql:NoRowsError {
        return error("No task found with the specified ID.");
    }
    return task;
}

function getAllTasks() returns Task[]|error {
    stream<Task, sql:Error?> taskStream = dbClient->query(`SELECT * FROM Tasks`, Task);
    Task[] tasks = [];
    
    error? e = from Task task in taskStream
               do {
                   tasks.push(task);
               };

    if e is sql:Error {
        return e;
    }

    return tasks;
}

// Update a task by ID in the MySQL database
function updateTask(int id, Task updatedTask) returns error? {
    sql:ExecutionResult result = check dbClient->execute(`
        UPDATE Tasks SET title = ${updatedTask.title}, description = ${updatedTask.description},
        priority = ${updatedTask.priority}, status = ${updatedTask.status}
        WHERE id = ${id}`);
    if result.affectedRowCount == 0 {
        return error("No task found with the specified ID to update.");
    }
}

// Delete a task by ID from the MySQL database
function deleteTask(int id) returns error? {
    sql:ExecutionResult result = check dbClient->execute(`DELETE FROM Tasks WHERE id = ${id}`);
    if result.affectedRowCount == 0 {
        return error("No task found with the specified ID to delete.");
    }
}

// HTTP Service to manage tasks
service /tasks on new http:Listener(8080) {

    // Initialization function to create the table
    function init() returns error? {
        check createTasksTable();
    }

    // Add a new task
    resource function post .(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task newTask = check payload.cloneWithType(Task);
        check addTask(newTask);
        
        Response res = {
            status: "success",
            message: "Task added successfully.",
            data: newTask
        };
        check caller->respond(res);
    }

    // Get all tasks
    resource function get .(http:Caller caller) returns error? {
        Task[] allTasks = check getAllTasks();
        Response res = {
            status: "success",
            message: "Tasks retrieved successfully.",
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
                message: "Task retrieved successfully.",
                data: task
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "error",
                message: "No task found with the specified ID."
            };
            check caller->respond(res);
        }
    }

    // Update a task by ID
    resource function put [int id](http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        Task updatedTask = check payload.cloneWithType(Task);
        error? result = updateTask(id, updatedTask);

        if result is error {
            Response res = {
                status: "error",
                message: "No task found with the specified ID to update."
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "success",
                message: "Task updated successfully.",
                data: updatedTask
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
                message: "No task found with the specified ID to delete."
            };
            check caller->respond(res);
        } else {
            Response res = {
                status: "success",
                message: "Task deleted successfully."
            };
            check caller->respond(res);
        }
    }
}
