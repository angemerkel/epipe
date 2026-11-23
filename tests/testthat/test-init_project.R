template <- function(item) system.file(item, package = "epipe", mustWork = TRUE)

test_that("copies _targets.R and config.R unchanged", {
  path <- withr::local_tempdir()
  copied <- suppressMessages(init_project(path))

  expect_setequal(basename(copied), c("_targets.R", "config.R"))
  for (file in c("_targets.R", "config.R")) {
    expect_equal(unname(tools::md5sum(file.path(path, file))),
                 unname(tools::md5sum(template(file))))
  }
})

test_that("creates a missing folder", {
  path <- file.path(withr::local_tempdir(), "new", "analysis")
  suppressMessages(init_project(path))

  expect_true(file.exists(file.path(path, "config.R")))
})

test_that("keeps an edited config.R unless overwrite = TRUE", {
  path <- withr::local_tempdir()
  writeLines("# my settings", file.path(path, "config.R"))

  expect_message(copied <- init_project(path), "Kept existing")
  expect_false("config.R" %in% basename(copied))
  expect_equal(readLines(file.path(path, "config.R")), "# my settings")

  expect_message(init_project(path, overwrite = TRUE), "Replaced")
  expect_equal(unname(tools::md5sum(file.path(path, "config.R"))),
               unname(tools::md5sum(template("config.R"))))
})

test_that("attaching epipe writes no files (regression, #4)", {
  path <- withr::local_tempdir()
  withr::local_dir(path)
  suppressMessages(epipe:::.onAttach(path, "epipe"))

  expect_length(list.files(path, all.files = TRUE, no.. = TRUE), 0)
})
