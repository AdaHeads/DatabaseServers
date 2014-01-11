part of contactserver.database;

Future<Map> getContact(int orgId, int contactId) {
    String sql = '''
      SELECT orgcon.organization_id, orgcon.contact_id, orgcon.wants_messages, orgcon.attributes, orgcon.enabled, con.full_name, con.contact_type, con.enabled
      FROM contacts con JOIN organization_contacts orgcon on con.id = orgcon.contact_id
      WHERE orgcon.organization_id = @orgid AND orgcon.contact_id = @contactid''';

    Map parameters = {'orgid' : orgId,
                      'contactid': contactId};

    return database.query(_pool, sql, parameters).then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'organization_id' : row.organization_id,
           'contact_id'      : row.contact_id,
           'wants_messages'  : row.wants_messages,
           'enabled'         : row.enabled,
           'full_name'       : row.full_name,
           'contact_type'    : row.contact_type};
        
        JSON.decode(row.attributes).forEach((key, value) => data.putIfAbsent(key, () => value));
      }

      return data;
    });
}
