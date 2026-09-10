
import ballerina/time;

// the single ConfirmBookingRequest message.

public type Booking record {
    string bookingId;
    string propertyId;
    string guestId;
    string checkIn;
    string checkOut;
    decimal totalCost = 0;
    string status; // PENDING, CONFIRMED, REJECTED
};

public function datesOverlap(string aIn, string aOut, string bIn, string bOut) returns boolean {
    if (aIn < bOut && bIn < aOut) {
        return true;
    } else {
        return false;
    }
}

public function calculateNights(string checkIn, string checkOut) returns int {
    time:Utc checkInTime = check time:utcFromString(checkIn + "T00:00:00Z");
    time:Utc checkOutTime = check time:utcFromString(checkOut + "T00:00:00Z");
    decimal diffSeconds = time:diff(checkOutTime, checkInTime);
    return <int> (diffSeconds / (60 * 60 * 24));
}