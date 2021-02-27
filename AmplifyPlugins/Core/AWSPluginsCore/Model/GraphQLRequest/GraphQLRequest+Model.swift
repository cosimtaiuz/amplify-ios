//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

// MARK: - Protocol

/// Protocol that represents the integration between `GraphQLRequest` and `Model`.
///
/// The methods defined here are used to build a valid `GraphQLRequest` from types
/// conforming to `Model`.
protocol ModelGraphQLRequestFactory {

    // MARK: Query

    /// Creates a `GraphQLRequest` that represents a query that expects multiple values as a result.
    /// The request will be created with the correct document based on the `ModelSchema` and
    /// variables based on the the predicate.
    ///
    /// - Parameters:
    ///   - modelType: the metatype of the model
    ///   - predicate: an optional predicate containing the criteria for the query
    /// - Returns: a valid `GraphQLRequest` instance
    ///
    /// - seealso: `GraphQLQuery`, `GraphQLQueryType.list`
    static func list<M: Model>(_ modelType: M.Type,
                               where predicate: QueryPredicate?,
                               apiName: String?) -> GraphQLRequest<[M]>

    /// Creates a `GraphQLRequest` that represents a query that expects a single value as a result.
    /// The request will be created with the correct correct document based on the `ModelSchema` and
    /// variables based on given `id`.
    ///
    /// - Parameters:
    ///   - modelType: the metatype of the model
    ///   - id: the model identifier
    /// - Returns: a valid `GraphQLRequest` instance
    ///
    /// - seealso: `GraphQLQuery`, `GraphQLQueryType.get`
    static func get<M: Model>(_ modelType: M.Type, byId id: String, apiName: String?) -> GraphQLRequest<M?>

    // MARK: Mutation

    /// Creates a `GraphQLRequest` that represents a mutation of a given `type` for a `model` instance.
    ///
    /// - Parameters:
    ///   - model: the model instance populated with values
    ///   - modelSchema: the model schema of the model
    ///   - predicate: a predicate passed as the condition to apply the mutation
    ///   - type: the mutation type, either `.create`, `.update`, or `.delete`
    /// - Returns: a valid `GraphQLRequest` instance
    static func mutation<M: Model>(of model: M,
                                   modelSchema: ModelSchema,
                                   where predicate: QueryPredicate?,
                                   type: GraphQLMutationType,
                                   apiName: String?) -> GraphQLRequest<M>

    /// Creates a `GraphQLRequest` that represents a create mutation
    /// for a given `model` instance.
    ///
    /// - Parameters:
    ///   - model: the model instance populated with values
    /// - Returns: a valid `GraphQLRequest` instance
    /// - seealso: `GraphQLRequest.mutation(of:where:type:)`
    static func create<M: Model>(_ model: M, apiName: String?) -> GraphQLRequest<M>

    /// Creates a `GraphQLRequest` that represents an update mutation
    /// for a given `model` instance.
    ///
    /// - Parameters:
    ///   - model: the model instance populated with values
    ///   - predicate: a predicate passed as the condition to apply the mutation
    /// - Returns: a valid `GraphQLRequest` instance
    /// - seealso: `GraphQLRequest.mutation(of:where:type:)`
    static func update<M: Model>(_ model: M,
                                 where predicate: QueryPredicate?, apiName: String?) -> GraphQLRequest<M>

    /// Creates a `GraphQLRequest` that represents a delete mutation
    /// for a given `model` instance.
    ///
    /// - Parameters:
    ///   - model: the model instance populated with values
    ///   - predicate: a predicate passed as the condition to apply the mutation
    /// - Returns: a valid `GraphQLRequest` instance
    /// - seealso: `GraphQLRequest.mutation(of:where:type:)`
    static func delete<M: Model>(_ model: M,
                                 where predicate: QueryPredicate?, apiName: String?) -> GraphQLRequest<M>

    // MARK: Subscription

    /// Creates a `GraphQLRequest` that represents a subscription of a given `type` for a `model` type.
    /// The request will be created with the correct document based on the `ModelSchema`.
    ///
    /// - Parameters:
    ///   - modelType: the metatype of the model
    ///   - type: the subscription type, either `.onCreate`, `.onUpdate` or `.onDelete`
    /// - Returns: a valid `GraphQLRequest` instance
    ///
    /// - seealso: `GraphQLSubscription`, `GraphQLSubscriptionType`
    static func subscription<M: Model>(of: M.Type,
                                       type: GraphQLSubscriptionType, apiName: String?) -> GraphQLRequest<M>
}

// MARK: - Extension

/// Extension that provides an integration layer between `Model`,
/// `GraphQLDocument` and `GraphQLRequest` by conforming to `ModelGraphQLRequestFactory`.
///
/// This is particularly useful when using the GraphQL API to interact
/// with static types that conform to the `Model` protocol.
extension GraphQLRequest: ModelGraphQLRequestFactory {

    public static func create<M: Model>(_ model: M, apiName: String? = nil) -> GraphQLRequest<M> {
        let modelType = ModelRegistry.modelType(from: model.modelName) ?? Swift.type(of: model)
        let modelSchema = modelType.schema
        return create(model, modelSchema: modelSchema, apiName: apiName)
    }

    public static func update<M: Model>(_ model: M,
                                        where predicate: QueryPredicate? = nil, apiName: String? = nil) -> GraphQLRequest<M> {
        let modelType = ModelRegistry.modelType(from: model.modelName) ?? Swift.type(of: model)
        let modelSchema = modelType.schema
        return update(model, modelSchema: modelSchema, where: predicate, apiName: apiName)
    }

    public static func delete<M: Model>(_ model: M,
                                        where predicate: QueryPredicate? = nil, apiName: String? = nil) -> GraphQLRequest<M> {
        let modelType = ModelRegistry.modelType(from: model.modelName) ?? Swift.type(of: model)
        let modelSchema = modelType.schema
        return delete(model, modelSchema: modelSchema, where: predicate)
    }

    public static func create<M: Model>(_ model: M, modelSchema: ModelSchema, apiName: String? = nil) -> GraphQLRequest<M> {
        return mutation(of: model, modelSchema: modelSchema, type: .create, apiName: apiName)
    }

    public static func update<M: Model>(_ model: M,
                                        modelSchema: ModelSchema,
                                        where predicate: QueryPredicate? = nil, apiName: String? = nil) -> GraphQLRequest<M> {
        return mutation(of: model, modelSchema: modelSchema, where: predicate, type: .update, apiName: apiName)
    }

    public static func delete<M: Model>(_ model: M,
                                        modelSchema: ModelSchema,
                                        where predicate: QueryPredicate? = nil, apiName: String? = nil) -> GraphQLRequest<M> {
        return mutation(of: model, modelSchema: modelSchema, where: predicate, type: .delete, apiName: apiName)
    }

    public static func mutation<M: Model>(of model: M,
                                          where predicate: QueryPredicate? = nil,
                                          type: GraphQLMutationType,
                                          apiName: String? = nil) -> GraphQLRequest<M> {
        mutation(of: model, modelSchema: model.schema, where: predicate, type: type, apiName: apiName)
    }

    public static func mutation<M: Model>(of model: M,
                                          modelSchema: ModelSchema,
                                          where predicate: QueryPredicate? = nil,
                                          type: GraphQLMutationType,
                                          apiName: String? = nil) -> GraphQLRequest<M> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelSchema: modelSchema,
                                                               operationType: .mutation)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: type))

        switch type {
        case .create:
            documentBuilder.add(decorator: ModelDecorator(model: model))
        case .delete:
            documentBuilder.add(decorator: ModelIdDecorator(id: model.id))
            if let predicate = predicate {
                documentBuilder.add(decorator: FilterDecorator(filter: predicate.graphQLFilter))
            }
        case .update:
            documentBuilder.add(decorator: ModelDecorator(model: model))
            if let predicate = predicate {
                documentBuilder.add(decorator: FilterDecorator(filter: predicate.graphQLFilter))
            }
        }

        let document = documentBuilder.build()
        return GraphQLRequest<M>(apiName: apiName,
                                 document: document.stringValue,
                                 variables: document.variables,
                                 responseType: M.self,
                                 decodePath: document.name)
    }

    public static func get<M: Model>(_ modelType: M.Type,
                                     byId id: String,
                                     apiName: String? = nil) -> GraphQLRequest<M?> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelSchema: modelType.schema,
                                                               operationType: .query)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .get))
        documentBuilder.add(decorator: ModelIdDecorator(id: id))
        let document = documentBuilder.build()

        return GraphQLRequest<M?>(apiName: apiName,
                                  document: document.stringValue,
                                  variables: document.variables,
                                  responseType: M?.self,
                                  decodePath: document.name)
    }

    public static func list<M: Model>(_ modelType: M.Type,
                                      where predicate: QueryPredicate? = nil,
                                      apiName: String? = nil) -> GraphQLRequest<[M]> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelSchema: modelType.schema,
                                                               operationType: .query)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .list))

        if let predicate = predicate {
            documentBuilder.add(decorator: FilterDecorator(filter: predicate.graphQLFilter))
        }

        documentBuilder.add(decorator: PaginationDecorator())
        let document = documentBuilder.build()

        return GraphQLRequest<[M]>(apiName: apiName,
                                   document: document.stringValue,
                                   variables: document.variables,
                                   responseType: [M].self,
                                   decodePath: document.name + ".items")
    }

    public static func subscription<M: Model>(of modelType: M.Type,
                                              type: GraphQLSubscriptionType,
                                              apiName: String? = nil) -> GraphQLRequest<M> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(modelSchema: modelType.schema,
                                                               operationType: .subscription)
        documentBuilder.add(decorator: DirectiveNameDecorator(type: type))
        let document = documentBuilder.build()

        return GraphQLRequest<M>(apiName: apiName,
                                 document: document.stringValue,
                                 variables: document.variables,
                                 responseType: modelType,
                                 decodePath: document.name)
    }
}
