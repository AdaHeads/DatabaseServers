part of callflowcontrol.router;

Map orignateOK (channelUUID) =>
    {'status'      : 'ok',
     'call'        : {'id' : channelUUID},
     'description' : 'Connecting...'};

void handlerCallOrignate(HttpRequest request) {

  const String context = '${libraryName}.handlerCallOrignate';

  final int    receptionID = pathParameter(request.uri, 'reception');
  final int    contactID   = pathParameter(request.uri, 'contact');
  final String extension   = pathParameterString(request.uri, 'originate');
  final String token       = request.uri.queryParameters['token'];

  logger.debugContext ('Originating to ${extension} in context ${contactID}@${receptionID}', context);

  /// Any authenticated user is allowed to originate new calls.
  bool aclCheck (User user) => true;

  bool validExtension (String extension) => extension != null && extension.length > 1;

  Service.Authentication.userOf(token: token, host: config.authUrl).then((User user) {

    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    if (!validExtension(extension)) {
      clientError(request, 'Invalid extension: $extension');
      return;
    }

    /// Park all the users calls.
    Future.forEach(Model.CallList.instance.callsOf(user).where
      ((Model.Call call) => call.state == Model.CallState.Speaking), (Model.Call call) => call.park(user)).whenComplete(() {
      Controller.PBX.originate (extension, contactID, receptionID, user)
        .then ((String channelUUID) {
          //Model.OriginationRequest.create (channelUUID);
          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

        }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

    }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
