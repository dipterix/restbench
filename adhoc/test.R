require(restbatch)

f <- '~/Desktop/junk/settings.yaml'
conf <- yaml::read_yaml('inst/debug_settings.yaml')
conf$options$debug = TRUE
conf$options$require_auth = T
conf$options$max_concurrent_jobs = 4
yaml::write_yaml(conf, f)
restbatch:::db_backup(T)

devtools::load_all();restbatch:::db_backup(T);p = restbatch::ensure_server(host = "10.0.0.132", port = 7033)



# rstudioapi::jobRunScript(local({
#   ff <- tempfile()
#   writeLines("restbatch:::start_server_internal(port = 7034, settings = '~/Desktop/junk/settings.yaml')", ff)
#   ff
# }))
# devtools::load_all();restbatch:::db_backup(T);
restbatch:::start_server_internal(port = 7034, settings = '~/Desktop/junk/settings.yaml')

# p = restbatch::start_server(port = 7033)

# restbatch:::portAvailable(7034)
# restbatch:::server_alive(port = 7034)

default_host('10.0.0.217')


task <- restbatch:::new_task2(function(x){
  Sys.sleep(1)
  Sys.getpid()
}, x = 1:3, task_name = "Test"); task

# res <- task$submit(); task$collect()
# task$reload_registry(TRUE)
# task$reg$cluster.functions <- batchtools::makeClusterFunctionsSocket(1)
# batchtools::submitJobs(reg = task$reg)
# batchtools::findExpired(reg = task$reg)
#
# task$status()->s; s
# task$collect()
# task$host <- "10.0.0.132"
# task$port <- 7034

# res <- task$validate(); res
res <- task$submit(); httr::content(res)
task$collect()
# restbatch:::db_backup(T)
# restbatch:::db_get_task(userid = restbatch:::get_user(), client = FALSE, status = 'all')
# restbatch:::db_get_task(userid = 'e5f6226c9f2e6874dd3a7f0944b13dcb', client = FALSE, status = 'all')
restbatch::list_tasks(status = 'all')
restbatch::request_task_list()
# task$..view()

task$collect()


task$local_status()
task$task_name

# task$remove()

res <- request_server('http://127.0.0.1:7033/task/status', body = list(task_name = '64d5010ac8f40ebd109b31817f2ccb04__noname__eODgK1F4aToedcFG'))
httr::content(res)

task$server_status()

restbatch::request_task_list()
task <- restbatch:::restore_task('22dbdc9ec25174a768c15e03c7356780__Noname__6463c71c4e020491')
task$resolved()
task$local_status()

task$server_status()

task$..view()
task$collect()

restbatch::kill_server()


