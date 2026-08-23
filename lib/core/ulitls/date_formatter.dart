
String dateTimeFormate(DateTime? date){
  if(date==null)
  {
    return "";
  }

  String formattedDate =
      "${date.day.toString().padLeft(2, '0')}/"
      "${date.month.toString().padLeft(2, '0')}/"
      "${date.year}";

  return formattedDate;

}
