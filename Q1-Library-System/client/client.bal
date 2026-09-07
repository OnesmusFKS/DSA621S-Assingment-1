import ballerina/http;
import ballerina/io;

http:Client assetClient = check new ("http://localhost:8080/assets");

public function main() returns error? {
    boolean running = true;
    while running {
        io:println("\n===== LIBRARY & RESOURCE SYSTEM =====");
        io:println("1. Loan/Book an asset");
        io:println("2. View all assets (global view)");
        io:println("3. Filter by institution/campus");
        io:println("4. View overdue items");
        io:println("5. Manage schedules");
        io:println("6. Exit");
        string choice = io:readln("Choose an option: ");

        match choice {
            "1" => { check loanOrBookAsset(); }
            "2" => { check viewAllAssets(); }
            "3" => { check filterByCampus(); }
            "4" => { check viewOverdue(); }
            "5" => { check manageSchedule(); }
            "6" => { running = false; }
            _ => { io:println("Invalid option."); }
        }
    }
}

function loanOrBookAsset() returns error? {
    // TODO: PUT the asset's status to LOANED_OUT/OCCUPIED via assetClient
    int assetTag = check io:readln("Enter asset tag: ").toInt();
    // TODO: Implement the loan/book logic
}

function viewAllAssets() returns error? {
    // TODO: GET / and print the list
}

function filterByCampus() returns error? {
    // TODO: prompt for institution or site, GET /institution/{x} or /site/{x}
}

function viewOverdue() returns error? {
    // TODO: GET /maintenance/overdue and print
}

function manageSchedule() returns error? {
    // TODO: POST/DELETE to /{assetTag}/schedules
}
