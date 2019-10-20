import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:gdgdevfest_emails/gdgdevfest_emails.dart';
import 'package:args/args.dart';
main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption("csv");
  parser.addOption("dir");
  parser.addOption("temp");
  final args = parser.parse(arguments);
  if(args["temp"]!=null&&args["csv"]!=null){
  final emailtemp = await File(args["temp"]).readAsString();
  final csvFile = File(args["csv"]).openRead();
  await Directory("${args["dir"]==null?"":args["dir"]+"/" }mails").create();
  final fields = await csvFile
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();
  fields[0].addAll(["access code", "qr code"]);
  for (int i = 1; i < fields.length; i++) {
    final emailUsername = fields[i][0].toString().replaceRange(
        fields[i][0].toString().indexOf("@"),
        fields[i][0].toString().length - 1,
        "");
    final accessCode = emailUsername + Random().nextInt(1000).toString();
    fields[i].add(accessCode);
    final value = await getDirectImageUrl(await uploadQrCodeImage(
        await generateQrCodeImage(accessCode), accessCode));
    fields[i].add(value);
    await File("${args["dir"]==null?"":args["dir"]+"/" }mails/${emailUsername}.txt").writeAsString(composeMail(emailtemp,fields[i][1],accessCode,value));
  }
  final conv = ListToCsvConverter();
  String csvStr = conv.convert(fields);
  File("${args["dir"]==null?"":args["dir"]+"/" }test_segment_with_codes.txt").writeAsStringSync(csvStr);
  }
}
