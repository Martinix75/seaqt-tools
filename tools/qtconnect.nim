#[implification of the Signal/Slot mechanism for Nim-Sea-Qt. With the possibility of passing topics to the function called.
by MArtinix75 2025
version 0.2.0
]#
import std/macros

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`())

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`())

#----------- overload functin args -----------------------------------------------------------------
macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: int) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: int) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: float) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: float) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: string) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: string) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))
macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: seq[int]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: seq[int]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: seq[float]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: seq[float]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))
        
macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; functionArg: seq[string]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc() {.closure.} =
            `callFunction`(`functionArg`))

macro connect*(widgetCall: untyped; widgetSignal: untyped; callFunction: untyped; qtArg: untyped; functionArg: seq[string]) =
    result = quote do:
        `widgetCall`.`widgetSignal`(
            proc(qtArg: `qtArg`) {.closure.} =
            `callFunction`(`functionArg`))
