mixin BaseModel {
  Map toMap();
}

class CardInfoModel implements BaseModel {
  String addr;
  String birthDay;
  String bmpdata;
  String certType;
  String department;
  String endDate;
  String fpDate;
  String iDCard;
  String issuesNum;
  String passCheckID;
  String people;
  String peopleName;
  String sex;
  String strCertVer;
  String strChineseName;
  String strNationCode;
  String strartDate;
  String uID;
  String wltdata;

  CardInfoModel({this.addr,
    this.birthDay,
    this.bmpdata,
    this.certType,
    this.department,
    this.endDate,
    this.fpDate,
    this.iDCard,
    this.issuesNum,
    this.passCheckID,
    this.people,
    this.peopleName,
    this.sex,
    this.strCertVer,
    this.strChineseName,
    this.strNationCode,
    this.strartDate,
    this.uID,
    this.wltdata});

    CardInfoModel.fromJson(Map<String, dynamic> json) {
      addr = json['addr'] as String;
      birthDay = json['birthDay'] as String;
      certType = json['certType'] as String;
      department = json['department'] as String;
      endDate = json['endDate'] as String;
      fpDate = json['fpDate'] as String;
      iDCard = json['iDCard'] as String;
      issuesNum = json['issuesNum'] as String;
      passCheckID = json['passCheckID'] as String;
      people = json['people'] as String;
      peopleName = json['peopleName'] as String;
      sex = json['sex'] as String;
      strCertVer = json['strCertVer'] as String;
      strChineseName = json['strChineseName'] as String;
      strNationCode = json['strNationCode'] as String;
      strartDate = json['strartDate'] as String;
      uID = json['uID'] as String;
      wltdata = json['wltdata'] as String;
    }

  @override
  Map toMap() {
    return {
      "addr": addr,
      "birthDay": birthDay,
      "bmpdata": bmpdata,
      "certType": certType,
      "department": department,
      "endDate": endDate,
      "fpDate": fpDate,
      "iDCard": iDCard,
      "issuesNum": issuesNum,
      "passCheckID": passCheckID,
      "people": people,
      "peopleName": peopleName,
      "sex": sex,
      "strCertVer": strCertVer,
      "strChineseName": strChineseName,
      "strNationCode": strNationCode,
      "strartDate": strartDate,
      "uID": uID,
      "wltdata": wltdata,
    };
  }
}
