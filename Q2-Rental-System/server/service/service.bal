import ballerina/grpc;

public type Booking record {| 
    string booking_id;
    string property_id;
    string guest_id;
    string check_in;
    string check_out;
    float total_cost = 0.0;
    string status = "PENDING";
|};

map<Property> properties = {};   // keyed by property_id
map<Booking> bookingCart = {};   // pending bookings, keyed by booking_id
map<Booking> confirmedBookings = {}; // keyed by booking_id
map<User> users = {};            // keyed by user_id

int propertyCounter = 0;
int bookingCounter = 0;

@grpc:Descriptor {value: RENTAL_DESC}
service "RentalService" on new grpc:Listener(9090) {

    // --- The RPCs ---

    remote function add_property(Property value) returns PropertyResponse|error {
        propertyCounter += 1;
        string newId = "P" + propertyCounter.toString();
        Property created = {
            property_id: newId,
            property_name: value.property_name,
            location: value.location,
            property_type: value.property_type,
            price_per_night: value.price_per_night,
            status: value.status
        };
        properties[newId] = created;
        return {property: created, message: "Property added successfully."};

    }

    remote function update_property(Property value) returns PropertyResponse|error {
        if !properties.hasKey(value.property_id) {
            return error("Property not found: "+ value.property_id);
        }
        properties[value.property_id] = value;
        return {property: value, message: "Property updated successfully."};
    }

    remote function remove_property(PropertyIdRequest value) returns PropertyList|error {
       if(!properties.hasKey(value.property_id)) {
            return error("Property not found: "+ value.property_id);
        }
        _ = properties.remove(value.property_id);
        Property[] remaining = [];
        foreach string propertyId in properties.keys() {
            Property? property = properties[propertyId];
            if property is Property {
                remaining.push(property);
            }
        }
        return {properties: remaining};
    }

    remote function search_property(PropertyIdRequest value) returns PropertyResponse|error {
        Property? found = properties.get(value.property_id);
        if found is Property {
            return {property: found, message: "Property found."};
        } else {
            return error("Property not found: "+ value.property_id);
        }

    }

    remote function book_property(BookingRequest value) returns BookingCartResponse|error {
        if (value.check_out <= value.check_in){
            return error("Check out must be after check in date");
        }
        if (!properties.hasKey(value.property_id)) {
            return error("Property not found: "+ value.property_id);
        }
        bookingCounter += 1;
        string bookingId = "B" + bookingCounter.toString();

        bookingCart[bookingId] = {
            booking_id: bookingId,
            property_id: value.property_id,
            guest_id: value.guest_id,
            check_in: value.check_in,
            check_out: value.check_out,
            total_cost: 0.0,
            status: "PENDING"
        };
        return {booking_id: bookingId, status: "PENDING"};
    }

    remote function confirm_booking(ConfirmBookingRequest value) returns BookingConfirmation|error {
        // TODO:
        // 1. verify no date overlap with confirmedBookings for this property
        // 2. calculate total_cost = price_per_night * nights
        // 3. move from bookingCart to confirmedBookings, return confirmation
    }

    // --- Client streaming ---

    remote function create_users(stream<User, grpc:Error?> clientStream) returns UserCreationResponse|error {
        // TODO: iterate clientStream, store each User in `users`, count them,
        // return one UserCreationResponse once the stream ends
    }

    // --- Server streaming ---

    remote function list_available_properties(RentalServiceListAvailablePropertiesCaller caller, PropertyFilter value) returns error? {
        // TODO: foreach property in `properties` matching the filter,
        // check caller->sendProperty(p); then check caller->complete();
    }
}
