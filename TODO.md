# TODO: Fix Issues in Booking and History Screens

## 1. Update Booking Model
- Change `scheduleId` from `int` to `String` to match `Schedule.id`.

## 2. Fix Booking Screen (booking_screen.dart)
- Update booking creation to use correct types (id: null, scheduleId: String, passengers: List<Passenger>).
- Create Passenger objects from form data.
- Handle round trip by creating separate booking for return trip.
- Use `createBooking` from DataProvider instead of commented `addBooking`.
- Get `userId` from AuthProvider.
- Implement date filtering in `_getAvailableSchedules`.
- Use actual `schedule.departureTime` in dropdown instead of hardcoded "08:00".
- Ensure navigation to history works (check routes).

## 3. Fix History Screen (history_screen.dart)
- Fix `booking.id` usage: Convert int? to String.
- Use `booking.createdAt` instead of non-existent `booking.date`.
- Handle nullable `passengers`: Check if not null before accessing length.
- Fetch schedule details for route info instead of hardcoded "SBY" to "MLG".
- Add method in DataProvider to get schedule by id.

## 4. Update DataProvider
- Add `getScheduleById(String id)` method.

## 5. Check Routes
- Ensure '/history' route is defined in main.dart.

## 6. Test Fixes
- Run the app and test booking and history screens.
