library callflowcontrol.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/httpserver.dart';

import 'controller/controller.dart' as Controller;
import 'model/model.dart' as Model;
import 'package:openreception_framework/model.dart' as SharedModel;
import 'package:openreception_framework/service.dart' as Service;
import 'package:openreception_framework/model.dart';

part 'router/handler-call-hangup.dart';
part 'router/handler-call-list.dart';
part 'router/handler-call-originate.dart';
part 'router/handler-call-park.dart';
part 'router/handler-call-pickup.dart';
part 'router/handler-call-queue.dart';
part 'router/handler-call-recordsound.dart';
part 'router/handler-call-transfer.dart';
part 'router/handler-channel-list.dart';
part 'router/handler-peer-list.dart';

const String libraryName = "notificationserver.router";

Map<int,List<WebSocket>> clientRegistry = new Map<int,List<WebSocket>>();

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern peerListResource        = new UrlPattern(r'/peer/list');
final Pattern callListResource        = new UrlPattern(r'/call/list');
final Pattern callQueueResource       = new UrlPattern(r'/call/queue');
final Pattern callHangupResource      = new UrlPattern(r'/call/([a-z\-0-9]+)/hangup');
final Pattern callPickupResource      = new UrlPattern(r'/call/([a-z\-0-9]+)/pickup');
final Pattern callParkResource        = new UrlPattern(r'/call/([a-z\-0-9]+)/park');
final Pattern callTransferResource    = new UrlPattern(r'/call/([a-z\-0-9]+)/transfer/([a-z\-0-9]+)');
final Pattern callOriginateResource   = new UrlPattern(r'/call/originate/([a-z\-0-9]+)/reception/(\d+)/contact/(\d+)');
final Pattern callPickupNextResource  = new UrlPattern(r'/call/pickup');
final Pattern callRecordSoundResource = new UrlPattern(r'/call/reception/(\d+)/record');
final Pattern channelListResource     = new UrlPattern(r'/channel/list');

final List<Pattern> allUniqueUrls = [peerListResource,
                                     callListResource, callQueueResource, callHangupResource,
                                     callParkResource, callOriginateResource,
                                     callPickupNextResource, callTransferResource,
                                     callRecordSoundResource];

void registerHandlers(HttpServer server) {
    logger.debugContext("CallFlowControl REST interface is listening on "
             "'http://${server.address.address}:${config.httpport}/'", "registerHandlers");
    var router = new Router(server);

    router
      ..filter(matchAny(allUniqueUrls), auth(config.authUrl))
      ..serve(  peerListResource,     method : "GET"  ).listen(handlerPeerList)
      ..serve(  callListResource,     method : "GET"  ).listen(handlerCallList)
      ..serve(channelListResource,    method : "GET"  ).listen(handlerChannelList)
      ..serve(  callQueueResource,    method : "GET"  ).listen(handlerCallQueue)
      ..serve(callHangupResource,     method : "POST" ).listen(handlerCallHangup)
      ..serve(callPickupResource,     method : "POST" ).listen(handlerCallPickup)
      ..serve(callPickupNextResource, method : "POST" ).listen(handlerCallPickupNext)
      ..serve(callParkResource,       method : "POST" ).listen(handlerCallPark)
      ..serve(callOriginateResource,  method : "POST" ).listen(handlerCallOrignate)
      ..serve(callTransferResource,   method : "POST" ).listen(handlerCallTransfer)
      ..serve(callRecordSoundResource, method : "POST" ).listen(handlerCallRecordSound)
      ..serve(anything, method: 'OPTIONS').listen(preFlight)
      ..defaultStream.listen(page404);
}

