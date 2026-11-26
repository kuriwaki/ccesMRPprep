# Written by Codex

# Public ACS interfaces ----
test_that("five-year district cells preserve mutually exclusive race and adult totals", {
  # Each of the 18 age-sex cells has 100 people, including 40 White alone,
  # 35 non-Hispanic White, 30 Black alone, and 25 Hispanic of any race.
  # Of 60 people other than White alone, 20 are Hispanic. Independence of
  # Black race and Hispanic origin then gives 30 * 20 / 60 = 10 in both.
  local_mocked_bindings(get_acs = function(geography, state, year, survey, variables) {
    expect_identical(geography, "congressional district")
    expect_identical(survey, "acs5")
    expect_equal(year, 2024)
    expect_equal(anyDuplicated(variables), 0L)
    table <- sub("_.*", "", variables)
    line <- as.integer(sub(".*_", "", variables))
    estimates <- numeric(length(variables))
    # Place the adult race count in the first fine age bin of each coarse
    # group. The remaining fine bins contain zero within this fixture.
    by_table <- c(B01001A = 40, B01001B = 30, B01001H = 35, B01001I = 25)
    first_lines <- c(3:7, 9, 11, 12, 14, 18:22, 24, 26, 27, 29)
    pick <- table %in% names(by_table) & line %in% first_lines
    estimates[pick] <- by_table[table[pick]]
    estimates[table == "B01001" & line %in% c(3:6, 27:30)] <- 100
    estimates[table == "B15001" & line %in% c(3, 11, 19, 27, 35, 44, 52, 60, 68, 76)] <- 100
    estimates[variables == "B15001_001"] <- 1000
    estimates[variables == "B03002_004"] <- 360
    estimates[variables == "B03002_014"] <- 180
    geos <- if (is.null(state)) c("0200", "3615", "36ZZ", "1198", "7298") else
      switch(state, AK = "0200", NY = c("3615", "36ZZ"))
    do.call(rbind, lapply(geos, function(geo) {
      data.frame(GEOID = geo, variable = variables, estimate = estimates)
    }))
  }, .package = "ccesMRPprep")

  cells <- get_acs_race_cells(2024, states = c("NY", "AK"))
  expect_named(cells, c("cd", "age", "female", "race", "count"))
  expect_setequal(cells$cd, c("NY-15", "AK-01"))
  expect_equal(nrow(cells), 80L)
  expect_equal(anyDuplicated(cells[c("cd", "age", "female", "race")]), 0L)
  expect_identical(levels(cells$race), c("White", "Black", "Hispanic", "Other"))
  expect_identical(levels(cells$age), levels(haven::as_factor(ccesMRPprep::age5_key$age)))
  expected <- c(White = 35, Black = 20, Hispanic = 25, Other = 20)
  expect_equal(cells$count, unname(expected[as.character(cells$race)]), tolerance = 1e-8)
  expect_equal(as.numeric(tapply(cells$count, cells$cd, sum)), c(1000, 1000))
  nationwide <- get_acs_race_cells(2024)
  expect_setequal(nationwide$cd, c("AK-01", "NY-15"))
  expect_equal(nrow(nationwide), 80L)
})

test_that("the complete raw code vector warns and returns its original observations", {
  local_mocked_bindings(get_acs = function(variables, ...) {
    data.frame(GEOID = "3615", NAME = "Congressional District 15 (118th Congress), New York",
               variable = variables, estimate = seq_along(variables), moe = 0)
  }, .package = "ccesMRPprep")
  codes <- rev(ccesMRPprep::acscodes_age_sex_race)
  expect_warning(raw <- get_acs_cces(codes), "get_acs_race_cells")
  expect_identical(raw$acscode, codes)
  expect_equal(raw$count, seq_along(codes))
  expect_no_warning(get_acs_cces(codes[1]))
})

# Bounds and structural zeros ----
test_that("district overlap respects feasible bounds in every age-sex cell", {
  allocate <- ccesMRPprep:::allocate_black_hispanic
  black <- c(9, 6, 0, 3)
  hispanic <- c(8, 5, 3, 3)
  population <- c(13, 21, 5, 3)
  # Both nondegenerate cells have odds ratio 2.
  expect_equal(allocate(black, hispanic, population, 11), c(6, 2, 0, 3), tolerance = 1e-8)
  expect_equal(allocate(black, hispanic, population, 7), c(4, 0, 0, 3))
  expect_equal(allocate(black, hispanic, population, 16), c(8, 5, 0, 3))
  expect_error(allocate(black, hispanic, population, 17))
})
