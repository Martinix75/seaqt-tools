import std/macros
# SOLUZIONE SEMPLICE: Due macro con overloading

# Macro senza parametro (per segnali come clicked)
macro connect*(call: untyped; event: untyped; fuc: untyped) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`())

# Macro con parametro (per segnali come valueChanged)
macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`())
#---------------------------------------------------------------------------------------
macro connect*(call: untyped; event: untyped; fuc: untyped; par: int) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: int) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; par: float) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: float) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))


macro connect*(call: untyped; event: untyped; fuc: untyped; par: string) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: string) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; par: seq[int]) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: seq[int]) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))


macro connect*(call: untyped; event: untyped; fuc: untyped; par: seq[float]) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: seq[float]) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; par: seq[string]) =
    result = quote do:
        `call`.`event`(
            proc() {.closure.} =
            `fuc`(`par`))

macro connect*(call: untyped; event: untyped; fuc: untyped; paramType: untyped; par: seq[string]) =
    result = quote do:
        `call`.`event`(
            proc(val: `paramType`) {.closure.} =
            `fuc`(`par`))

