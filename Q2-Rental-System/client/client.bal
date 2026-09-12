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
    io:println("Enter property details:");

    string propertyName = io:readln("Enter property name: ");
    float pricePerNight = check float:fromString(io:readln("Enter property price: "));
    string propertyLocation = io:readln("Enter property location: ");
    string propertyType = io:readln("Enter property type: ");

    Property property = {
        property_name: propertyName,
        location: propertyLocation,
        property_type: propertyType,
        price_per_night: pricePerNight
    };

    PropertyResponse response = check rentalClient->add_property(property);
    io:println("Property added successfully: " + response.message);
}

function updateProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id + new values, call update_property
    string propertyId = io:readln("Enter property ID to update: ");

    string propertyName = io:readln("Enter new property name: ");
    float pricePerNight = check float:fromString(io:readln("Enter new property price: "));
    string propertyLocation = io:readln("Enter new property location: ");
    string propertyType = io:readln("Enter new property type: ");

    Property property = {
        property_id: propertyId,
        property_name: propertyName,
        location: propertyLocation,
        property_type: propertyType,
        price_per_night: pricePerNight
    };

    PropertyResponse response = check rentalClient->update_property(property);
    io:println("Property updated successfully: " + response.message);
}

function removeProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call remove_property
        string propertyId = io:readln("Enter property ID to remove: ");
        _ = check rentalClient->remove_property({
                property_id: propertyId
        });
    io:println("Property removed successfully.");  
}

function listAvailableProperties(RentalServiceClient rentalClient) returns error? {
    // TODO: call list_available_properties, get back a stream, iterate + print
    PropertyFilter filter = {
        location: io:readln("Enter location filter (or press Enter for any): "),
        max_price: check float:fromString(io:readln("Enter maximum price: "))
    };
    _ = check rentalClient->list_available_properties(filter);
    do {
        io:println("property"); 
    }
}

function searchProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call search_property
    string propertyId = io:readln("Enter property ID to search: ");
    PropertyResponse response = check rentalClient->search_property({
        property_id: propertyId
    });
    io:println("Found property: " + response.property.property_name);

}

function bookProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id/guest_id/dates, call book_property
    string propertyID = io:readln("Enter property ID to book: ");
    string guestID = io:readln("Enter guest ID");
    string checkIn = io:readln("Enter check-in  date (YYYY-MM-DD): ");
    string checkOut = io:readln("Enter check-out date (YYYY-MM-DD): ");
    

        BookingRequest request =
        {
            property_id: propertyID,
            guest_id: guestID,
            check_in: checkIn,  
            check_out: checkOut
        };

    BookingCartResponse bookingResponse = check rentalClient->book_property(request);
    io:println("Property booked successfully. Booking ID: " + bookingResponse.booking_id);
}

function confirmBooking(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for booking_id, call confirm_booking
    string bookingID = io:readln("Enter booking ID to confirm: ");

    
    ConfirmBookingRequest request =
        {
        booking_id: bookingID
    };

    BookingConfirmation confirmationResponse = check rentalClient->confirm_booking(request);

    io:println("Booking ID: " + confirmationResponse.booking_id);
    io:println("Total cost: " + confirmationResponse.total_cost.toString());
    io:println("Status: " + confirmationResponse.status);
}


function createUsers(RentalServiceClient rentalClient) returns error? {
    // TODO: build a stream of User records, call create_users with it
 string userID = io:readln("Enter user ID: ");
 string userName = io:readln("Enter user name: ");
 string userRole = io:readln("Enter user role: ");

 User user = {
        user_id: userID,
        name: userName,
        role: userRole
    };

    Create_usersStreamingClient usersClient = check rentalClient->create_users();

    check usersClient->sendUser(user);

    check usersClient->complete();

    UserCreationResponse|() response = check usersClient->receiveUserCreationResponse();
    if response is UserCreationResponse {
        io:println("User creation response: " + response.message);
    } else {
        io:println("No user creation response received.");
    }
} 

