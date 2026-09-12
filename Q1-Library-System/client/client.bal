import ballerina/http;
import ballerina/io;
import ballerina/url;

http:Client assetClient = check new ("http://localhost:8080/assets");

public function main() returns error? {
    boolean running = true;
    while running {
        io:println("\n ---LIBRARY & RESOURCE SYSTEM ---");
        io:println("1. Loan/Book an asset");
        io:println("2. View all assets ");
        io:println("3. Filter by institution or campus");
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
    json|http:ClientError response = assetClient->get("/");
    
    if response is http:ClientError {
        io:println("Could not fetch assets: ", response.message());
        return;
    }

    json[] assets = <json[]>response;
    
    if assets.length() == 0 {
        io:println("No assets found in the system.");
        return;
    }

    io:println("\n/// ALL ASSETS ///");
    foreach json item in assets {
    map<json> assetMap = <map<json>>item;
    string tag = check assetMap["assetTag"].ensureType(string);
    string name = check assetMap["name"].ensureType(string);
    string institution = check assetMap["institution"].ensureType(string);
    string site = check assetMap["site"].ensureType(string);
    string status = check assetMap["status"].ensureType(string);
    string dateAcquired = check assetMap["dateAcquired"].ensureType(string);
    io:println(string `[${tag}] ${name} | ${institution} - ${site} | Status: ${status} | Acquired: ${dateAcquired}`);
}
}
function filterByCampus() returns error? {
    string filterType = io:readln("Filter by (1) Institution or (2) Site? ");
    string path = "";

    match filterType {
        "1" => {
            string inst = io:readln("Enter institution name: ");
            string encoded = check url:encode(inst, "UTF-8");
            path = "/institution/" + encoded;
        }
        "2" => {
            string site = io:readln("Enter site name: ");
            string encoded = check url:encode(site, "UTF-8");
            path = "/site/" + encoded;
        }
        _ => {
            io:println("Invalid filter choice.");
            return;
        }
    }

    json|http:ClientError response = assetClient->get(path);
    if response is http:ClientError {
        io:println("Search failed: ", response.message());
        return;
    }

    json[] assets = <json[]>response;
    if assets.length() == 0 {
        io:println("No matching assets found.");
        return;
    }

    io:println("\n// FILTER RESULTS ////");
    foreach json item in assets {
        map<json> assetMap = <map<json>>item;
        string tag = check assetMap["assetTag"].ensureType(string);
        string name = check assetMap["name"].ensureType(string);
        string status = check assetMap["status"].ensureType(string);
        io:println(string `[${tag}] ${name} - ${status}`);
    }
}

function viewOverdue() returns error? {
    // Expects backend to calculate overdue logic and return the filtered list at this endpoint
    json|http:ClientError response = assetClient->get("/maintenance/overdue");
    
    if response is http:ClientError {
        io:println("Failed to get  overdue items sorry :", response.message());
        return;
    }

    json[] assets = <json[]>response;
    
    if assets.length() == 0 {
        io:println("No items are currently overdue now .");
        return;
    }

    io:println("\n//// OVERDUE ASSETS///");
    foreach json item in assets {
        map<json> assetMap = <map<json>>item;
        string tag = check assetMap["assetTag"].ensureType(string);
        string name = check assetMap["name"].ensureType(string);
        
        io:println(string `WARNING: [${tag}] ${name} is OVERDUE`);
    }
}

function manageSchedule() returns error? {
    string assetTag = io:readln("Enter the asset tag to manage: ");
    string action = io:readln("Do you want to (1) Add a Schedule or (2) Delete a Schedule? ");

    match action {
        "1" => {
            string date = io:readln("Enter schedule date in this order  (YYYY-MM-DD): ");
            string desc = io:readln("Enter schedule description: ");
            
           
            json payload = { 
                "type": "MAINTENANCE",
                "dueDate": date,
                "description": desc
            };
            
            json|http:ClientError res = assetClient->post("/" + assetTag + "/schedules", payload);
            
            if res is http:ClientError {
                io:println("Failed to add schedule: ", res.message());
            } else {
                io:println("Schedule is added successfully .");
            }
        }
        "2" => {
            string scheduleId = io:readln("Enter the schedule ID to delete: ");
            
            http:Response|http:ClientError res = assetClient->delete("/" + assetTag + "/schedules/" + scheduleId);
            
            if res is http:ClientError {
                io:println("Failed to delete schedule: ", res.message());
            } else {
                io:println("Schedule successfully removed.");
            }
        }
        _ => {
            io:println("Invalid option.");
        }
    }
}
