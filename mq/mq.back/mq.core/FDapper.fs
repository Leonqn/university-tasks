namespace Mq.Core

module FDapper =
    open System.Dynamic
    open System.Collections.Generic
    open Dapper
    open System.Data
    open System.Transactions

    let private createParam (param: obj) =
        match param with
        | :? Map<string, obj> as x -> 
            let expando = ExpandoObject()
            let expandoDictionary = expando :> IDictionary<string,obj>
            for paramValue in x do
                expandoDictionary.Add(paramValue.Key, paramValue.Value)
            box expando
        | _ -> param

    let query (connection: IDbConnection) (query: string) =
        connection.Query<_> query

    let queryAsync (connection: IDbConnection) (query: string) =
        connection.QueryAsync<_> query |> Async.AwaitTask
   
    let preparedQuery (connection: IDbConnection) query (param: obj) =
        let preparedObject = createParam param
        connection.Query<_>(query, preparedObject)   

    let preparedQueryAsync (connection: IDbConnection) query (param: obj) =
        let preparedObject = createParam param
        connection.QueryAsync<_>(query, preparedObject) |> Async.AwaitTask

    let execute (connection: IDbConnection) (command: string)  = 
        connection.Execute command

    let executeAsync (connection: IDbConnection) (command: string)  = 
        connection.ExecuteAsync command |> Async.AwaitTask

    let preparedExecute (connection: IDbConnection) (command: string) (param: obj) =
        let preparedObject = createParam param
        connection.Execute(command, preparedObject)

    let preparedExecuteAsync (connection: IDbConnection) (command: string) (param: obj) =
        let preparedObject = createParam param
        connection.ExecuteAsync(command, preparedObject) |> Async.AwaitTask

    let transactionAsync fAsync = async {
        use transaction = new TransactionScope(System.Transactions.TransactionScopeAsyncFlowOption.Enabled)
        do! fAsync
        transaction.Complete()
    }

    
