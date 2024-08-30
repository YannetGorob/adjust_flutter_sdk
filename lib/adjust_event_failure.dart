//
//  adjust_event_failure.dart
//  Adjust SDK
//
//  Created by Srdjan Tubin (@2beens) on 25th April 2018.
//  Copyright (c) 2018-Present Adjust GmbH. All rights reserved.
//

class AdjustEventFailure {
  final String? message;
  final String? timestamp;
  final String? adid;
  final String? eventToken;
  final String? callbackId;
  final String? jsonResponse;
  final bool? willRetry;

  AdjustEventFailure({
    this.message,
    this.timestamp,
    this.adid,
    this.eventToken,
    this.callbackId,
    this.jsonResponse,
    this.willRetry,
  });

  factory AdjustEventFailure.fromMap(dynamic map) {
    try {
      return AdjustEventFailure(
        message: map['message'],
        timestamp: map['timestamp'],
        adid: map['adid'],
        eventToken: map['eventToken'],
        callbackId: map['callbackId'],
        jsonResponse: map['jsonResponse'],
        willRetry: map['willRetry']?.toString().toLowerCase() == 'true',
      );
    } catch (e) {
      throw Exception(
          '[AdjustFlutter]: Failed to create AdjustEventFailure object from given map object. Details: ' +
              e.toString());
    }
  }
}
