{{#hasModel}}
{{#modelExists}}
import '{{{modelImport}}}';
{{/modelExists}}
{{/hasModel}}

{{#is_crud}}
/// {{name.pascalCase()}} Interface
///
/// Defines a standard CRUD contract for {{name.sentenceCase()}} data operations.
/// Use this interface to abstract data persistence logic.
abstract class {{name.pascalCase()}}Interface {
{{/is_crud}}
{{#is_empty}}
/// {{name.pascalCase()}} Interface
///
/// Defines a custom contract for {{name.sentenceCase()}} operations.
/// Extend this interface with your own methods as needed.
abstract class {{name.pascalCase()}}Interface {
{{/is_empty}}
  {{#is_crud}}
  {{#hasModel}}{{#modelExists}}
  Future<List<{{modelName}}>> getAll();
  Future<{{modelName}}?> getById(int id);
  Future<{{modelName}}> create({{modelName}} model);
  Future<{{modelName}}> update(int id, {{modelName}} model);
  Future<void> delete(int id);
  {{/modelExists}}{{/hasModel}}
  {{^hasModel}}
  Future<List<dynamic>> getAll();
  Future<dynamic> getById(int id);
  Future<void> create(Map<String, dynamic> data);
  Future<void> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
  {{/hasModel}}
  {{/is_crud}}

  {{#is_empty}}
  // Define custom methods here
  {{/is_empty}}
}