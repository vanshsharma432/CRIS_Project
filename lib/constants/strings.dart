class AStrings {
  // App titles and section headings
  static const dashboardTitle = 'IREQMS';
  static const trainRequestList = 'Train Requests List';

  // Table headers (used in both desktop header and allColumns)
  static const status = 'Status';
  static const passengers = 'Passengers';
  static const trainInfo = 'Train No. (Boarding at)';
  static const pnrJourney = 'PNR (Journey Date)';
  static const startDate = 'Start Date';
  static const requestedBy = 'Requested by (Requested on)';
  static const divisionZone = 'Division (Zone)';
  static const select = 'Select';
  static const options = 'options';


  // Data labels for filtering/column selection
  static const totalPassengers = 'Total Passengers';
  static const requestedPassengers = 'Requested Passengers';
  static const acceptedPassengers = 'Accepted Passengers';
  static const currentStatus = 'Current Status';
  static const remarksByRailways = 'Remarks By Railways';
  static const requestedOn = 'Requested On';
  static const trainStartDate = 'Train Start Date';
  static const trainJourneyDate = 'Train Journey Date';
  static const sourceStation = 'Source Station';
  static const destination = 'Destination';
  static const requestedByName = 'Requested By';
  static const zone = 'Zone';
  static const division = 'Division';
  static const lastUpdated = 'Last Updated';
  static const pnrDate = 'PNR Date';
  static const trainNo = 'Train No';
  static const filterBy = 'Filter by';
  static const searchValue = 'Enter value to search';
  static const resetFilter = 'Reset Filter';
  static const filterTitle = 'Filter Options';
  static const selectFilterField = 'Filter By:';
  static const selectFieldHint = 'Select Field';
  static const enterSearchValue = 'Enter value to filter';
  static const minValue = 'Min';
  static const maxValue = 'Max';
  static const pickDate = 'Pick a Date';
  static const seatClass = 'Class';

  // Dynamic text fragments
  static const remarksPrefix = 'Remarks: ';
  static const noRemarks = 'No remarks provided';
  static const lastUpdatedLabel = 'Last Updated: ';
  static const reqByShort = 'Req by - ';
  static const divZoneShort = 'Div(Zone)-';
  static const total = 'Total';
  static const requested = 'Requested';
  static const accepted = 'Accepted';
  static const pnrLabel = 'PNR';

  //sort
  static const String sortBy = 'Sort By';
  static const String selectSortFieldHint = 'Select sort field';
  static const String ascending = 'Ascending';
  static const String descending = 'Descending';
  static const String defaultSort = "Default";

  //prescreen
  static const journeyDate = 'Journey Date';
  static const userType = 'User Type';
  static const or = 'OR';
  static const submit = 'Submit';
  static const editOptions = 'Edit Options';
  static const selectPrompt = 'Tap to select';
  static const fillFieldsError = 'Please select one date and one filter option.';




  // All column titles used in filters and select columns widget
  static const List<String> allColumns = [
    totalPassengers,
    requestedPassengers,
    acceptedPassengers,
    currentStatus,
    remarksByRailways,
    requestedOn,
    trainStartDate,
    trainJourneyDate,
    sourceStation,
    destination,
    requestedByName,
    zone,
    division,
    lastUpdated,
    pnrDate,
    requestedBy,
    trainNo,
    select,
  ];
}
