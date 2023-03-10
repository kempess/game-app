import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'package:game/app/core/error/exception/exception.dart';
import 'package:game/data/constants/constants.dart';
import 'package:game/data/models/game/game_model.dart';
import 'package:game/data/services/dio/dio.dart';
import 'package:game/data/services/sqlite/sqlite.dart';

import 'games_list_repository.dart';

class GamesListRepositoryImpl implements GamesListRepository {
  final DioService _dioService;
  final SqliteGamesService _sqliteGamesService;

  GamesListRepositoryImpl({
    required DioService dioService,
    required SqliteGamesService sqliteGamesService,
  })  : _dioService = dioService,
        _sqliteGamesService = sqliteGamesService;

  @override
  Future<List<GameModel>> getGamesList({
    required int limit,
    required int offset,
    required int idPlatform,
  }) async {
    var dio = _dioService.getDio();
    const baseGamesUrl = ConstantsAPI.game;
    try {
      final response = await dio.post(baseGamesUrl,
          data: '''
          fields id, name, platforms, summary, screenshots.url, genres.name, platforms.name;
          where platforms = $idPlatform;
          limit $limit;
          offset $offset;
        ''',
          options: Options(validateStatus: (_) => true));

      var statusCode = response.statusCode;
      // developer.log('$statusCode', name: 'StatusCode');

      // developer.log(response.data.toString());
      final responseData = response.data as List<dynamic>;

      if (statusCode == 200) {
        var responseInternal = responseData
            .map<GameModel>(
                (games) => GameModel.fromMap(games as Map<String, dynamic>))
            .toList();
        await _sqliteGamesService.updateListGames(
          games: responseInternal,
          idPlatform: idPlatform,
        );
        return responseInternal;
      } else {
        return _sqliteGamesService.getGamesList(
          limit: limit,
          offset: offset,
          idPlatform: idPlatform,
        );
      }
    } on DioError catch (e, s) {
      var errorStatusCode = e.response?.statusCode;
      if (errorStatusCode == 429) {
        throw TooManyRequestsException('Many Request happening.');
      }
      developer.log('$errorStatusCode', name: 'errorStatusCode');
      developer.log('$e', name: 'Dio Error', stackTrace: s);
      developer.log('$s', name: 'Dio StackTrace', stackTrace: s);
      throw ServerException('Exception on server');
    } catch (e, s) {
      developer.log('$e', name: 'Error', stackTrace: s);
      developer.log('$s', name: 'StackTrace', stackTrace: s);
      throw ServerException('Exception when load Games List');
    }
  }

  @override
  Future<void> generateToken() async {
    var dio = _dioService.getDio();
    const baseGamesUrl =
        "https://id.twitch.tv/oauth2/token?client_id=0uy52675r40ll0yo5a2p1v36cjxw64&client_secret=dzarctfdcgbv2rdadw4loka5m4g380&grant_type=client_credentials";
    try {
      final response = await dio.post(baseGamesUrl,
          data: {
            "client_id": "0uy52675r40ll0yo5a2p1v36cjxw64",
            "client_secret": "dzarctfdcgbv2rdadw4loka5m4g380",
            "grant_type": "client_credentials"
          },
          options: Options(validateStatus: (_) => true));

      var statusCode = response.statusCode;
      developer.log('$statusCode', name: 'StatusCode');

      developer.log(response.data.toString());

      if (statusCode == 200) {
        ConstantsAPI.token = response.data['access_token'];
      } else {}
    } on DioError catch (e, s) {
      var errorStatusCode = e.response?.statusCode;
      if (errorStatusCode == 429) {
        throw TooManyRequestsException('Many Request happening.');
      }
      developer.log('$errorStatusCode', name: 'errorStatusCode');
      developer.log('$e', name: 'Dio Error', stackTrace: s);
      developer.log('$s', name: 'Dio StackTrace', stackTrace: s);
      throw ServerException('Exception on server');
    } catch (e, s) {
      developer.log('$e', name: 'Error', stackTrace: s);
      developer.log('$s', name: 'StackTrace', stackTrace: s);
      throw ServerException('Exception when load Games List');
    }
  }
}
