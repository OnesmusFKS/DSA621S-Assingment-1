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
    string assetTag = io:readln("Please enter the asset tag: ");

    json|http:ClientError current = assetClient->get("/" + assetTag);
    if current is http:ClientError {
        io:println("The asset was not found.");
        return;
    }

    map<json> asset = <map<json>>current;
    string status = check asset["status"].ensureType(string);

    if status != "AVAILABLE" {
        io:println("Asset is currently: " + status + " — cannot loan/book.");
        return;
    }

    asset["status"] = "LOANED_OUT";

    json|http:ClientError updateResult = assetClient->put("/" + assetTag, asset);
    if updateResult is http:ClientError {
        io:println("The update failed: ", updateResult.message());
    } else {
        io:println("The loan was successful.");
    }
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
