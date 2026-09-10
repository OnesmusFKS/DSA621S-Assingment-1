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

function datesOverlap(
    string firstCheckIn,string firstCheckOut,
    string secondCheckIn,
    string secondCheckOut
) returns boolean {
    return firstCheckIn < secondCheckOut && secondCheckIn < firstCheckOut;
}

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
        Booking? pending = bookingCart[value.booking_id];
        if pending is () {
            return error("Booking not found: "+ value.booking_id);
        }


        // Reect if property is already confirmed
        foreach Booking existing in confirmedBookings {
            if existing.property_id == pending.property_id && datesOverlap(pending.check_in, pending.check_out, existing.check_in, existing.check_out) {
                return {
                    booking_id: value.booking_id,
                    total_cost: 0.0,
                    status: "REJECTED",
                    message: "Booking rejected due to date overlap with existing confirmed booking."
                };
            }
        }

        Property? property = properties[pending.property_id];
        if property is(){
            return error("Property "+ pending.property_id + " no longer exists");
        }

        int nights = check calculateNights(pending.check_in, pending.check_out);
        decimal totalCost = <decimal>nights * <decimal>property.price_per_night;

        Booking confirmed = pending;
        confirmed.total_cost = totalCost;
        confirmed.status = "CONFIRMED";
        confirmedBookings[value.booking_id] = confirmed;
        _ = bookingCart.remove(value.booking_id);

        return {booking_id: value.booking_id, total_cost: totalCost, status: "CONFIRMED", message: "Booking confirmed successfully."};


    }

    // --- Client streaming ---

    remote function create_users(stream<User, grpc:Error?> clientStream) returns UserCreationResponse|error {
        int count = 0;
        check from User u in clientStream
        do{
            users[u.user_id] = u;
            count += 1;
        }
        return {count: count, message: "Registered "+count.toString()+" users successfully."};
    }

    // --- Server streaming ---

    remote function list_available_properties(RentalServiceListAvailablePropertiesCaller caller, PropertyFilter value) returns error? {
        foreach Property p in properties {
            boolean matchesLocation = value.location == "" || p.location == value.location;
            boolean matchesPrice = value.max_price == 0.0 || p.price_per_night <= value.max_price;
            if (matchesLocation && matchesPrice && p.status == "AVAILABLE") {
                check caller->sendProperty(p);
            }
        }

        check caller->complete();
    }
}
