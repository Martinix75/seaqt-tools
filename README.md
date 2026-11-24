# seaqt-tools

Small tools that make it easier to write Qt6 programs in Nim with
[seaqt](https://github.com/seaqt/nim-seaqt).

The `tools` folder has two files, and each one does a different job:

| File | What it does |
|------|--------------|
| `qtconnect.nim` | A `connect` macro that links a widget signal to your Nim procedure in a short, easy way. |
| `nimdeploy.nim` | A small program for Windows that copies all the DLLs your `.exe` needs, so it runs on any PC. |

---

## 1. qtconnect.nim

**Version:** 0.6.3

### The problem

With seaqt, every widget signal has its own form. Some signals use a plain
procedure, while others need a special "slot" wrapper with the right
parameter type. For example:

```nim
button.onClicked(proc() {.closure.} = saveData())

lineEdit.onTextChanged(QLineEditTextChangedSlot(
  proc(qtArg: openArray[char]) {.closure.} = updateTitle()))
```

You must remember the slot name, the parameter type and the closure pragma
for every widget. That is easy to get wrong.

### The solution

With `qtconnect` you always write the same thing:

```nim
connect(widget, signal, yourProc)
```

The macro looks at the widget type at compile time and writes the right
code for you.

### How to use it

Copy `qtconnect.nim` into your project and import it:

```nim
import qtconnect
```

There are three versions of `connect`, one for each number of arguments
your procedure takes (0, 1 or 2):

```nim
proc saveData() = echo "saved"
proc setLed(n: int) = echo "LED ", n
proc setPin(pin: int, state: bool) = echo pin, " = ", state

connect(saveButton, onClicked, saveData)           # no arguments
connect(ledButton,  onClicked, setLed, 3)          # one argument
connect(pinBox,     onClicked, setPin, 5, true)    # two arguments
```

The extra arguments can be of any type (they are generic).

### How it works

When you compile, the macro does these steps:

1. **Finds the widget type.** It reads the type of the widget (for example
   `QLineEdit`) and removes the `Q` at the start. If the name starts with
   `Abstract`, it removes that too (`QAbstractButton` becomes `Button`).
2. **Checks the signal.** Some signals send a value. The macro knows these
   ones and their value type:

   | Signal | Value type |
   |--------|-----------|
   | `onTextChanged` | `openArray[char]` |
   | `onCurrentTextChanged` | `openArray[char]` |
   | `onStateChanged` | `cint` |
   | `onValueChanged` | `cint` |
   | `onCurrentIndexChanged` | `cint` |

   Any other signal (for example `onClicked`) is treated as a signal with
   no value.
3. **Builds the slot name.** For a signal that sends a value, the macro
   builds the slot name like this:
   `"Q" + widget type + signal name without "on" + "Slot"`.
   For example, `QLineEdit` + `onTextChanged` gives `QLineEditTextChangedSlot`.
4. **Handles the exceptions.** Some widgets (`Slider`, `Widget`, `Button`)
   do not use the slot wrapper. For these, the macro passes the procedure
   directly.
5. **Writes the final code.** It creates a closure that calls your
   procedure with your arguments.

### Things to know

- **Your procedure does not get the signal value.** For example, with
  `onTextChanged` your procedure does not receive the new text. If you need
  it, read it from the widget inside your procedure.
- **The widget must already exist.** The first argument is `typed`, so it
  must be a variable the compiler already knows.
- **To add a new signal that sends a value**, add it to the table in
  `getSignalParameterTypes()`.
- **To add a new exception widget**, add its name to the list in
  `ecexioniXX()`.
- At compile time the macro prints some `Debug - ...` lines. They show the
  widget type and slot name it found, which helps if something goes wrong.

---

## 2. nimdeploy.nim

**Version:** 0.2.0

### The problem

When you build a Qt6 program on Windows with MSYS2, the `.exe` needs many
DLLs: the Qt DLLs, the Qt plugins, and the MinGW libraries (`libstdc++`,
`libgcc`, `libwinpthread`, `icu`, `zstd` and others). On your PC everything
works because MSYS2 is installed. On another PC the program does not start,
because these DLLs are missing.

### The solution

`nimdeploy` copies all the needed files into the folder of your `.exe`.
You can then copy that folder to any Windows PC, and the program runs
without installing MSYS2 or Qt.

### Requirements

- Windows with MSYS2 installed (`C:/msys64`)
- Qt6 installed in MSYS2 (the `mingw64` packages)
- `ldd` available (run the program from the MSYS2 MINGW64 shell)

### Settings

At the top of the file there are a few constants. Change them for your
project:

```nim
const
  exeName = "dclockGui2.exe"              # the program to deploy
  targetDir = "."                         # where to copy the files
  mingwBin = "C:/msys64/mingw64/bin"      # MinGW folder in MSYS2
  windeployqt = mingwBin / "windeployqt.exe"
  windeployArgs = "--no-translations --compiler-runtime"
```

- `--no-translations` does not copy the Qt translation files. Remove it if
  your program needs them.
- `--compiler-runtime` asks windeployqt to copy the compiler libraries too.

### How to use it

1. Compile the tool:
   ```
   nim c nimdeploy.nim
   ```
2. Put `nimdeploy.exe` in the same folder as your program.
3. Run it from the MSYS2 MINGW64 shell:
   ```
   ./nimdeploy.exe
   ```

### How it works

The program does three steps, in this order:

1. **Qt files (windeployqt).** It runs `windeployqt.exe` on your program.
   This is the official Qt tool. It copies the Qt DLLs and the plugins the
   program needs (`platforms`, `styles`, `imageformats`, ...) into
   subfolders. If windeployqt is missing or fails, the program stops with an
   error.
2. **MinGW DLLs for the exe.** It runs `ldd` on your `.exe`. `ldd` lists all
   the DLLs the program uses. The tool keeps only the ones that come from
   `mingw64/bin` and copies them next to the `.exe`.
3. **MinGW DLLs for the plugins.** Qt plugins can need other MinGW DLLs that
   the `.exe` does not use directly. For example, the JPEG plugin needs
   `libjpeg`. So the tool runs `ldd` on every DLL in the subfolders and
   copies what is missing.

The order is important: windeployqt runs first. After that, `ldd` finds the
Qt DLLs already in your folder, so it only copies the MinGW libraries that
are still missing.

### Messages

The program prints one line for each DLL (the messages are in Italian):

| Message | Meaning |
|---------|---------|
| `copiato: <dll>` | copied |
| `già presente: <dll>` | already in the folder, so not copied again |
| `NON TROVATO: <dll>` | not found in `mingwBin`: check this one |

### Test it

To be sure nothing is missing, test the program on a PC without MSYS2. You
can also start it from a normal `cmd` window. In the MSYS2 shell the
program can still find DLLs in MSYS2, so a missing one may not show up.

---

## Author

Martinix75
