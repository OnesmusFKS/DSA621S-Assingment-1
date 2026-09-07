import ballerina/grpc;
import ballerina/io;

// NOTE: RentalServiceClient is generated from rental.proto - adjust the
// name if the generated stub calls it something else.

public function main() returns error? {
    RentalServiceClient rentalClient = check new ("http://localhost:9090");

    boolean running = true;
    while running {
        io:println("\n===== RENTAL SYSTEM =====");
        io:println("1. Add Property");
        io:println("2. Update Property");
        io:println("3. Remove Property");
        io:println("4. List Available Properties");
        io:println("5. Search Property");
        io:println("6. Book Property");
        io:println("7. Confirm Booking");
        io:println("8. Create Users");
        io:println("9. Exit");
        string choice = io:readln("Choose an option: ");

        match choice {
            "1" => { check addProperty(rentalClient); }
            "2" => { check updateProperty(rentalClient); }
            "3" => { check removeProperty(rentalClient); }
            "4" => { check listAvailableProperties(rentalClient); }
            "5" => { check searchProperty(rentalClient); }
            "6" => { check bookProperty(rentalClient); }
            "7" => { check confirmBooking(rentalClient); }
            "8" => { check createUsers(rentalClient); }
            "9" => { running = false; }
            _ => { io:println("Invalid option."); }
        }
    }
}

function addProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property details, call rentalClient->add_property
    int propertyId = 0; // Replace with actual input
}

function updateProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id + new values, call update_property
}

function removeProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call remove_property
}

function listAvailableProperties(RentalServiceClient rentalClient) returns error? {
    // TODO: call list_available_properties, get back a stream, iterate + print
}

function searchProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call search_property
}

function bookProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id/guest_id/dates, call book_property
}

function confirmBooking(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for booking_id, call confirm_booking
}

function createUsers(RentalServiceClient rentalClient) returns error? {
    // TODO: build a stream of User records, call create_users with it
}
