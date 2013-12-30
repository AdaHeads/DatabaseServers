part of http;

void getOrgList(HttpRequest request) {
  int orgId = int.parse(request.uri.pathSegments.elementAt(3));
  
  db.getOrganizationContactList(orgId).then((Map value) {
    writeAndClose(request, JSON.encode(value));
  }).catchError((error) => serverError(request, error.toString()));
}