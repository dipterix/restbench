# Initialize, run once
debug <- getOption('restbatch.debug', FALSE)
safe_run <- function(expr, res, debug = FALSE){
  ret <- tryCatch({ expr }, error = function(e){
    # I'm a teapot, well, the request is improper, change your coffee to your tea
    res$status <- 418
    print(e)
    list(
      error = e$message,
      call = paste(utils::capture.output({ e$call }), collapse = '\n')
    )
  })
  ret
}


#* Create a new task with shared data directory
#* @serializer json
#* @post /new
function(req, res) {
  if(debug){ assign('req', req, envir = globalenv())}
  safe_run({
    restbatch <- asNamespace('restbatch')
    userid <- restbatch$clean_db_entry(req$HEADERS[['restbatch.userid']], "[^a-zA-Z0-9]", msg = "Invalid user ID: illegal characters found.")

    # Parse task
    task <- restbatch$handler_unpack_task(req)

    # Queue & watch task
    restbatch$queue_task(task, userid)

    return(list(message = "Job submitted."))
  }, res = res, debug = debug)
}


#* @serializer json
#* @post /list
function(req, res){
  if(debug){ assign('req', req, envir = globalenv())}

  safe_run({
    userid <- req$HEADERS[["restbatch.userid"]]
    status <- req$body$status
    stopifnot(isTRUE(status %in% c("running", "init", "finish", "valid", "all", "canceled")))

    tbl <- restbatch::handler_query_task(userid, status = status)
    tbl
  }, res = res, debug = debug)

}

#* @serializer unboxedJSON
#* @post /status
function(req, res){
  if(debug){ assign('req', req, envir = globalenv())}

  safe_run({
    ns <- asNamespace('restbatch')

    userid <- ns$clean_db_entry(req$HEADERS[["restbatch.userid"]], msg = '[1] Invalid user ID')
    task_name <- ns$clean_db_entry(req$body$task_name, disallow = '[^a-zA-Z0-9-_]', msg = '[5] Invalid task name')

    # # get database connection and ensure proper disconnection
    # conn <- ns$db_ensure(close = FALSE)
    # ns$db_lock(conn)
    # on.exit({
    #   ns$db_unlock(conn)
    #   DBI::dbDisconnect(conn)
    # })
    #
    # # query the task status
    # # userid and task_name only contain letters, digits and -_, so quote them and it's safe against SQL injection
    # tbl <- DBI::dbGetQuery(conn, sprintf(
    #   'SELECT * FROM restbatchtasksserver WHERE userid="%s" AND name="%s"',
    #   userid, task_name
    # ))
    #
    # # Close now as restoring task may need connection to DB
    # ns$db_unlock(conn)
    # DBI::dbDisconnect(conn)
    # on.exit({})
    #
    # # just hide some information
    # tbl$path <- NULL
    # tbl$clientip <- NULL
    # tbl$ncpu <- NULL
    # tbl$userid <- NULL
    # if(nrow(tbl)){
    #   tbl <- as.list(tbl[1,])
    # } else {
    #   tbl <- as.list(tbl)
    # }


    # add local information
    task <- ns$restore_task(task_name = task_name, userid = userid,
                            .client = FALSE, .update_db = TRUE)

    if(is.null(task)){
      ret <- list(
        name = task_name,
        status = "unknown",
        error = NA,
        removed = 1L,
        packed = 0L,
        time_added = NA,
        n_total = NA,
        n_started = NA,
        n_done = NA,
        n_error = NA
      )
    } else {
      s <- task$local_status()
      ret <- list(
        name = task$task_name,
        status = task$..server_status,
        error = as.integer(s$error > 0),
        removed = 0L,
        packed = as.integer(task$..server_packed),
        time_added = as.numeric(task$..server_time_added),
        n_total = task$njobs,
        n_started = s$started,
        n_done = s$done,
        n_error = s$error
      )
    }

    ret
  }, res = res, debug = debug)
}

#* @serializer contentType list(type="application/zip")
#* @post /download
function(req, res){
  if(debug){ assign('req', req, envir = globalenv())}

  safe_run({
    ns <- asNamespace('restbatch')

    userid <- ns$clean_db_entry(req$HEADERS[["restbatch.userid"]], msg = '[1] Invalid user ID')
    task_name <- ns$clean_db_entry(req$body$task_name, disallow = '[^a-zA-Z0-9-_]', msg = '[6] Invalid task name')
    task <- ns$restore_task(task_name = task_name, userid = userid, .client = FALSE, .update_db = TRUE)

    if(!task$..server_packed){
      stop("Task was not packed when you sent them.")
    }
    if(!task$locally_resolved()){
      stop("Task has not been resolved.")
    }
    if(task$..server_status != 2L){
      stop("Packing the result still in progress.")
    }
    # zipped <- ns$task__zip(task)
    zipped <- paste0(task$task_dir, '.zip')
    if(!file.exists(zipped)){
      stop("Cannot find the result file.")
    }
    readBin(zipped, "raw", n=file.info(zipped)$size)
  }, res = res, debug = debug)
}

#* @post /remove
function(req, res){
  if(debug){ assign('req', req, envir = globalenv())}

  safe_run({
    ns <- asNamespace('restbatch')

    userid <- ns$clean_db_entry(req$HEADERS[["restbatch.userid"]], msg = '[1] Invalid user ID')
    task_name <- ns$clean_db_entry(req$body$task_name, disallow = '[^a-zA-Z0-9-_]', msg = '[7] Invalid task name')
    task <- ns$restore_task(task_name = task_name, userid = userid, .client = FALSE, .update_db = TRUE)

    # This might cause batchtools to hang?
    if(!is.null(task)){
      if(isTRUE(dir.exists(task$task_dir))){
        unlink(task$task_dir, recursive = TRUE)
      }
      if(isTRUE(file.exists(paste0(task$task_dir, '.zip')))){
        unlink(paste0(task$task_dir, '.zip'))
      }
      try({
        db_update_task_server2(task, userid = userid)
      }, silent = TRUE)
    }

  }, res = res, debug = debug)
}

