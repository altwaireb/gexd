{{#hasInterface}}
import '{{{interfaceImport}}}';
{{/hasInterface}}
{{#hasModel}}
{{#modelExists}}
import '{{{modelImport}}}';
{{/modelExists}}
{{/hasModel}}
{{#is_crud}}
/// {{name.pascalCase()}} Repository
///
/// Defines a standard CRUD contract for {{name.sentenceCase()}} data operations.
/// Uses dependency injection for data sources to maintain loose coupling.
class {{name.pascalCase()}}Repository {{#hasInterface}}implements {{name.pascalCase()}}RepositoryInterface {{/hasInterface}}{
  // TODO: Inject your data source through constructor
  // final {{name.pascalCase()}}RemoteDataSource _remoteDataSource;
  // final {{name.pascalCase()}}LocalDataSource _localDataSource;
  
  // {{name.pascalCase()}}Repository(this._remoteDataSource, this._localDataSource);

{{/is_crud}}
{{#is_empty}}
/// {{name.pascalCase()}} Repository
///
/// Defines a custom contract for {{name.sentenceCase()}} operations.
/// Add your own constructor and dependencies as needed.
class {{name.pascalCase()}}Repository {{#hasInterface}}implements {{name.pascalCase()}}RepositoryInterface {{/hasInterface}}{
  // TODO: Add constructor and inject your dependencies here
{{/is_empty}}
  {{#is_crud}}
  {{#hasModel}}{{#modelExists}}
  /// Fetch all items
  {{#hasInterface}}@override{{/hasInterface}}
  Future<List<{{modelName}}>> getAll() async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.getAll();
      throw UnimplementedError('TODO: Implement getAll method');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch item by ID
  {{#hasInterface}}@override{{/hasInterface}}
  Future<{{modelName}}?> getById(int id) async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.getById(id);
      throw UnimplementedError('TODO: Implement getById method');
    } catch (e) {
      rethrow;
    }
  }

  /// Create new record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<{{modelName}}> create({{modelName}} model) async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.create(model);
      throw UnimplementedError('TODO: Implement create method');
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<{{modelName}}> update(int id, {{modelName}} model) async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.update(id, model);
      throw UnimplementedError('TODO: Implement update method');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<void> delete(int id) async {
    try {
      // TODO: Replace with actual data source call
      // await _remoteDataSource.delete(id);
      throw UnimplementedError('TODO: Implement delete method');
    } catch (e) {
      rethrow;
    }
  }
  {{/modelExists}}{{/hasModel}}
  {{^hasModel}}
  /// Fetch all items
  {{#hasInterface}}@override{{/hasInterface}}
  Future<List<dynamic>> getAll() async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.getAll();
      throw UnimplementedError('TODO: Implement getAll method');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch item by ID
  {{#hasInterface}}@override{{/hasInterface}}
  Future<dynamic> getById(int id) async {
    try {
      // TODO: Replace with actual data source call
      // return await _remoteDataSource.getById(id);
      throw UnimplementedError('TODO: Implement getById method');
    } catch (e) {
      rethrow;
    }
  }

  /// Create new record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<void> create(Map<String, dynamic> data) async {
    try {
      // TODO: Replace with actual data source call
      // await _remoteDataSource.create(data);
      throw UnimplementedError('TODO: Implement create method');
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      // TODO: Replace with actual data source call
      // await _remoteDataSource.update(id, data);
      throw UnimplementedError('TODO: Implement update method');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a record
  {{#hasInterface}}@override{{/hasInterface}}
  Future<void> delete(int id) async {
    try {
      // TODO: Replace with actual data source call
      // await _remoteDataSource.delete(id);
      throw UnimplementedError('TODO: Implement delete method');
    } catch (e) {
      rethrow;
    }
  }
  {{/hasModel}}
  {{/is_crud}}

  {{#is_empty}}
  // Define custom methods here
  {{/is_empty}}
}