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
    io:println("Enter property details:");

    string propertyName = io:readln("Enter property name: ");
    string propertyAddress = io:readln("Enter property address: ");
    float pricePerNight = check float:fromString(io:readln("Enter property price: "));
    string proprtyLocation = io:readln("Enter property location: ");
    string propertyType = io:readln("Enter property type: ");

   

    Property property =
        {
            name: propertyName,
            address: propertyAddress,
            price: pricePerNight,
            property_type: propertyType,
            location: proprtyLocation
        };

        PropertyResponse response = check rentalClient->add_property(property);
    io:println("Property added successfully. Assigned ID: " + response.id);
}

function updateProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id + new values, call update_property
    string propertyId = io:readln("Enter property ID to update: ");

    string propertyName = io:readln("Enter new property name: ");
    string propertyAddress = io:readln("Enter new property address: ");
    float pricePerNight = check float:fromString(io:readln("Enter new property price: "));
    string proprtyLocation = io:readln("Enter new property location: ");
    string propertyType = io:readln("Enter new property type: ");

    Property property =
       
        {
             propertyId: propertyId,
            name: propertyName,
            address: propertyAddress,
            price: pricePerNight,
            property_type: propertyType,
            location: proprtyLocation
        };

        PropertyResponse response = check rentalClient->update_property(property);
    io:println("Property updated successfully.");
}

function removeProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call remove_property
  string propertyId = io:readln("Enter property ID to remove: ");
    check rentalClient->remove_property(propertyId);
    io:println("Property removed successfully.");  
}

function listAvailableProperties(RentalServiceClient rentalClient) returns error? {
    // TODO: call list_available_properties, get back a stream, iterate + print
    stream<Property,grpc:Error?> properties = rentalClient->list_available_properties();
    do {
        io:println("property"); 
    }
}

function searchProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id, call search_property
    string propertyId = io:readln("Enter property ID to search: ");
    var property = check rentalClient->search_property(propertyId);
    io:println("Found property: " + property.name);

}

function bookProperty(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for property_id/guest_id/dates, call book_property
    string propertyID = io:readln("Enter property ID to book: ");
    string guestID = io:readln("Enter guest ID");
    string checkIn = io:readln("Enter check-in  date (YYYY-MM-DD): ");
    string checkOut = io:readln("Enter check-out date (YYYY-MM-DD): ");
    

  BookingResponse response = 
        {
            property_id: propertyID,
            guest_id: guestID,
            check_in: checkIn,  
            check_out: checkOut
        };

        BookingResponse bookingResponse = check rentalClient->book_property(response);
    io:println("Property booked successfully.");
}

function confirmBooking(RentalServiceClient rentalClient) returns error? {
    // TODO: prompt for booking_id, call confirm_booking
    string bookingID = io:readln("Enter booking ID to confirm: ");

    
    BookingConfirmation response = 
        {
        booking_id: bookingId
    };

    BookingConfirmation confirmationResponse = check rentalClient->confirm_booking(response);

    io:println("Booking ID: " + confirmationResponse.booking_id);
    io:println("Total cost: " + confirmationResponse.total_cost.toString());
    io:println("Status: " + confirmationResponse.status);
    io:println("Message: " + confirmationResponse.message);
}


function createUsers(RentalServiceClient rentalClient) returns error? {
    // TODO: build a stream of User records, call create_users with it
 string userID = io:readln("Enter user ID: ");
 string userName = io:readln("Enter user name: ");
 string userRole = io:readln("Enter user role: ");

 User user = {
        id: userID,
        name: userName,
        role: userRole
    };

    Create_usersStreamingClient usersClient = check rentalClient->create_users();

    check usersClient->sendUser(user);

    check usersClient->complete();

    UserCreationResponse response = check usersClient->recieveUserCreationResponse();

    io:println("User creation response: " + response.message);
} 

