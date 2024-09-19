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

public function main() {
    io:println("Hello, World!");
}