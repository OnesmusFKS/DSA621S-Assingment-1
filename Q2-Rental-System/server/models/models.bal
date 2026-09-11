

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

function calculateNights(string checkIn, string checkOut) returns int|error {
    int startDay = check dateToDays(checkIn);
    int endDay = check dateToDays(checkOut);
    int nights = endDay - startDay;

    if nights <= 0 {
        return error("Check-out must be after check-in");
    }

    return nights;
}

function dateToDays(string date) returns int|error {
    if date.length() != 10 ||
        date.substring(4, 5) != "-" ||
        date.substring(7, 8) != "-" {
        return error("Date must use YYYY-MM-DD format");
    }

    int year = check int:fromString(date.substring(0, 4));
    int month = check int:fromString(date.substring(5, 7));
    int day = check int:fromString(date.substring(8, 10));

    if month < 1 || month > 12 || day < 1 || day > 31 {
        return error("Invalid date");
    }

    int[] monthDays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    int total = year * 365 + monthDays[month - 1] + day;

    if month > 2 && year % 2 == 0 {
        total += 1;
    }

    return total;
}