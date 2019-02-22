namespace Mq.Executor

module Db =

    module Model =

        [<CLIMutable>]
        type Program =
            { Id: int
              Code: string }
    
        [<CLIMutable>]
        type Task =
            { Id: int
              Program: int
              Author: string }  

        [<CLIMutable>]
        type ExecutionResults =
            { Author: string
              Task: int
              Program: int
              Content: byte[]
              Args: string[][]
              Status: string }   


    module Requests =
        open Model
        open Mq.Core
        open Mq.Core.Operators
        open System

        let getPrograms connection programId : Async<Program seq> =
            let query = 
                """
                (select code, id from programs where id = @id)
                union
                (with recursive r as ((select program, "scope_program" from scope where program = @id)
                union
                (select scope.program, scope."scope_program" from scope
                join r on scope.program = r."scope_program"))
                select code, id from r join programs on r."scope_program" = programs.id)
                """
            FDapper.preparedQueryAsync connection query (Map ["id" => programId]) 

        let dequeueTask connection : Async<Task option> =
            let query = 
                """
                select * from "fetch_tasks"(1)
                """
            FDapper.queryAsync connection query
            |> Async.map Seq.tryLast

        let completeTask connection taskId : Async<int> =
            let command =
                """
                update tasks set status = 'completed'::"task_status", "completed_at" = @completedAt where id = @id
                """
            FDapper.preparedExecuteAsync connection command (Map ["completedAt" => DateTime.UtcNow; "id" => taskId])

        let insertResults connection results : Async<int> =
            let command =
                """
                insert into "execution_results" (content, author, program, task, status) values (@content, @author, @program, @task, @status :: "result_status")
                """ 
            FDapper.preparedExecuteAsync connection command results

        let completeAndInsert connection (task: Task) (results: ExecutionResults) = 
            let task = async {
                do! insertResults connection results |> Async.ignore
                do! completeTask connection task.Id |> Async.ignore

            }
            FDapper.transactionAsync task