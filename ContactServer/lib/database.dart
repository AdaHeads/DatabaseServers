library contactserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as database;
import 'configuration.dart';

part 'db/getreceptioncontact.dart';
part 'db/getreceptioncontactlist.dart';
part 'db/getcontactsphones.dart';
part 'db/getphone.dart';
part 'db/getcalendar.dart';
part 'db/contact-calendar.dart';

Pool _pool;

Future startDatabase() =>
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) {_pool = pool;});
