# TaskTrek-Backend

**Simple Task Management API built with Ballerina**

TaskTrek-Backend is a lightweight and simple REST API for managing tasks. Built using the Ballerina programming language, it provides essential CRUD operations to manage tasks with different priorities and statuses.


## Features

- Add new tasks
- View all tasks
- Get a task by ID
- Update a task
- Delete a task


## Task Structure

Each task contains the following fields:

- `id`: Unique identifier for the task (auto-generated)
- `title`: Title of the task
- `description`: Description of the task
- `priority`: Priority of the task (`low`, `medium`, `high`)
- `status`: Status of the task (`pending`, `in progress`, `completed`)


## Endpoints

The API provides the following endpoints:

### 1. Add a New Task

- **Endpoint**: `/tasks`
- **Method**: `POST`
- **Request Body**:
```json
{
    "title": "Sample Task",
    "description": "Task description",
    "priority": "high",
    "status": "pending"
}
```
**Response**:
```json
{
    "status": "success",
    "message": "task added successfully",
    "data": {
        "id": 1,
        "title": "Sample Task",
        "description": "Task description",
        "priority": "high",
        "status": "pending"
    }
}
```

### 2. Get All Tasks

- **Endpoint**: `/tasks`
- **Method**: `GET`
- **Response**:
```json
  {
      "status": "success",
      "message": "tasks retrieved successfully",
      "data": [
          {
              "id": 1,
              "title": "Sample Task",
              "description": "Task description",
              "priority": "high",
              "status": "pending"
          }
      ]
  }
```

### 3. Get Task by ID

- **Endpoint**: `/tasks/{id}`
- **Method**: `GET`
- **Response**:
```json
  {
      "status": "success",
      "message": "task retrieved successfully",
      "data": {
          "id": 1,
          "title": "Sample Task",
          "description": "Task description",
          "priority": "high",
          "status": "pending"
      }
  }
```

### 4. Update Task by ID

- **Endpoint**: `/tasks/{id}`
- **Method**: `PUT`
- **Request Body**:
```json
  {
      "title": "Updated Task",
      "description": "Updated description",
      "priority": "medium",
      "status": "in progress"
  }
```
- **Response**:
```json
  {
        "status": "success",
        "message": "task updated successfully",
        "data": {
            "id": 1,
            "title": "Updated Task",
            "description": "Updated description",
            "priority": "medium",
            "status": "in progress"
        }
  }
```

### 5. Delete Task by ID

- **Endpoint**: `/tasks/{id}`
- **Method**: `DELETE`
- **Response**:
```json
  {
      "status": "success",
      "message": "task deleted successfully"
  }
```


## Running the Service

1. Install [Ballerina](https://ballerina.io/).
2. Clone this repository:
```bash
   git clone https://github.com/hirunaofficial/TaskTrek-Backend.git
```
3. Navigate to the project directory:
```bash
   cd TaskTrek-Backend
```
4. Run the Ballerina service:
```bash
   bal run
```
5. The service will be available at http://localhost:8080/tasks.


## License

This project is licensed under the GPL-3.0 License. See the LICENSE file for details.


### Contact

- Author: Hiruna Gallage
- Website: [hiruna.dev](https://hiruna.dev)
- Email: [hello@hiruna.dev](mailto:hello@hiruna.dev)
