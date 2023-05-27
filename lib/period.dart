// Периоды доступные для установки, можно установить любое количество дней
enum Period {
  everyDay('Every day', 1),
  inOneDay('In one day', 2),
  inTwoDays('In two days', 3);

  const Period(this.name, this.inDays);

  final String name;
  final int inDays;
}
