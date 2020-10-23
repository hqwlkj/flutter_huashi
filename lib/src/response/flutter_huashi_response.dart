

const String _errCode = "errCode";
const String _message = "message";

typedef BaseFlutterHuashiResponse _FlutterHuashiResponseInvoker(Map argument);

Map<String, _FlutterHuashiResponseInvoker> _nameAndResponseMapper = {
  "onCardInfoResponse": (Map argument) => CardInfoResponse.fromMap(argument)
};

class BaseFlutterHuashiResponse {
  final String code;
  final String message;

  BaseFlutterHuashiResponse._(this.code, this.message);

  factory BaseFlutterHuashiResponse.create(String name, Map argument) =>
      _nameAndResponseMapper[name](argument);
}

class CardInfoResponse extends BaseFlutterHuashiResponse {
  final String peopleName;
  final String sex;
  final String people;
  final DateTime birthDay;

  CardInfoResponse.fromMap(Map map)
      :
        peopleName = map['peopleName'],
        sex = map['sex'],
        people = map['people'],
        birthDay = map['birthDay'],
        super._(map[_errCode], map[_message]);
}