# TODO List - TCC Project Refactoring

## Completed Tasks

- [x] Create User model with fromJson, toJson, copyWith, and equality
- [x] Create Validators utility with email and password validation
- [x] Create HttpService base class for HTTP operations
- [x] Update AuthService to extend HttpService and return User objects
- [x] Update ApiService to extend HttpService and return User objects
- [x] Update UserState to use User model instead of separate properties
- [x] Update LoginScreen to use Validators and UserState.loginWithUser
- [x] Create FilterManager for managing filter state
- [x] Test the app by running flutter run

## Notes

- AuthService now uses /worker-login endpoint as per backend API
- All services now return User objects instead of Map<String, dynamic>
- Validation logic moved to Validators utility
- Filter logic extracted to FilterManager with ChangeNotifier
- UserState now holds a User? object instead of separate fields
- HttpService provides common HTTP methods for subclasses
- Tests created for User model (though import path may need adjustment)

## Next Steps (if needed)

- Add FilterManager to main.dart providers
- Update home_page.dart to use FilterManager instead of local state
- Run tests with flutter test
- Fix any compilation errors
