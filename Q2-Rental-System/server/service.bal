import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
isolated service "RentalService" on ep {

    private map<Property> properties = {};
    private map<BookingRequest> tempBookings = {};
    private int bookingCounter = 0;

    remote function add_property(Property value) returns PropertyResponse|error {
        return error("not implemented yet");
    }

    remote function update_property(Property value) returns PropertyResponse|error {
        string id = value.property_id;
        lock {
            if !self.properties.hasKey(id) {
                return error(string `No property found with id ${id}`);
            }
            self.properties[id] = value.clone();
            return {property: value.clone(), message: "Property updated successfully"};
        }
    }

    remote function remove_property(PropertyIdRequest value) returns PropertyList|error {
        return error("not implemented yet");
    }

    remote function search_property(PropertyIdRequest value) returns PropertyResponse|error {
        string id = value.property_id;
        lock {
            if self.properties.hasKey(id) {
                return {property: self.properties.get(id).clone(), message: "Property found"};
            }
        }
        return {message: "Not Available"};
    }

    remote function book_property(BookingRequest value) returns BookingCartResponse|error {
        if value.check_in >= value.check_out {
            return error(string `check_out (${value.check_out}) must be after check_in (${value.check_in})`);
        }
        string bookingId;
        lock {
            self.bookingCounter += 1;
            bookingId = "BK-" + self.bookingCounter.toString();
            self.tempBookings[bookingId] = value.clone();
        }
        return {booking_id: bookingId, status: "PENDING"};
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns BookingConfirmation|error {
        return error("not implemented yet");
    }

    remote function create_users(stream<User, grpc:Error?> clientStream) returns UserCreationResponse|error {
        return error("not implemented yet");
    }

    remote function list_available_properties(RentalServicePropertyCaller caller, PropertyFilter value) returns error? {
        return;
    }
}