library organizationserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'package:Utilities/common.dart';
import 'package:Utilities/database.dart' as database;

part 'db/getorganization.dart';
part 'db/getcalendar.dart';
part 'db/createorganization.dart';
part 'db/deleteorganization.dart';
part 'db/updateorganization.dart';
part 'db/getorganizationlist.dart';

Pool _pool;

Future startDatabase() => 
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});