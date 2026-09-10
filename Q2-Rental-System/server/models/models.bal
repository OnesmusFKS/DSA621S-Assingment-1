// Internal server-side state, separate from the wire messages in rental.proto.
// A confirmed Booking needs fields (like total_cost, dates) that outlive
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
