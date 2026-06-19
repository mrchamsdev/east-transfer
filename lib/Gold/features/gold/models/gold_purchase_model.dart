
class GoldParty {
  final int id;
  final String partyName;
  final String partyPhoneNumber;
  final String dlNumber;
  final String licenseNumber;
  final String? note;

  GoldParty({
    required this.id,
    required this.partyName,
    required this.partyPhoneNumber,
    required this.dlNumber,
    required this.licenseNumber,
    this.note,
  });

  factory GoldParty.fromJson(Map<String, dynamic> json) => GoldParty(
        id: json["id"],
        partyName: json["partyName"] ?? "",
        partyPhoneNumber: json["partyPhoneNumber"] ?? "",
        dlNumber: json["dlNumber"] ?? "",
        licenseNumber: json["licenseNumber"] ?? "",
        note: json["note"],
      );
}

class GoldBilledItem {
  final int? id;
  final int? purchaseId;
  final double grossWeight;
  final double side1;
  final double side2;
  final double averagePercentage;
  final double pureWeight;

  GoldBilledItem({
    this.id,
    this.purchaseId,
    required this.grossWeight,
    required this.side1,
    required this.side2,
    required this.averagePercentage,
    required this.pureWeight,
  });

  Map<String, dynamic> toJson() => {
        "grossWeight": grossWeight,
        "side1": side1,
        "side2": side2,
        "averagePercentage": averagePercentage,
        "pureWeight": pureWeight,
      };

  factory GoldBilledItem.fromJson(Map<String, dynamic> json) => GoldBilledItem(
        id: json["id"],
        purchaseId: json["purchaseId"],
        grossWeight: _toDouble(json["grossWeight"]),
        side1: _toDouble(json["side1"]),
        side2: _toDouble(json["side2"]),
        averagePercentage: _toDouble(json["averagePercentage"]),
        pureWeight: _toDouble(json["pureWeight"]),
      );

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class GoldPurchase {
  final int? id;
  final String purchaseDate;
  final String partyName;
  final String partyPhoneNumber;
  final String dlNumber;
  final String licenseNumber;
  final String? status;
  final double? totalGrossWeight;
  final double? totalPureWeight;
  final String? royaltyCifHiv;
  final String? tra;
  final String? svl;
  final double? amount;
  final double? totalAmount;
  final double? tax;
  final double? grandTotal;
  final String? note;
  final List<GoldBilledItem>? items;
  final GoldParty? party;
  final GoldParty? saleParty;
  final String? saleDate;
  final double? saleAmount;
  final bool? soldOut;
  final int? partyId;
  final int? salePartyId;
  final String? profitLossStatus;
  final double? profitLossAmount;
  final double? profitAmount;
  final double? lossAmount;

  GoldPurchase({
    this.id,
    required this.purchaseDate,
    required this.partyName,
    required this.partyPhoneNumber,
    required this.dlNumber,
    required this.licenseNumber,
    this.status,
    this.totalGrossWeight,
    this.totalPureWeight,
    this.royaltyCifHiv,
    this.tra,
    this.svl,
    this.amount,
    this.totalAmount,
    this.tax,
    this.grandTotal,
    this.note,
    this.items,
    this.party,
    this.saleParty,
    this.saleDate,
    this.saleAmount,
    this.soldOut,
    this.partyId,
    this.salePartyId,
    this.profitLossStatus,
    this.profitLossAmount,
    this.profitAmount,
    this.lossAmount,
  });

  Map<String, dynamic> toJson() => {
        "purchaseDate": purchaseDate,
        "partyName": partyName,
        "partyPhoneNumber": partyPhoneNumber,
        "dlNumber": dlNumber,
        "licenseNumber": licenseNumber,
        "status": status ?? "PURCHASE",
        "totalGrossWeight": totalGrossWeight,
        "totalPureWeight": totalPureWeight,
        "royaltyCifHiv": royaltyCifHiv,
        "tra": tra,
        "svl": svl,
        "amount": amount,
        "totalAmount": totalAmount,
        "tax": tax,
        "grandTotal": grandTotal,
        "note": note,
        "saleDate": saleDate,
        "saleAmount": saleAmount,
        "soldOut": soldOut,
        "partyId": partyId,
        "salePartyId": salePartyId,
        "profitLossStatus": profitLossStatus,
        "profitLossAmount": profitLossAmount,
        "profitAmount": profitAmount,
        "lossAmount": lossAmount,
      };

  factory GoldPurchase.fromJson(Map<String, dynamic> json) {
    final partyData = json["party"] != null ? GoldParty.fromJson(json["party"]) : null;
    
    return GoldPurchase(
      id: json["id"],
      purchaseDate: json["purchaseDate"] ?? "",
      partyName: partyData?.partyName ?? json["partyName"] ?? "",
      partyPhoneNumber: partyData?.partyPhoneNumber ?? json["partyPhoneNumber"] ?? "",
      dlNumber: partyData?.dlNumber ?? json["dlNumber"] ?? "",
      licenseNumber: partyData?.licenseNumber ?? json["licenseNumber"] ?? "",
      status: json["status"],
      totalGrossWeight: _toDouble(json["totalGrossWeight"]),
      totalPureWeight: _toDouble(json["totalPureWeight"]),
      royaltyCifHiv: json["royaltyCifHiv"],
      tra: json["tra"],
      svl: json["svl"],
      amount: _toDouble(json["amount"]),
      totalAmount: _toDouble(json["totalAmount"]),
      tax: _toDouble(json["tax"]),
      grandTotal: _toDouble(json["grandTotal"]),
      note: json["note"],
      saleDate: json["saleDate"],
      saleAmount: _toDouble(json["saleAmount"]),
      party: partyData,
      saleParty: json["saleParty"] != null ? GoldParty.fromJson(json["saleParty"]) : null,
      items: json["items"] == null
          ? null
          : (json["items"] as List)
              .map((x) => GoldBilledItem.fromJson(x))
              .toList(),
      soldOut: json["soldOut"],
      partyId: json["partyId"],
      salePartyId: json["salePartyId"],
      profitLossStatus: json["profitLossStatus"],
      profitLossAmount: _toDouble(json["profitLossAmount"]),
      profitAmount: _toDouble(json["profitAmount"]),
      lossAmount: _toDouble(json["lossAmount"]),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class GoldMonthGroup {
  final String month;
  final List<GoldPurchase> records;

  GoldMonthGroup({required this.month, required this.records});

  factory GoldMonthGroup.fromJson(Map<String, dynamic> json) => GoldMonthGroup(
        month: json["month"] ?? "",
        records: (json["records"] as List)
            .map((x) => GoldPurchase.fromJson(x))
            .toList(),
      );
}
