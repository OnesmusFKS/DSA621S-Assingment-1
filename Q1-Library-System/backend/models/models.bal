// Data models for the Library & Resource Management System (Q1).
// These mirror the example payload in the assignment brief.

public type Component record {
    string compId;
    string name;
    string description;
};

public type Task record {
    string taskId;
    string description;
    boolean completed = false;
};

public type WorkOrder record {
    string orderId;
    string status; // OPEN, IN_PROGRESS, CLOSED
    string description;
    Task[] tasks = [];
};

public type Schedule record {
    string scheduleId;
    string 'type; // e.g. MAINTENANCE, BOOKING
    string dueDate;
    string description;
};

public type Asset record {
    string assetTag; // unique key
    string name;
    string description;
    string institution;
    string site;
    string status; // AVAILABLE, LOANED_OUT, UNDER_MAINTENANCE, DISPOSED
    string dateAcquired;
    Component[] components = [];
    Schedule[] schedules = [];
    WorkOrder[] workOrders = [];
};
