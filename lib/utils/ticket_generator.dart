String generateFormattedCounter(DateTime date, int counter) {
  String year = date.year.toString();
  String month = date.month.toString().padLeft(2, '0');
  String day = date.day.toString().padLeft(2, '0');

  // Format the counter with leading zeros
  String formattedCounter = counter.toString().padLeft(2, '0');

  // Concatenate all components to form the final string
  return '$year$month$day$formattedCounter';
}

String generateUniqueCounter(DateTime date, int counter) {
  if (date.year != DateTime.now().year ||
      date.month != DateTime.now().month ||
      date.day != DateTime.now().day) {
    counter = 1;
  } else {
    counter++;
    counter = counter > 10000 ? 1 : counter;
  }

  // Generate and return the formatted counter string
  return generateFormattedCounter(date, counter);
}
