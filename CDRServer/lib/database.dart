library cdrserver.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';

import 'configuration.dart';
import 'model.dart';
import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/database.dart' as database;


part 'db/cdr.dart';
part 'db/newcdr.dart';

Pool _pool;

final String packageName = "cdrserver.database";

class NotFound extends StateError {
  NotFound(String message) : super(message);
}

class CreateFailed extends StateError {
  CreateFailed (String message) : super(message);
}


Future startDatabase() =>
    database.start(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname)
            .then((pool) { _pool = pool;});
